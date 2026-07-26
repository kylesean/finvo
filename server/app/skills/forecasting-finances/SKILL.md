---
name: forecasting-finances
description: >
  Predicts future balance and simulates purchase impact.
  USE WHEN: balance forecast, affordability check, "can I afford X", future projection.
  NOT FOR: past spending analysis (→ reviewing-finances), budget creation (→ guide to app UI), budget status query (→ query_budget_status tool).

allowed-tools: "execute search_transactions read_file"
---

# Forecasting Finances

Predict future financial situation and evaluate purchase affordability.

## Scripts

### forecast_balance.py

```bash
uv run python app/skills/forecasting-finances/scripts/forecast_balance.py --days 30
```

**Parameters**:
- `--days`: Forecast period (default: 30)
- `--simulate-purchase`: Enable purchase simulation
- `--amount`: Purchase amount for simulation
- `--description`: Purchase description

**Output**: `forecast` (daily balance series), `warnings` (low balance alerts), `recurring_events`

**GenUI Component**: `CashFlowForecastChart`

## Workflows

### Balance Forecast
1. Run `forecast_balance.py --days N`
2. Present CashFlowForecastChart
3. Highlight warning periods and key upcoming events

### Purchase Simulation
```bash
uv run python app/skills/forecasting-finances/scripts/forecast_balance.py --simulate-purchase --amount 5000 --description "iPhone"
```
1. Run with simulation parameters
2. Show before/after comparison
3. State clearly: AFFORDABLE or NOT RECOMMENDED

## Rules

1. Focus on FUTURE only — no past analysis
2. Always give clear yes/no on affordability
3. Highlight low balance warnings prominently
4. Do NOT create budgets — guide user to app budget module
5. Execute scripts directly without `cd`, `&&`, or pipe operators
