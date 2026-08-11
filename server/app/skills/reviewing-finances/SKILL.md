---
name: reviewing-finances
description: >
  Analyzes past spending by category, income vs expense balance, and financial health scoring.
  USE WHEN: spending breakdown, category analysis, cashflow review, financial health score.
  NOT FOR: future forecast (→ forecasting-finances), budget creation (→ guide to app UI), budget status (→ query_budget_status tool).

allowed-tools: "analyze_spending analyze_cashflow search_transactions"
---

# Reviewing Finances

Analyze past spending patterns and assess financial health.

## Tools

### analyze_spending

Call the typed `analyze_spending` tool (structured arguments — never via shell) to get a past spending breakdown.

**Parameters**:
- `start_date` / `end_date`: Date range (YYYY-MM-DD). For "current month" queries use the 1st of the month as start and today as end.
- `days`: Fallback period if dates omitted (default: 90)
- `category`: Optional category key filter (e.g. "FOOD_DINING")

**Result**: structured category/month/trend breakdown feeding the BudgetAnalysisCard.

### analyze_cashflow

Call the typed `analyze_cashflow` tool to get income vs expense balance and financial health.

**Parameters**:
- `days`: Analysis period (default: 90)
- `start_date` / `end_date`: Optional date range

**Result**: `netCashFlow`, `savingsRate`, `healthScore` (0-100), `healthDimensions` feeding the CashFlowCard.

## Workflows

### Spending Analysis
1. Call `analyze_spending` with the appropriate date range
2. Present the category breakdown via GenUI
3. Highlight top categories and unusual patterns
4. Localize category keys to the user's language

### Financial Health
1. Call `analyze_cashflow`
2. Present the CashFlowCard
3. Interpret the health score (excellent/good/fair/poor)

## Rules

1. Focus on PAST & PRESENT only — no predictions
2. Always localize category keys to the user's language
3. Never mention technical details (tool names, schemas) to the user
4. Do NOT create budgets — guide the user to the app budget module
5. If the user asks both spending + health, call both tools
6. If a tool returns empty data, explain the situation to the user
