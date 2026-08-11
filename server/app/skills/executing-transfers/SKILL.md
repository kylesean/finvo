---
name: executing-transfers
description: >
  Executes fund transfers between asset accounts via interactive wizard with fuzzy account matching.
  USE WHEN: transfer money, move funds between accounts, account-to-account transfer.
  NOT FOR: spending analysis (→ reviewing-finances), recording transactions (→ record_transactions tool), shared ledger queries (→ managing-shared-ledgers).

allowed-tools: "prepare_transfer record_transactions read_file"
---

# Executing Transfers

Guide users through account-to-account transfers using a visual wizard.

## Tools

### prepare_transfer

Call the `prepare_transfer` tool (typed, structured arguments — never via shell) to build the transfer wizard. It lists the user's transfer-eligible (asset) accounts and produces the **TransferWizard** component.

**Parameters** (extracted strictly from the user's LATEST prompt):
- `amount`: Transfer amount (optional — the wizard has an input field)
- `source_hint`: Keyword for the source account's name/type (optional)
- `target_hint`: Keyword for the target account's name/type (optional)
- `memo`: Transfer note (optional)
- `tags`: Tags extracted from the user's message (optional, same rules as `record_transactions` — infer meaningful tags in the user's language, e.g. "转账" → `转账`; "还信用卡" → `信用卡,还款`; skip when nothing meaningful is extracted)

**Result**: The wizard is ALWAYS returned (the tool never fails on account matching):
- `guidance = NO_ACCOUNTS` or `SINGLE_ACCOUNT`: the wizard renders an empty state — gently tell the user transfers need at least two asset accounts and guide them to add accounts in the Finance section. Do NOT frame this as a failed operation.
- otherwise: wizard displays automatically; respond naturally.

## Workflows

### Transfer Intent
1. Call `prepare_transfer` with the hints available from the user's message
2. The wizard is always returned — never treat account matching as an error:
   - **guidance = `NO_ACCOUNTS` / `SINGLE_ACCOUNT`**: wizard shows an empty state. Gently tell the user transfers need at least two asset accounts and guide them to the Finance section to add accounts.
   - **SUCCESS**: wizard displays automatically, respond naturally.

### Transfer Confirmation
- User confirms in wizard → the UI executes the transfer via `execute_transfer` (the LLM is not involved in this step).

## Rules

1. Never mention technical details (tool names, scripts, schemas) to user
2. Open the wizard even if the amount is missing (wizard has input fields)
3. Only transfer between ASSET-type accounts
4. Always require user confirmation before executing
5. Pass only hints from the user's message — never invent account names or IDs
6. For new transfer requests, extract amount and account hints strictly from the user's LATEST prompt in the current turn. Do NOT carry over parameters from previously completed transfers.
7. Never tell the user an account was "not found". The wizard always lists the transfer-eligible accounts; hints only silently preselect a uniquely-matched account. If the user names an account that isn't available, simply let them pick from the wizard's list.
