# Finvo Production Deployment Checklist

Minimal self-hosted production path (single node, Docker Compose). Read
alongside `server/.env.example` — every item below maps to a setting there.

## 1. Secrets (the server refuses to boot without these outside development)

| Variable | Rule |
|---|---|
| `JWT_SECRET_KEY` | Long random value (`python -c "import secrets; print(secrets.token_urlsafe(32))"`). Never the shipped placeholder. |
| `ENCRYPTION_KEY` | Same treatment (own guard in `app/utils/encryption.py`). |
| `POSTGRES_PASSWORD` | Explicit value; `postgres/postgres` is rejected at boot. |
| `REGISTRATION_OPEN` | Set `false` for public deployments unless you want open signup. |
| `SMS_PROVIDER` / `EMAIL_PROVIDER` | Real providers (`aliyun`/`twilio`, `smtp`). `mock` is refused at boot. |
| `METRICS_TOKEN` | Required when `ENABLE_METRICS=true`. |
| `GRAFANA_ADMIN_PASSWORD` | No server-side guard — set it in compose env. |

## 2. Topology constraints (do not "fix" these by scaling)

- **Single uvicorn worker** (`UVICORN_WORKERS=1`). The in-process scheduler,
  rate limiter and metrics assume one process; more workers duplicate
  scheduled transactions. Compose already pins this — keep it.
- **Redis is optional but load-bearing**: without it, token revocation
  degrades to not-revoked (ERROR-logged in production, red on `/health`).
  For a public instance, run the bundled Redis.

## 3. Backup & restore

- Nightly `pg_dump` of the Postgres volume (`postgres-data`). Test restores:
  an untested backup is a rumor.
- `server/storage/` and `server/artifacts/` hold uploads/attachments —
  snapshot alongside the DB or accept attachment orphans after a DB-only
  restore.

## 4. Updates

- Images are gated: `deploy.yml` refuses to build/push when Backend CI
  failed on that commit. Pull, `docker compose up -d`, then check
  `/health` (expects 200; 503 names the sick component).
- Migrations run via `alembic upgrade head` in CI; the app itself does not
  auto-migrate on boot. Apply the same command against the production DB
  before starting the new image.

## 5. Monitoring

- `docker compose --profile monitoring up -d` for Prometheus + Grafana.
- Watch `memory_extractions_total{result="disabled"}` (misconfigured
  memory provider) and the slowapi 429 rate on `/auth/*`.
- Voice is opt-in: `docker compose --profile voice up -d` (self-hosted
  ASR on host port 8081); without it the app uses on-device speech.
