---
name: managing-shared-ledgers
description: >
  Manages shared ledgers for family/team collaborative tracking.
  USE WHEN: shared space spending, family bills, team expenses, space summary.
  NOT FOR: personal spending analysis (→ reviewing-finances), personal transfers (→ executing-transfers), budget creation (→ guide to app UI).

allowed-tools: "execute search_transactions read_file"
---

# Managing Shared Ledgers

Handle collaborative financial queries for shared spaces ("we/us" context).

## Scripts

### list_spaces.py

```bash
uv run python app/skills/managing-shared-ledgers/scripts/list_spaces.py
```

**Output**: `spaces` (list with names and user roles)

### query_space_summary.py

```bash
uv run python app/skills/managing-shared-ledgers/scripts/query_space_summary.py
```

With specific space:
```bash
echo '{"space_id": "uuid-string"}' | uv run python app/skills/managing-shared-ledgers/scripts/query_space_summary.py
```

**Output**: Monthly totals, member breakdown, category distribution

**GenUI Component**: `SharedSpaceSummaryCard`

## Workflows

### List Spaces
1. Run `list_spaces.py`
2. Present available spaces with role indicators

### Space Summary
1. Identify target space (by name, or ask if ambiguous)
2. Run `query_space_summary.py` with space_id
3. Present SharedSpaceSummaryCard

## Rules

1. Only handle shared/collaborative context — not personal "I/me" queries
2. Always identify which space user means
3. Respect role-based permissions (owner vs member)
4. For transfers → executing-transfers skill
5. For recording → use `record_transactions` tool with space context
6. Execute scripts directly without `cd`, `&&`, or pipe operators
7. Run each script at most once per user request. If it fails, explain the error to the user.
