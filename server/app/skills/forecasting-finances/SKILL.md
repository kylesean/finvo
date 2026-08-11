---
name: forecasting-finances
description: >
  Predicts future balance and simulates purchase impact.
  USE WHEN: balance forecast, affordability check, "can I afford X", future projection.
  NOT FOR: past spending analysis (→ reviewing-finances), budget creation (→ guide to app UI), budget status query (→ query_budget_status tool).

allowed-tools: "forecast_balance search_transactions"
---

# Forecasting Finances

Predict future financial situation and evaluate purchase affordability.

## Tools

### forecast_balance

Call the typed `forecast_balance` tool (structured arguments — never via shell) to predict the future balance.

**Parameters**:
- `days`: Forecast period (default: 30)
- `simulate_purchase`: Enable purchase simulation
- `amount`: Purchase amount for simulation
- `description`: Purchase description

**Result**: `forecast` (daily balance series), `warnings` (low balance alerts), `recurring_events` feeding the CashFlowForecastChart.

## Workflows

### Balance Forecast
1. Call `forecast_balance` with the forecast period
2. Present the CashFlowForecastChart
3. Highlight warning periods and key upcoming events

### Purchase Simulation
1. Call `forecast_balance` with `simulate_purchase`, `amount` and `description`
2. Show the before/after comparison
3. State clearly: AFFORDABLE or NOT RECOMMENDED

## Rules

1. Focus on FUTURE only — no past analysis
2. Always give a clear yes/no on affordability
3. Highlight low balance warnings prominently
4. Do NOT create budgets — guide the user to the app budget module
5. If the result contains `"data_quality": "insufficient"`, inform the user that forecasting requires some financial data (accounts or transactions) and suggest they add some first
6. Call the tool at most once per user request
