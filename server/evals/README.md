# Evals — LLM quality harness

LLM-as-judge evaluation over recent Langfuse traces. This is an operational
quality *monitor*, not a CI gate.

## What it does

- Pulls traces from the last 24h (`evals/evaluator.py`) and scores them with
  5 generic judge metrics (conciseness / hallucination / helpfulness /
  relevancy / toxicity, prompts under `evals/metrics/prompts/`).
- Prints per-metric averages and a "Success Rate" — the share of metrics that
  produced a score, NOT an agent quality score.

## Run

```bash
cd server
uv run python -m evals.main          # requires Langfuse creds in server/.env
```

## Known gaps (before you trust the numbers)

- No golden set for the core booking chain: amount/category/direction
  extraction accuracy and intent-routing correctness have no regression
  signal — only generic judge metrics on live traces.
- Requires Langfuse configured; without traces in the window the run is empty.

## Entry points

- `evals/main.py` — CLI entry
- `evals/evaluator.py` — trace fetch + judge orchestration
- `evals/schemas.py` — result models
- `evals/helpers.py` — Langfuse client wiring
