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
- `start_date` / `end_date`: Date range (YYYY-MM-DD). ALWAYS pass explicit dates for this-week / this-month queries — never rely on the `days` fallback.
- `days`: Fallback period ONLY when the user says "last N days" without a calendar anchor (default: 90)
- `category`: Optional category key filter (e.g. "FOOD_DINING")

### This Week — calendar week, NOT rolling 7 days

1. Read `Current date: YYYY-MM-DD (Weekday) [timezone]` from Dynamic Context — it is already in the user's timezone.
2. `start_date` = Monday of that week (weekday() Monday=0: `monday = today - timedelta(days=today.weekday())`), `end_date` = today. A Monday query is a 1-day window; a Sunday query is 7 days.
3. Example: today is 2026-09-13 (Sunday) → `start_date="2026-09-07"`, `end_date="2026-09-13"`.
4. Do NOT use `days=7` as a substitute — it means rolling 7 days and misattributes cross-week spending.
5. Do NOT use `search_transactions` for week analysis — it returns a raw list (rolling 7-day default, max 50/page, no percentages/trends) and its card cannot render a breakdown.
6. The tool compares against the previous equal-length period automatically and returns `trends.week_over_week` — surface its direction in your summary.

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
