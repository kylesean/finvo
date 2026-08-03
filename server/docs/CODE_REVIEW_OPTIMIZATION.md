# CODE REVIEW OPTIMIZATION — Known Debt Ledger

This file is the living ledger for known technical debt tracked across the
codebase. Items referenced from code comments and CI must be kept in sync
with this file.

## P0 — Fixed (2026-08)

- **alembic/env.py used an empty `SQLModel.metadata`** (models are SQLAlchemy
  2.0 `DeclarativeBase`, not SQLModel). This made `alembic check` report every
  table as "removed" and `alembic revision --autogenerate` produce destructive
  drop-everything migrations. Fixed: `target_metadata = Base.metadata` from
  `app.models.base`. Re-run `alembic check` to validate future changes.

## P1 — Schema drift between ORM models and migration scripts

`alembic check` (against a freshly migrated database) reports real
model-vs-migration drift. Categories:

1. **Removed table `ai_feedback_memory`** — exists in migrations but no longer
   in `app.models` (memory features migrated to a new model). A reconciliation
   migration must decide drop-vs-keep (data-preserving rename/review needed).
2. **Removed columns** — `created_at`/`updated_at` on `budget_periods`,
   `budget_settings`, `space_members`, `space_transactions`,
   `transaction_shares`; `financial_settings.created_at`. Models dropped them
   without a follow-up migration.
3. **Type changes** — `TEXT() → String()` on `transactions.raw_input`,
   `transactions.description`, `transaction_comments.comment_text`,
   `shared_spaces.description`, `recurring_transactions.description`,
   `notifications.content`, `budget_periods.notes`; `BIGINT() → Integer()` on
   `attachments.size`; `TEXT() → UUID()` on `attachments.thread_id`;
   `users.email` 255→100, `users.timezone` 50→100.
4. **Index/constraint changes** — unique indexes added on `users.uuid/email/
   mobile`; `ix_transactions_recurring_id` renamed to
   `ix_transactions_recurring_transaction_id`; unique constraints added on
   `space_transactions(space_id, transaction_id)` and
   `transactions(recurring_transaction_id, transaction_at)`; `user_settings`
   unique + FK drift.
5. **Nullable drift** — `updated_at` is NOT NULL in migrations but nullable in
   models for ~10 tables; `attachments.meta_info` nullable mismatch.

Noise to suppress when autogenerating (not real drift):
- `modify_default` on most columns (migrations use `server_default=text(...)`,
  models use Python-side defaults — align convention or use
  `compare_server_default=False`).
- SERIAL sequence detection on integer PKs.

**Action**: author a single reconciliation migration (0017+) with hand-picked
operations for items 1-5 after product review (drop/keep `ai_feedback_memory`,
timestamp columns). Enable hard failure of the CI `alembic check` step after
reconciliation lands.

## P1 — JWT revocation

- jti-based revocation blacklist implemented (Redis, TTL-bounded to token
  expiry) — `app/core/dependencies.py`. Residual item: verify blacklist
  behavior when Redis is down (degrade-open is documented and accepted).
- Tracked as P1/M7. No code change pending.

## P2 — Test strategy

- Unit tests run on SQLite (conftest forces `sqlite+aiosqlite:///:memory:`);
  `SELECT ... FOR UPDATE` row locks are silently no-op'd there, so ledger
  concurrency is untested. CI provisions a Postgres service but pytest does not
  use it. Plan: honor an injected `DATABASE_URL` (testcontainers or the CI
  Postgres service) for ledger/transaction tests; keep SQLite for pure unit
  tests.
