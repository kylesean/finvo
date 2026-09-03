# Unit Testing Guide

> English version. 中文版见 [`unit-testing-guide.md`](./unit-testing-guide.md).
> If the two diverge, the Chinese version wins until they are re-synced.

> Scope: Finvo `server/` (FastAPI + LangGraph + PostgreSQL) and `client/`
> (Flutter + Riverpod + GenUI/A2UI).
> Basis: written from the layered reality found by a CodeGraph review of the
> whole repo (860 files); aligned with the current `tests/` and `test/` layout.
> Goal in one sentence —— **backend tests prove "computed right", frontend
> tests prove "rendered right", contract tests prove "they match". Never test
> the same business logic twice.**

---

## 1. Core principles (mandatory subset of industry best practice)

1. **Test pyramid**: target unit (70%) > integration/API (20%) > E2E (10%).
   Current state is 25 unit + 7 integration (`server/tests/`) plus 72 Dart unit
   tests, with no standalone E2E directory —— keep the current ratio, no E2E
   for now.
2. **Single source of truth (SSOT)**: amounts, ledger, budgets, permissions,
   exchange rates, and timezone attribution are computed only in
   `server/app/services/`. `client/` must not reimplement them —— formatting,
   display, and validation only.
3. **Unit-test definition**: FIRST (Fast / Isolated / Repeatable /
   Self-validating / Timely) + AAA (Arrange-Act-Assert) + one `test_` asserts
   exactly one behavior.
4. **Isolation**: unit tests touch no real network, no real LLM, no real
   clock/randomness (inject or freeze it), and share no mutable state across
   cases.
5. **Regression over coverage**: every production bug gets a failing unit test
   first (see the `parse_time` `yestday` regression), then the fix.

### Coverage gates (global floor + directional targets)

CI already enforces a global floor (raise-only): `server/.coverage-baseline`
(currently 59%) via `--cov-fail-under` in `backend-ci.yml`, and
`client/.coverage-baseline` (currently 19%) via the lcov awk gate in
`client-ci.yml`. The table below lists directional targets (NOT yet enforced
per directory —— do not treat them as landed gates):

| Layer | Target | Rationale |
|---|---|---|
| `server/app/services/`, `utils/currency_utils`, `core/langgraph/tools/_helpers` | ≥80%, 100% on core money paths | Money mistakes are irreversible |
| `server/app/api/v1/` routers | Contract coverage, not line coverage | Per endpoint: 200 + 401/404/422 + business 409 |
| `client/lib/shared/utils/`, `models.fromJson`, `genui/**/ ViewModel.fromRawMap` | ≥80% | `AmountFormatter` has 65 call sites —— lock it down |
| `client` widgets/pages | Key rendering and interaction only | No full widget coverage |
| `.g.dart`, `i18n/*.g.dart`, third-party libs | 0%, explicitly excluded | Never test generated code |

---

## 2. Server (backend) rules

### 2.1 Layer-to-directory mapping (mandatory)

```
server/app/                  server/tests/
services/<domain>_service.py  <-> unit/services/test_<domain>_service.py
core/langgraph/tools/*.py     <-> unit/langgraph/test_tools.py, test_middleware.py, test_event_generator.py
core/*.py, utils/*.py         <-> unit/core/*.py, test_identicon.py, test_artifact_signing.py
api/v1/*.py                   <-> integration/test_*.py (contracts only, no logic)
```

Keep routers thin (see `api/v1/budget.py`, `home.py`: validate params + read
checks + call service + `success_response`).
No amount/`Decimal` math, SQL assembly, or exchange-rate/timezone computation
in routers —— that belongs in services with unit tests.
Line count is not gated (read-check loops naturally exceed 10 lines); gate on
responsibility instead.

### 2.2 Must test / must not test

Must test:

* Amount precision (`Decimal` on ledger/balance/settlement paths, no `float`
  accumulation; `float()` is allowed at display/LLM-wire boundaries with a
  mandatory `display-only` comment —— e.g. `amount_float` properties,
  `budget_tools`/`analysis_tools` serialization), multi-currency conversion
  with unconvertible-skip (see `test_multi_currency_balance.py`), system-tx
  exclusion (see `test_statistics_system_tx_exclusion.py`).
* Idempotency (`test_transaction_idempotency.py`), ledger rollback resilience
  (`test_ledger_rollback_resilience.py`), RRULE validation
  (`recurring_service.validate_recurrence_rule`), budget threshold alerts,
  shared-ledger permissions/settlement (`test_shared_space_*`).
* Security boundaries: `artifact_signing` (token bound to user+path, expiry,
  tampering, cross-user), `filesystem_backend._resolve_path` traversal,
  `avatar` private attachments not enumerable. Models:
  `tests/unit/test_artifact_signing.py`, `test_identicon.py`.
* LLM/Agent boundaries: `parse_time` illegal input must fail loud
  (`ValueError` → tool returns `{"success": False, "error": "unparseable_time"}`),
  `StateValidator` degrades illegal `ClientStateMutation`,
  `EventGenerator` emits zero component events on failure. Models:
  `unit/langgraph/`.
* Error-code consistency: `test_error_code_consistency.py` is permanent
  (backend `ERROR_CODE_MAP` self-consistency + frontend `error_codes.dart`
  int-subset cross-check). New `BusinessError`s must sync both sides.

Must not test: SQLAlchemy itself, Pydantic validation itself, LLM-generated
prose (test tool schemas and branches only), behavior outside real Postgres
dialect.

### 2.3 Fixtures and isolation (current state is the standard)

DB fixtures are opt-in by directory scope: `tests/db_fixtures.py` defines the
shared Postgres fixtures, and only `unit/services/conftest.py` and
`integration/conftest.py` re-export them. Pure-logic subtrees cannot see the
engine, so zero containers start there. Root `tests/conftest.py` keeps only
the cheap `setup_test_env` (env + mem0 mock) and `setup_db_manager` (engine
reference reset):

* `async_db_engine` (session-scoped, Postgres testcontainers; CI uses
  `DATABASE_URL`, local runs auto-start `postgres:16`) + autouse
  `_clean_tables` (`TRUNCATE … CASCADE`). DB tests isolate via
  real commits + truncate by default; never hand-roll rollback.
* `db_session`: entry point for service-level tests. `client` /
  `client_with_auth` + `test_user`: entry point for API contract tests
  (`dependency_overrides[get_current_user]`).
* `setup_test_env` (autouse): globally mocks only
  `mem0.AsyncMemory.from_config`. LLM, Redis, and external HTTP must be mocked
  explicitly per case at the boundary (`monkeypatch`/`pytest-mock`); no real
  `httpx` calls to the outside world in unit tests.

`pyproject.toml` is settled: `asyncio_mode = "auto"`,
`asyncio_default_*_loop_scope = "session"`. Write async tests as plain
`async def test_`; never hand-roll an `event_loop` fixture. Known pitfall is
engine reuse across event loops: `setup_db_manager` resets
`db_manager._engine` per test —— do not delete it.

> Note: DB fixtures are visible only in `unit/services/` and `integration/`
> (directory-scoped opt-in), so pure-logic tests never start a container.
> Only DB tests pay the container cost —— see §7 FAQ.

### 2.4 Naming and structure templates

File `test_<module>.py`, class `Test<ClassUnderTest>`, method
`test_<scenario>_<expectation>`. Parametrize pure functions, group services by
class.

```python
class TestBudgetRebalance:
    async def test_rebalance_insufficient_funds_returns_error(self, db_session) -> None:
        # Arrange
        service = BudgetService(db_session)
        ...
        # Act
        code = await service.rebalance_with_status(from_id, to_id, amount, user_uuid)
        # Assert
        assert code == "INSUFFICIENT_FUNDS"

    @pytest.mark.parametrize(("prev", "current", "expected"), [
        (Decimal("0"), Decimal("0"), 0.0),
        (Decimal("0"), Decimal("100"), 100.0),
    ])
    def test_calc_change_percent_boundary(self, prev, current, expected) -> None:
        assert StatisticsService._calc_change_percent(prev, current) == expected
```

Determinism: pass `now` in explicitly or freeze the clock via `monkeypatch`;
assert amounts with exact `Decimal("x")` comparisons; any `datetime` involved
must carry `tzinfo=UTC` (see `TestParseTime`).

### 2.5 Anti-patterns (found in this repo —— no new ones)

* **Skeleton skipped tests**: cleaned up (three `Skeleton` skips in
  `TestBudgetTools` deleted 2026-09; `rg Skeleton server/tests` is 0 today).
  CI `backend-ci.yml` (`Forbid skeleton placeholder tests`) guards against
  regression —— no `pass` placeholder tests. Implement it, or delete it and
  file an issue.
* **Silent fallback**: `parse_time` used to book `"yestday"` as today with no
  error. Illegal input always fails loud with a structured error code; no
  `try/except: return now()`.
* **Real external deps beyond containers in unit tests**: LLM key uses
  `sk-test-key-for-unit-tests`, `JWT_SECRET_KEY`/`ENCRYPTION_KEY` use the
  conftest-pinned values; never read the developer's local `server/.env`.
* **Real Redis counters/connections**: `cache_manager` must be mocked (the
  in-memory fake in `TestLoginLockout` is the model). Real Redis connections
  bind to their creating loop and poison later `TestClient` lifespans with
  cross-loop Future errors; counters also accumulate across pytest processes
  (TRUNCATE never clears Redis), turning lockout tests order-dependent.

### 2.6 Local commands

```bash
cd server && uv run pytest tests/unit -q
cd server && uv run pytest tests/integration -q
# Same coverage gate as CI (floor lives in server/.coverage-baseline, raise-only):
cd server && uv run pytest tests/ --cov=app --cov-report=term-missing --cov-fail-under="$(cat .coverage-baseline)" -q
cd server && ./manage.sh lint   # ruff + mypy(strict) + bandit
```

---

## 3. Client (frontend) rules

### 3.1 Layer-to-directory mapping (mandatory)

`test/` mirrors `lib/`, one to one:

```
lib/shared/utils/amount_formatter.dart        <-> test/shared/utils/amount_formatter_test.dart
lib/features/budget/models/budget_models.dart <-> test/features/budget/models/budget_models_test.dart
lib/features/auth/services/auth_service.dart  <-> test/features/auth/services/auth_service_test.dart
lib/features/report/services/statistics_service.dart <-> test/features/report/services/statistics_service_test.dart
lib/features/chat/genui/templates/*.dart     <-> test/features/chat/genui/*_test.dart
```

Model: `test/shared/utils/amount_formatter_test.dart` (locks
`Intl.defaultLocale`, `group`s per method, boundary + regression guards). Copy
its structure for new utils.

### 3.2 Must test / must not test

Must test:

1. **Pure display functions**: `AmountFormatter` (signs/currency/thousands /
   `万/亿` vs `K/M/B`, Traditional vs Simplified Chinese, unknown-currency
   fallback to code), `DateTimeUtils`, `HeatColors`, `formatFileSize`. No
   widget dependency —— the fastest `flutter test` runs.
2. **Model/ViewModel tolerant parsing**: every `fromJson`/`fromRawMap` must
   survive missing fields and type mismatches (numeric Strings, `null`,
   `bool`) without crashing. Go through
   `AmountFormatter.parseDecimalFromJson` +
   `MapExtensions.getString/getList/getDouble` (see
   `CashFlowForecastViewModel.fromRawMap`, `BudgetPeriodDetail.fromJson`).
   Each GenUI template ViewModel needs at least 3 cases: normal,
   missing-fields, malformed-data. ViewModels must be public (never `private
   _...`, or unit tests can't reach them).
3. **Thin service layer**: `AuthService`, `StatisticsService`,
   `RecurringTransactionService` —— test only query assembly (`_baseQuery`'s
   `time_range`/`tz_offset`/`yyyy-MM-dd`) and `ResponseParser` dispatch.
   `NetworkClient` must be mocked; no real `dio`.
4. **Key widgets/interactions**: GenUI catalog mapping (unknown `component`
   never renders blank), form validation, budget progress, empty/error states.
   `testWidgets` + `pump`, assert text and key `Key`s.

Must not test: `*.g.dart` generated code, the `Currency` enum table itself,
third-party `genui`/`forui`/`fl_chart` rendering internals, real
`SharedPreferences`/`FlutterSecureStorage` (use fake/memory implementations),
real network and SSE.

### 3.3 Mocks and state management

* Network: mock `NetworkClient.request/requestMap` to return envelopes that
  `ResponseParser` can consume; assert only that the service passed the right
  path/query/body.
* Storage: `AuthService`'s `_storageService` uses an in-memory fake; assert
  fail-closed (Keychain failure throws, never persists plaintext).
* Riverpod: `ProviderContainer` + `overrideWithValue` (see the
  `_FakeStatisticsService` pattern of `statisticsService`); never boot the
  whole app.
* Localization: any test touching `NumberFormat`/`t.budget.*` locks
  `Intl.defaultLocale` on the first line (cover boundary cases under both
  `zh_CN` and `en_US`).

Template:

```dart
group('BudgetPeriodDetail.fromJson', () {
  test('tolerates missing and malformed amounts', () {
    final m = BudgetPeriodDetail.fromJson({'id': '1', 'budget_id': 'b', 'spent_amount': 'abc'});
    expect(m.spentAmount, Decimal.zero);
    expect(m.remainingAmount, m.adjustedTarget);
  });
});
```

### 3.4 Local commands

```bash
cd client && flutter test
cd client && flutter analyze
```

> Note: tests using `@GenerateMocks` produce `.mocks.dart` files, and
> `build_runner`/`slang` outputs are committed. After editing a mock source or
> i18n file, regenerate and commit the outputs (CI verifies, see §7 FAQ) ——
> otherwise the test file and its mock drift apart silently.

---

## 4. Frontend-backend split and contracts (the core of this CS architecture)

| concern | backend | frontend |
|---|---|---|
| Amount math/rollup/conversion | Sole truth, `Decimal`, locked by unit tests | Display formatting only, `double` only at the display edge |
| Budget overrun/alerts | Decided by service | Only recolors by `status` |
| Time attribution | Server buckets into local calendar days by `tz_offset` (`home/calendar-month-details`, `statistics/*`) | Only sends `tz_offset` + `yyyy-MM-dd` (`StatisticsService._baseQuery/_formatDateParam`), format locked by unit tests |
| Errors | Unified `success_response` + `BusinessError` code | `ResponseParser` + `error_interceptor` map copy; never parse stack traces |

New/changed APIs must sync: `server` schemas + `client` models + both sides'
unit tests + this table (whenever timezones/amounts/error codes are involved).

---

## 5. PR self-checklist

* [ ] New service logic has `unit/services` unit tests; new utils/models/ViewModels have Dart unit tests; regression bugs have fail-first cases.
* [ ] No `@pytest.mark.skip` placeholders, no `pass` tests, no real network/LLM calls, no hardcoded local paths.
* [ ] Amounts use `Decimal` (py) / `parseDecimalFromJson` (dart); times carry timezones; `flutter analyze` + `manage.sh lint` pass.
* [ ] API changes sync the contract: frontend and backend unit tests updated together.

## 6. Known gaps (next steps)

1. [x] ~~Three skeleton skips in `test_tools.py`~~ —— deleted, CI gate permanent (2026-09).
2. Cover every `genui/templates/*ViewModel.fromRawMap` with the
   missing-fields/malformed-data trio (`CashFlowForecastViewModel` is the
   worked example; ~20 remaining templates to go).
3. [x] ~~Explicit Dart unit tests for `StatisticsService._baseQuery`
   (`tz_offset`, `yyyy-MM-dd`)~~ —— `_baseQuery contract` group added
   (2026-09); keep asserting `tz_offset` presence + int-parseability on every
   later change.

---

## 7. FAQ (troubleshooting)

1. **`pytest` fails with `permission denied ... docker.sock`?**
   Your user is not in the `docker` group (testcontainers needs the daemon).
   Fix once with `sudo usermod -aG docker <you>` and re-login; in a stale
   shell `newgrp docker -c '<cmd>'` works without re-login.
2. **Does a pure-logic test still start a Postgres container?**
   No (since 2026-09): DB fixtures are visible only to `unit/services/` and
   `integration/` (directory-scoped opt-in); pure-logic subtrees cannot even
   see the engine. `pytest tests/unit/core tests/unit/langgraph` finishes in
   seconds without docker. Only DB tests need docker access (see above).
3. **How do I raise the coverage baseline?**
   Only upward, by hand: run the CI coverage command locally, confirm the new
   number on `main`, then bump `server/.coverage-baseline` /
   `client/.coverage-baseline` (single number = floor %). Never lower it to
   make CI green.
4. **CI says generated files are out of date?**
   You edited a mock source / model / i18n file without regenerating:
   `dart run build_runner build --delete-conflicting-outputs && dart run slang`,
   then commit the resulting diffs under `lib/` / `test/`.
