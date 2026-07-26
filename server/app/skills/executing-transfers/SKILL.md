---
name: executing-transfers
description: >
  Executes fund transfers between asset accounts via interactive wizard with fuzzy account matching.
  USE WHEN: transfer money, move funds between accounts, account-to-account transfer.
  NOT FOR: spending analysis (→ reviewing-finances), recording transactions (→ record_transactions tool), shared ledger queries (→ managing-shared-ledgers).

allowed-tools: "execute record_transactions read_file"
---

# Executing Transfers

Guide users through account-to-account transfers using a visual wizard.

## Scripts

### prepare_transfer.py

```bash
uv run python app/skills/executing-transfers/scripts/prepare_transfer.py --amount 500 --source_hint "ICBC"
```

**Parameters**:
- `--amount`: Transfer amount (optional)
- `--source_hint`: Keyword for source account (optional)
- `--target_hint`: Keyword for target account (optional)

**Output**:
- Success: `{"success": true, "accounts": [...]}` → Show TransferWizard
- Error: `{"error_type": "NO_ACCOUNTS"}` or `{"error_type": "SINGLE_ACCOUNT"}`

**GenUI Component**: `TransferWizard`

## Workflows

### Transfer Intent
1. Run `prepare_transfer.py` with available hints
2. Handle result:
   - **NO_ACCOUNTS**: Inform user, suggest adding accounts in settings
   - **SINGLE_ACCOUNT**: Inform user transfer requires 2+ accounts
   - **SUCCESS**: Wizard displays automatically, respond naturally

### Transfer Confirmation
- User confirms in wizard → backend executes via `record_transactions` tool

## Rules

1. Never mention scripts or technical details to user
2. Open wizard even if amount is missing (wizard has input fields)
3. Only transfer between ASSET-type accounts
4. Always require user confirmation before executing
5. Execute scripts directly without `cd`, `&&`, or pipe operators
