# Financial Account Lifecycle — Design & Business Documentation

> Covers: account creation/editing, batch save (UPSERT), closing (with balance
> disposal), merging, hard deletion, and reopening — plus the ledger rules,
> state machine, guards & error codes, and the client interaction design.
> This document is kept in lockstep with the current implementation; update it
> whenever the code evolves.

---

## 1. Positioning & Core Design Principles

An account plays two roles in the system:

1. **Balance carrier**: each account has an `initialBalance` (opening) and a
   `currentBalance`; `currentBalance` is ledger-derived:
   `currentBalance = initialBalance + Σ signed effects of cleared transactions`.
2. **Transaction dimension**: every transaction is attached to an account
   (`source_account_id` / `target_account_id`). Transactions are the smallest
   dimension of income/expense reports, net-worth rollups, and AI analysis.

Three **non-negotiable** principles follow:

| Principle | Meaning | Direct consequence |
|---|---|---|
| ① History is never destroyed | Transactions are the user's raw records; no operation may lose or silently rewrite them | Deletion is allowed only for accounts with **zero history**; accounts with history use merge/close |
| ② The ledger must stay self-consistent | At any moment `currentBalance` must be recomputable from the transactions | Balance disposal must create real transactions instead of directly editing the balance field |
| ③ Lifecycle transitions are explicit | Close/delete are irreversible or semi-reversible decisions: dedicated entry points, unambiguous semantics, never hidden inside ordinary editing | Plain editing cannot set an account to CLOSED; closing goes through the dedicated close endpoint |

In one sentence:
**History lives forever (it can be migrated, never destroyed); account identities are reusable (close/reopen); physical deletion is only for empty accounts that never carried history.**

---

## 2. State Machine & Operation Matrix

An account has exactly two states:

```
        PATCH status=ACTIVE (reopen)
      ┌──────────────────────────────┐
      ▼                              │
   ┌───────┐   CLOSE (dedicated)   ┌────────┐
   │ ACTIVE │ ───────────────────▶ │ CLOSED │
   └───────┘                       └────────┘
        ▲                               │
        │      DELETE (empty only)      │（with history: merge first）
        └───────────────────────────────┘
```

| Operation | ACTIVE | CLOSED | Notes |
|---|---|---|---|
| Edit name/type/nature/net-worth flag | ✅ | ✅ | Ordinary editing |
| Edit opening/current balance | ✅ | ✅ (not advised) | PATCH carries balance-shift semantics |
| Close (CLOSE) | ✅ | ❌ (already closed → 409, code 3301) | Only active accounts can be closed |
| Merge into another account (MERGE) | ✅ source/target | ✅ as **source**; ❌ as target (3308) | Merge is the migration/correction path; source may be any state |
| Hard delete (DELETE) | ✅ empty only | ✅ empty only | State-independent: depends only on "has history + zero balance" |
| Reopen (REOPEN) | ❌ meaningless | ✅ | Explicit entry; ordinary editing never silently revives it |

**Key clarification (see FAQ)**: *Reopening does NOT make an account deletable.*
Deletion permission is not about state — it is about whether the account
carries history. A closed account keeps all history; after reopening the
history is still there, so it still cannot be deleted directly. To remove the
account itself, "merge it into another account".

---

## 3. The Six Core Operations

### 3.1 Create / Batch Save (UPSERT)

- `POST /user/financial-accounts` — batch save (the edit page saves the whole set)
- `POST /user/financial-accounts/create` — single create

Batch-save semantics:
- Matches by `id`: existing → in-place update (**identity preserved**); missing `id` → insert;
- **Balances are never reset**: even if the client echoes old balances, the
  server keeps what's in store — transaction-driven balances are not "written back" away;
- Accounts absent from the payload are **not** implicitly deleted (no silent cleanup);
- `status=CLOSED` accounts stay CLOSED through batch save — ordinary editing
  never silently flips a closed account back to active.

### 3.2 Edit (PATCH, `PATCH /user/financial-accounts/{id}`)

- Fields: name, nature, type, currency, opening balance, current balance,
  net-worth inclusion, status;
- **Balance semantics (ledger-friendly)**:
  - `initialBalance` + `currentBalance` both provided → authoritative;
  - only `initialBalance` provided → **shift** `currentBalance` by the same
    delta (accumulated transaction effects preserved, not zeroed);
  - only `currentBalance` provided → direct overwrite (explicit correction);
- **Status guard**: `status=CLOSED` is always rejected (3301 semantics); it must
  go through the close endpoint. Conversely `status=ACTIVE` is allowed — that is
  exactly how "reopen" is implemented server-side.

### 3.3 Close (CLOSE, `POST /user/financial-accounts/{id}/close`)

**Business meaning**: mirrors "closing/terminating a real account" while fully
preserving its transaction history. After closing, the account no longer appears
in new-transaction pickers nor in net-worth rollups, but historical reports stay intact.

**Pre-guards**:
- Account must exist (404) and be ACTIVE (already closed → 409, code 3301);
- **Blocking case**: the account is still referenced by **recurring rules** →
  rejected (code 3304); the user must first disable the rules or merge them into
  another account (recurring rules would keep generating future transactions on a
  closed account — they must be detached first).
- Ordinary transaction history does **not** block closing — closing exists precisely to keep it.

**Balance disposal (`disposal`)**: if the balance is non-zero at close time, one
of three strategies is required (see §4).

**Wrap-up**: `status=CLOSED`; after the disposal entry, the snapshot balance is
recomputed from the ledger (exactly consistent with the transactions); returns
`{account_id, status, disposal, transaction_id, final_balance}`.

### 3.4 Merge (MERGE, `POST /user/financial-accounts/{id}/merge`)

**Business meaning**: the **correction & migration path** for wrong/duplicate
accounts — move the source account's whole history onto the target account,
then the source disappears (physically deleted, but its history continues to
exist as transactions under the target's name).

Behaviour:
1. Guards: cannot merge into itself (3308); currencies must match (3309);
   natures must match — asset→asset, liability→liability (3310); the target must
   be an active account (3311);
2. Re-point every transaction/recurring rule of the source (`source`/`target`)
   to the target account;
3. Recompute the target balance from the (now extended) ledger;
4. Delete the source account (it no longer carries any history).

**Merge is the only path that lets a history-carrying account identity disappear from the system.**

### 3.5 Hard Delete (DELETE, `DELETE /user/financial-accounts/{id}`)

**Business meaning**: physical deletion is permitted only for accounts that
**never carried history and have zero balance**. Such an account holds no raw
records, so deleting it loses nothing (e.g. a mis-created empty account).

Guards (in order):
1. **Reference guard**: any transaction/recurring-rule reference → 409:
   - account CLOSED with references → **code 3312**: dedicated message
     "this closed account keeps its full history; merge it into another account to remove it entirely";
   - active account with references → **code 3302**: "merge it first, or close it";
2. **Balance guard**: non-zero balance → 409 (code 3303): "merge it elsewhere, or
   dispose of the balance when closing";
3. Otherwise → physical delete + commit.

**Delete is a pure "cleanup" entry — it has no migration capability; for migration use merge.**

### 3.6 Reopen (REOPEN)

- Client: the edit page's manage menu shows a "Reopen Account" entry for CLOSED
  accounts (confirm dialog → PATCH `status=ACTIVE`);
- Server: plain PATCH to `ACTIVE` (PATCH only rejects setting CLOSED; CLOSED→ACTIVE is allowed);
- Effect: the account returns to the active set — counted in net worth again,
  selectable for new transactions; **its balance is the current snapshot**
  (keep = the balance at close time; transfer/write-off = zeroed balance); all
  history remains untouched.

---

## 4. Balance Disposal: Business Meaning & Ledger Details

If the balance is non-zero at close time, the three strategies each have a
clear business meaning. **In every case the zeroing/moving of the balance is
done through real transactions** — the balance field is never edited directly,
so the ledger stays self-consistent.

| Disposal | Meaning (one-liner) | Generated entry | Net-worth impact | Example |
|---|---|---|---|---|
| `keep` (freeze snapshot) | "I accept the balance, but it won't change" | **No** entry; balance frozen | Balance keeps counting | closing a digital wallet, archiving an account with a final value |
| `transfer` (move out) | "I still **want** the balance — move it" | **TRANSFER** entry | unchanged (asset move / debt transfer) | moving the balance out before closing a bank card |
| `writeoff` (write off as expense/income) | "I **don't want** the balance — acknowledge it's gone" | **EXPENSE** or **INCOME** entry | net worth drops/rises accordingly (honest bookkeeping) | abandoning leftover prepaid credit, bad-debt write-off, debt forgiveness |

### 4.1 Sign Rules (exactly aligned with the ledger convention)

Ledger conventions:
- `EXPENSE`  → deducts the **source** account;
- `INCOME`   → credits the **target** account (an income attached to the source has no effect);
- `TRANSFER` → source −, target +;
- Liability balances are stored **negative** ("owed money").

The direction is chosen by the **sign of the balance** (not the account nature),
so any account zeros out exactly:

| Scenario | Disposal | Entry shape |
|---|---|---|
| Asset, positive balance (+120) | writeoff | `EXPENSE`, source=closing account → 120−120=0 (treated as spent/lost/bad debt) |
| Liability, negative balance (owed 3000) | writeoff | `INCOME`, target=closing account → −3000+3000=0 (treated as forgiven) |
| Asset, positive balance (+120) | transfer | `TRANSFER`, source=closing account → target +120, closing account → 0 |
| Liability, negative balance (owed 3000) | transfer | `TRANSFER`, **source=chosen target, target=closing account** → closing account +3000 → 0, debt lands on the target (debt transfer) |
| Zero balance | any | disposal is auto-downgraded to `keep` (nothing to dispose) |

> Historical lesson: an earlier implementation chose the direction by "nature"
> instead of "sign", which made liability write-offs grow more negative and
> reversed the debt-transfer direction. Fixed, with regression tests
> (`test_close_liability_*`).

### 4.2 Entry "Source" & Language

- Disposal entries: category `OTHERS`, source column pinned to `SYSTEM`
  (traceably machine-generated, distinct from user-typed/AI entries);
- `raw_input` (the entry's memo) is localized **at creation time** from the
  client's `Accept-Language`: `停用时余额转出/核销`, `停用時餘額轉出/核銷`,
  `口座停止時の残高振替/処理`, `계좌 정지 시 잔액 이체/정리`, English fallback;
- Like a user-typed memo, it is a snapshot: later UI language changes do not
  rewrite existing entries.

---

## 5. Guards & Error-Code Quick Reference (AccountErrorCode 3300–3312)

| Code | Constant | Scenario | Client message (localized) |
|---|---|---|---|
| 3300 | `accountNotFound` | target/account not found | Account not found |
| 3301 | `accountAlreadyClosed` | closing twice | This account is already closed |
| 3302 | `accountDeleteReferenced` | deleting an active referenced account | Still referenced by transactions/rules — merge or close first |
| 3303 | `accountDeleteBalanceNotZero` | deleting an active account with balance | Still has a balance — merge, or dispose when closing |
| 3304 | `accountCloseRecurringActive` | closing while recurring rules exist | Disable/migrate the rules first |
| 3305 | `accountCloseTargetRequired` | transfer disposal without target | A target account is required to transfer out |
| 3306 | `accountCloseTargetClosed` | transfer target is closed | Target is closed — pick another |
| 3307 | `accountCloseTargetCurrencyMismatch` | transfer target currency differs | Target must use the same currency |
| 3308 | `accountMergeSelf` | merging into itself | Cannot merge an account into itself |
| 3309 | `accountMergeCurrencyMismatch` | merging different currencies | Cannot merge accounts with different currencies |
| 3310 | `accountMergeNatureMismatch` | asset into liability (or vice versa) | Assets and liabilities cannot be merged into each other |
| 3311 | `accountMergeClosedTarget` | target is closed | Reopen it or pick another target |
| 3312 | `accountDeleteClosedHasHistory` | deleting a closed account with history | Closed account keeps full history — merge it first |

Client side has a three-layer mapping:
`error_codes.dart` (int) → `error_translator.dart` → `errorMapping.account.*`
(5 languages). Every blocking toast is a localized message — the server's
English text is never shown raw.

---

## 6. Client Interaction Design

### 6.1 Consistency: every management menu/picker reuses system components

- The account manage menu (merge/close/delete/reopen) matches every other
  "three-dot menu" in the app: it uses `ActionBottomSheet` — drag handle, title,
  dividers, icon items with **subtitle explanations**. Tapping an item lets the
  component pop itself (carrying the item's `result`); callers never pop a
  second time (avoiding a go_router double-pop crash);
- The balance-disposal picker (keep/transfer/write-off) uses the **same**
  `ActionBottomSheet`, each option explaining in one subtitle line what it
  actually does in the books;
- The merge-target / transfer-target picker reuses the system
  `AccountSelectionSheet` (the same picker used by the transaction form: title
  + cancel + account cards). A `filter` injects "same currency + active +
  (for merge) same nature + not the current account", pre-filtering options the
  backend would reject.

### 6.2 CLOSED accounts: visuals & entries

- **List**: closed accounts are **dimmed (opacity 0.55)** with a
  `Closed / 已停用` badge next to the name — instantly recognizable;
- **Edit-page manage menu**: for CLOSED accounts, "Reopen Account" becomes the
  primary action, and "Close" is hidden (meaningless when already closed);
- **Delete stays available**, but the server answers with the dedicated guidance
  (3312): to make a closed account disappear, merge it;
- Ordinary edit-save never silently revives a closed account (UPSERT keeps CLOSED).

### 6.3 Guide, don't just reject

- Every blocked scenario tells the user the **next step** (merge first / close
  first / pick another target / reopen) instead of a bare "not allowed";
- Error codes are fine-grained per scenario and localized, giving a consistent
  experience across platforms.

---

## 7. FAQ

**Q1: A closed account can be reopened — why does delete still say "keeps its full history"?**
A: Deletion permission is state-independent; it only depends on whether the
account carries history. Closing promises to keep history — and since the
history is there, a direct delete is never allowed. Reopening only moves the
account from the archive back into the active set (net-worth rollups and new
transaction pickers again); the history is untouched.
**To make the account identity disappear: merge it into another account**
(history moves under the target; the source is removed).

**Q2: Why can't I just set the balance to 0 when closing?**
A: Directly editing the number breaks ledger consistency (the sum of entries
would not equal the balance), and reports/reconciliation would break. The
balance must be flushed by a real EXPENSE/INCOME/TRANSFER entry so "where did
the balance go" is always traceable.

**Q3: Delete / Close / Merge — which one do I pick?**
```
Does the account carry history (transactions/rules)?
 ├─ The account itself is wrong/duplicate  → merge into the correct one (history moves, source disappears)
 ├─ It is real, just no longer used         → close it (dispose balance, keep history, reopenable)
 └─ Want the account identity gone entirely → only via merge (delete disallows history)
No history and zero balance                → delete (physical cleanup)
```

**Q4: Can liabilities (owed money) be "transferred/written off"?**
A: Yes. Liability balances use negative numbers for debt: transfer = debt
moves onto the target; write-off = debt is forgiven (recorded as an income
credit, zeroing it). The direction is chosen automatically from the sign of the
balance — the user does not need to learn the rule.

**Q5: Why are merge/close entries' memos in Chinese/Japanese/Korean?**
A: System entries' memos are generated at creation time from the client's UI
language (`Accept-Language`). Historical entries keep the language they were
created in (snapshot semantics).

**Q6: Where does the source account's "history" go after a merge?**
A: Every transaction's source/target is re-pointed to the target account, and
the target balance is recomputed from the ledger. Not a single line is lost —
it just changes ownership.

---

## 8. API Quick Reference (`/api/v1/user/financial-accounts`)

| Method | Path | Purpose |
|---|---|---|
| POST | `.../create` | Create account |
| POST | `...` | Batch save (UPSERT) |
| GET | `...` | Account list |
| PATCH | `.../{id}` | Edit (status guard: rejects setting CLOSED; allows CLOSED→ACTIVE) |
| DELETE | `.../{id}` | Hard delete (zero history + zero balance only) |
| POST | `.../{id}/merge` | Merge (history migration + source removal) |
| POST | `.../{id}/close` | Close (balance disposal + CLOSED; reads Accept-Language to localize entries) |

Close request: `{disposal: "keep"|"transfer"|"writeoff", targetAccountId?: uuid}`.

---

## 9. Test Coverage (tests/unit/services/test_account_lifecycle.py)

- UPSERT: identity preserved, balances not reset, no implicit deletion, CLOSED stays CLOSED;
- Delete: reference guard / balance guard / empty account deletable / closed-with-history → dedicated 3312 guidance;
- Merge: self/currency/nature/closed-target guards; history re-pointing + balance recompute;
- Close: keep freeze snapshot, transfer (assets), writeoff (assets), already-closed 409;
- Liability direction: writeoff zeroes via INCOME, transfer zeroes via debt transfer (regression-protected);
- System messages: `Accept-Language` → per-language memos (function-level checks).

> Integration/DB cases run in Docker-enabled environments; error codes, routes,
> and static checks are part of the pre-CI validation.
