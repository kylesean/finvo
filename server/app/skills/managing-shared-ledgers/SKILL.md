---
name: managing-shared-ledgers
description: >
  Manages shared ledgers for family/team collaborative tracking.
  USE WHEN: shared space spending, family bills, team expenses, space summary.
  NOT FOR: personal spending analysis (→ reviewing-finances), personal transfers (→ executing-transfers), budget creation (→ guide to app UI).

allowed-tools: "list_spaces query_space_summary search_transactions"
---

# Managing Shared Ledgers

Handle collaborative financial queries for shared spaces ("we/us" context).

## Tools

### list_spaces

Call the typed `list_spaces` tool (structured arguments — never via shell) to list the shared spaces the user belongs to.

**Result**: `spaces` (list with names and user roles).

### query_space_summary

Call the typed `query_space_summary` tool to get a shared space's current-month spending summary.

**Parameters**:
- `space_id`: Optional space ID; omit to summarize all the user's spaces

**Result**: per-space monthly totals, transaction counts (feeds the SharedSpaceSummaryCard).

## Workflows

### List Spaces
1. Call `list_spaces`
2. Present the available spaces with role indicators

### Space Summary
1. Identify the target space (by name, or ask if ambiguous)
2. Call `query_space_summary` with the `space_id`
3. Present the SharedSpaceSummaryCard

## Rules

1. Only handle shared/collaborative context — not personal "I/me" queries
2. Always identify which space the user means
3. Respect role-based permissions (owner vs member)
4. For transfers → executing-transfers skill
5. For recording → use `record_transactions` tool with space context
6. If a tool returns no spaces, explain that to the user
