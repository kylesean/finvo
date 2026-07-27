---
name: reviewing-finances
description: >
  Analyzes past spending by category, income vs expense balance, and financial health scoring.
  USE WHEN: spending breakdown, category analysis, cashflow review, financial health score.
  NOT FOR: future forecast (→ forecasting-finances), budget creation (→ guide to app UI), budget status (→ query_budget_status tool).

allowed-tools: "execute search_transactions read_file"
---

# Reviewing Finances

Analyze past spending patterns and assess financial health.

## Scripts

### analyze_spending.py

```bash
uv run python app/skills/reviewing-finances/scripts/analyze_spending.py --start-date YYYY-MM-01 --end-date YYYY-MM-DD
```

**Parameters**:
- `--start-date` / `--end-date`: Date range (YYYY-MM-DD)
- `--days`: Fallback period if dates omitted (default: 90)
- `--category`: Filter by category key (e.g. "FOOD_DINING")

**Note**: For "current month" queries, set start_date to 1st of current month and end_date to today.

### analyze_cashflow.py

```bash
uv run python app/skills/reviewing-finances/scripts/analyze_cashflow.py --days 90
```

**Parameters**:
- `--start-date` / `--end-date`: Date range
- `--days`: Analysis period (default: 90)

**Output**: `netCashFlow`, `savingsRate`, `healthScore` (0-100), `healthDimensions`

**GenUI Component**: `CashFlowCard`

## Workflows

### Spending Analysis
1. Run `analyze_spending.py` with appropriate date range
2. Present category breakdown via GenUI
3. Highlight top categories and unusual patterns
4. Localize category keys to user's language

### Financial Health
1. Run `analyze_cashflow.py`
2. Present CashFlowCard
3. Interpret health score (excellent/good/fair/poor)

## Rules

1. Focus on PAST & PRESENT only — no predictions
2. Always localize category keys to user's language
3. Never mention scripts or technical details to user
4. Do NOT create budgets — guide user to app budget module
5. Execute scripts directly without `cd`, `&&`, or pipe operators
6. If user asks both spending + health, run both scripts
7. Run each script at most once per user request. If it fails or returns empty data, explain the situation to the user.
