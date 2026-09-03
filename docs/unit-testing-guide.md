# 单测指导方案（Unit Testing Guide）

> 英文版见 [`unit-testing-guide_EN.md`](./unit-testing-guide_EN.md)。中英不一致时以中文版为准，直至重新对齐。

> 适用：Finvo `server/`（FastAPI + LangGraph + PostgreSQL）与 `client/`（Flutter + Riverpod + GenUI/A2UI）。
> 依据：用 CodeGraph 对全仓（860 文件）审查后的分层现实制定；与当前 `tests/`、`test/` 落子严格对齐。
> 目标：一句话原则 —— **后端测“算得对”，前端测“显示对”，契约测“对得上”。不重复测同一业务。**

---

## 1. 核心原则（业内最佳实践子集，强制）

1. **测试金字塔**：目标分布单测（70%）> 集成/API 测试（20%）> E2E（10%）。本仓现状是 unit 25 + integration 7（`server/tests/`）与 72 Dart 单测，无独立 E2E 目录——保持现有比例，暂不补 E2E。
2. **单一真相源（SSOT）**：金额、账本、预算、权限、汇率、时区归因只在 `server/app/services/` 算。`client/` 不得重实现，只做格式化/展示/校验。
3. **单测定义**：FIRST（Fast / Isolated / Repeatable / Self-validating / Timely）+ AAA（Arrange-Act-Assert）+ 一个 `test_` 只断言一个行为。
4. **隔离性**：单测不碰真实网络、真实 LLM、真实时钟/随机数（注入或冻结）、不跨用例共享可变状态。
5. **回归优先于覆盖率**：每个线上 Bug 必须先补失败单测（参考 `parse_time` 的 `yestday` 回归），再修代码。

### 覆盖率门禁（全局地板 + 差异化目标）

CI 已强制全局地板（只升不降）：`server/.coverage-baseline`（当前 59%）经
`backend-ci.yml` 的 `--cov-fail-under` 卡，`client/.coverage-baseline`（当前 19%）
经 `client-ci.yml` 的 lcov awk 门禁卡。下表是方向性目标（尚未按目录强制执行，
不要当成已落地的门禁）：

| 层 | 目标 | 说明 |
|---|---|---|
| `server/app/services/`、`utils/currency_utils`、`core/langgraph/tools/_helpers` | ≥80%，核心账务路径 100% | 钱错了无法挽回 |
| `server/app/api/v1/` routers | 不追求行覆盖，追求契约覆盖 | 每个端点：200 + 401/404/422 + 业务 409 |
| `client/lib/shared/utils/`、`models.fromJson`、`genui/**/ _ViewModel.fromRawMap` | ≥80% | `AmountFormatter` 现有 65 处调用，必须锁死 |
| `client` widgets/pages | 只覆盖关键渲染与交互 | 不追求全面 widget 覆盖 |
| `.g.dart`、`i18n/*.g.dart`、第三方库 | 0%，显式排除 | 生成代码不测 |

---

## 2. Server（后端）规范

### 2.1 分层与目录映射（强制）

```
server/app/                  server/tests/
services/<domain>_service.py  <-> unit/services/test_<domain>_service.py
core/langgraph/tools/*.py     <-> unit/langgraph/test_tools.py、test_middleware.py、test_event_generator.py
core/*.py、utils/*.py         <-> unit/core/*.py、test_identicon.py、test_artifact_signing.py
api/v1/*.py                   <-> integration/test_*.py（只测契约，不测逻辑）
```

Router 保持薄（参考 `api/v1/budget.py`、`home.py`：参数校验 + 读检查 + 调 service + `success_response`）。
禁在 router 里做金额/`Decimal` 运算、SQL 组装、汇率/时区计算——这些必须下沉到 service 并补单测。
行数不卡（判重循环等读检查天然超 10 行），按职责卡。

### 2.2 必须测 / 禁止测

必须测：

* 金额精度（账本/余额/结算路径用 `Decimal`，禁止 `float` 累加；展示/LLM wire 边界允许 `float()`，
  必须加 `display-only` 注释——如 `amount_float` 属性、`budget_tools`/`analysis_tools` 的序列化）、
  多币种折算与不可兑换跳过（参考 `test_multi_currency_balance.py`）、系统交易排除（`test_statistics_system_tx_exclusion.py`）。
* 幂等（`test_transaction_idempotency.py`）、账本回滚韧性（`test_ledger_rollback_resilience.py`）、RRULE 校验（`recurring_service.validate_recurrence_rule`）、预算阈值告警、共享账本权限/结算（`test_shared_space_*`）。
* 安全边界：`artifact_signing`（token 绑定 user+path、过期、篡改、越权）、`filesystem_backend._resolve_path` 越权、`avatar` 私有附件不可枚举。范本见 `tests/unit/test_artifact_signing.py`、`test_identicon.py`。
* LLM/Agent 边界：`parse_time` 非法输入必须 loud fail（`ValueError` → tool 返回 `{"success": False, "error": "unparseable_time"}`），`StateValidator` 非法 `ClientStateMutation` 降级，`EventGenerator` 失败结果零发射。范本见 `unit/langgraph/`。
* 错误码一致性：`test_error_code_consistency.py` 常驻（含后端 `ERROR_CODE_MAP` 自洽 +
  前端 `error_codes.dart` int 子集对照），新增 `BusinessError` 必须同步双边。

禁止测：SQLAlchemy 本身、Pydantic 校验本身、LLM 生成文本内容（只测 tool schema 与分支）、真实 Postgres 方言之外的行为。

### 2.3 Fixture 与隔离（现状即标准）

DB fixture 按目录作用域 opt-in：`tests/db_fixtures.py` 定义共享的 Postgres
fixture，只有 `unit/services/conftest.py` 与 `integration/conftest.py` 重导出它们。
纯逻辑子目录拿不到 engine，天然零容器。root `tests/conftest.py` 只留廉价的
`setup_test_env`（env + mem0 mock）与 `setup_db_manager`（engine 引用重置）：

* `async_db_engine`（session 级，Postgres testcontainers；CI 用 `DATABASE_URL`，本地自动起 `postgres:16`）+ autouse `_clean_tables`（`TRUNCATE … CASCADE`）。DB 单测默认走“真提交 + truncate”隔离，不要自己手写 rollback。
* `db_session`：service 级单测入口。`client` / `client_with_auth` + `test_user`：API 契约测试入口（`dependency_overrides[get_current_user]`）。
* `setup_test_env`（autouse）：只全局 mock 了 `mem0.AsyncMemory.from_config`。LLM、Redis、外部 HTTP
  需要每个用例在边界显式 mock（`monkeypatch`/`pytest-mock`），禁止在单测里 `httpx` 打外网。

`pyproject.toml` 已定：`asyncio_mode = "auto"`、`asyncio_default_*_loop_scope = "session"`。异步测试直接写 `async def test_`，不要手写 `event_loop` fixture。跨事件循环复用 engine 是已知坑：`setup_db_manager` 每个 test 重置 `db_manager._engine`，不要删除。

### 2.4 命名与结构模板

文件名 `test_<被测模块>.py`，类 `Test<被测类>`，方法 `test_<场景>_<预期>`。纯函数用参数化，service 用类分组。

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

确定性要求：显式传入 `now` 或用 `monkeypatch` 冻结时钟；金额断言用 `Decimal("x")` 精确比较；涉及 `datetime` 必须带 `tzinfo=UTC`（参考 `TestParseTime`）。

### 2.5 反模式（本仓已发现，禁止新增）

* **骨架 skip 测试**：已清理（`TestBudgetTools` 三个 `Skeleton` skip 于 2026-09 删除，
  当前 `rg Skeleton server/tests` 为 0）。CI `backend-ci.yml` 的 `Forbid skeleton placeholder tests`
  常驻防止回归 —— 禁止提交 `pass` 占位测试。要么实现，要么删掉并建 issue。
* **静默 fallback**：`parse_time` 曾把 `"yestday"` 记到今天且无报错。非法输入一律 loud fail + 结构化错误码，禁止 `try/except: return now()`。
* **在单测里起真实容器之外的外部依赖**：LLM key 用 `sk-test-key-for-unit-tests`，`JWT_SECRET_KEY`/`ENCRYPTION_KEY` 用 conftest 固定值，禁止读开发者本机 `server/.env`。
* **真 redis 计数/连接**：`cache_manager` 必须 mock（`TestLoginLockout` 的内存 fake 即范本）。真 redis 连接绑定创建时的 loop，会毒化后继 `TestClient` lifespan（跨 loop Future）；计数器还跨 pytest 进程累积（TRUNCATE 清不掉 redis），让 lockout 类用例变顺序敏感。

### 2.6 本地命令

```bash
cd server && uv run pytest tests/unit -q
cd server && uv run pytest tests/integration -q
# 与 CI 同口径的覆盖率门禁（地板值见 server/.coverage-baseline，只升不降）：
cd server && uv run pytest tests/ --cov=app --cov-report=term-missing --cov-fail-under="$(cat .coverage-baseline)" -q
cd server && ./manage.sh lint   # ruff + mypy(strict) + bandit
```

---

## 3. Client（前端）规范

### 3.1 分层与目录映射（强制）

`test/` 镜像 `lib/`，一对一：

```
lib/shared/utils/amount_formatter.dart        <-> test/shared/utils/amount_formatter_test.dart
lib/features/budget/models/budget_models.dart <-> test/features/budget/models/budget_models_test.dart
lib/features/auth/services/auth_service.dart  <-> test/features/auth/services/auth_service_test.dart
lib/features/report/services/statistics_service.dart <-> test/features/report/services/statistics_service_test.dart
lib/features/chat/genui/templates/*.dart     <-> test/features/chat/genui/*_test.dart
```

范本：`test/shared/utils/amount_formatter_test.dart`（`Intl.defaultLocale` 锁定、`group` 按方法分组、边界 + 回归守卫）。新 utils 照抄此结构。

### 3.2 必须测 / 禁止测

必须测：

1. **纯展示函数**：`AmountFormatter`（符号/币种/千分位/`万/亿` vs `K/M/B`、繁简中文、未知币种回退 code）、`DateTimeUtils`、`HeatColors`、`formatFileSize`。无 Widget 依赖，跑 `flutter test` 最快。
2. **Model/ViewModel 容错解析**：所有 `fromJson`/`fromRawMap` 必须测缺字段/类型错位（String 数字、`null`、`bool`）不崩溃。统一走 `AmountFormatter.parseDecimalFromJson` + `MapExtensions.getString/getList/getDouble`（参考 `CashFlowForecastViewModel.fromRawMap`、`BudgetPeriodDetail.fromJson`）。每个 GenUI template 的 ViewModel 至少 3 个用例：正常、缺字段、脏数据。ViewModel 必须公开（不可 `private _...`，否则单测无法直测）。
3. **Service 薄层**：`AuthService`、`StatisticsService`、`RecurringTransactionService` 只测 query 组装（`_baseQuery` 的 `time_range`/`tz_offset`/`yyyy-MM-dd`）与 `ResponseParser` 分发。`NetworkClient` 必须 mock，禁止真实 `dio`。
4. **关键 Widget/交互**：GenUI catalog 映射（未知 `component` 不白屏）、表单校验、预算进度、空态/错误态。用 `testWidgets` + `pump`，断言文本与关键 `Key`。

禁止测：`*.g.dart` 生成代码、`Currency` 枚举表本身、第三方 `genui`/`forui`/`fl_chart` 渲染细节、真实 `SharedPreferences`/`FlutterSecureStorage`（用 fake/memory 实现）、真实网络与 SSE。

### 3.3 Mock 与状态管理

* 网络：mock `NetworkClient.request/requestMap`，返回 `ResponseParser` 能消费的 envelope；只断言 service 传对了 path/query/body。
* 存储：`AuthService` 的 `_storageService` 用内存 fake；断言 fail-closed（Keychain 失败即抛，不落盘明文）。
* Riverpod：用 `ProviderContainer` + `overrideWithValue`（参考 `statisticsService` 的 `_FakeStatisticsService` 模式），不启动整个 App。
* 本地化：凡涉及 `NumberFormat`/`t.budget.*` 的测试，首行锁定 `Intl.defaultLocale`（`zh_CN` + `en_US` 各跑一遍边界）。

模板：

```dart
group('BudgetPeriodDetail.fromJson', () {
  test('tolerates missing and malformed amounts', () {
    final m = BudgetPeriodDetail.fromJson({'id': '1', 'budget_id': 'b', 'spent_amount': 'abc'});
    expect(m.spentAmount, Decimal.zero);
    expect(m.remainingAmount, m.adjustedTarget);
  });
});
```

### 3.4 本地命令

```bash
cd client && flutter test
cd client && flutter analyze
```

> 注：带 `@GenerateMocks` 的测试会产出 `.mocks.dart`，`build_runner`/`slang` 产物已入库。
> 改了 mock 源文件或 i18n 后必须重新生成并提交产物（CI 会校验，见 §7 FAQ），否则测试与 mock 静默漂移。

---

## 4. 前后端分工与契约（CS 架构核心）

|  concern  | 后端 | 前端 |
|---|---|---|
| 金额计算/汇总/折算 | 唯一真相，`Decimal`，单测锁死 | 只格式化展示，`double` 仅出现在显示边界 |
| 预算是否超支/告警 | service 判定 | 只按 `status` 变色 |
| 时间归因 | 服务端按 `tz_offset` 落本地自然日（`home/calendar-month-details`、`statistics/*`） | 只负责传 `tz_offset` + `yyyy-MM-dd`（`StatisticsService._baseQuery/_formatDateParam`），单测锁死格式 |
| 错误 | 统一 `success_response` + `BusinessError` code | `ResponseParser` + `error_interceptor` 映射文案，不解析堆栈 |

新增/修改 API 必须同步：`server` schemas + `client` models + 双边单测 + 本节表格（如涉及时区/金额/错误码）。

---

## 5. PR 自检清单

* [ ] 新 service 逻辑有 `unit/services` 单测；新 util/model/ViewModel 有 Dart 单测；回归 Bug 有失败先行的用例。
* [ ] 无 `@pytest.mark.skip` 占位、无 `pass` 测试、无真实网络/LLM 调用、无硬编码本地路径。
* [ ] 金额用 `Decimal`（py）/ `parseDecimalFromJson`（dart）；时间带时区；`flutter analyze` + `manage.sh lint` 通过。
* [ ] API 变更同步契约：前后端单测同时更新。

## 6. 现状差距（下一步）

1. [x] ~~`test_tools.py` 中的三个 skeleton skip~~ —— 已删除，CI 门禁常驻（2026-09）。
2. 给所有 `genui/templates/*ViewModel.fromRawMap` 补“缺字段/脏数据”三件套用例（`CashFlowForecastViewModel` 已做范本，其余 ~20 个 templates 待补）。
3. [x] ~~`StatisticsService._baseQuery`（`tz_offset`、`yyyy-MM-dd`）显式 Dart 单测~~ —— 已补
   `_baseQuery contract` group（2026-09），后继改动必须保持 `tz_offset` 存在 + int 可解析。

---

## 7. FAQ（排障）

1. **`pytest` 报 `permission denied ... docker.sock`？**
   当前用户不在 `docker` 组（testcontainers 需要连 daemon）。
   `sudo usermod -aG docker <you>` 后重新登录；陈旧 shell 里可用
   `newgrp docker -c '<cmd>'` 免重登。
2. **纯逻辑单测也要起 Postgres 容器？**
   不用（2026-09 起）：DB fixture 只对 `unit/services/` 与 `integration/`
   可见（目录作用域 opt-in），纯逻辑子目录根本拿不到 engine。
   `pytest tests/unit/langgraph tests/unit/core` 无 docker 也能秒级跑完。
   只有跑 DB 单测才需要 docker 权限（见上一条）。
3. **覆盖率地板怎么升？**
   只许手涨：本地跑 CI 同口径覆盖率命令，在 `main` 上确认新数字后，
   再改 `server/.coverage-baseline` / `client/.coverage-baseline`
   （单个数字 = 地板 %）。禁止为了让 CI 变绿而下调。
4. **CI 说生成文件过期？**
   改了 mock 源文件 / model / i18n 但没重新生成：
   `dart run build_runner build --delete-conflicting-outputs && dart run slang`，
   然后把 `lib/` / `test/` 下的产物 diff 一并提交。
