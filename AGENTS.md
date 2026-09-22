# AGENTS.md — Testing & Verification Standard

## 1. Universal Verification Invariants

- **No Post-Hoc Tests**: Never write tests after production code. Tests written after-the-fact only mirror the implementation.
- **Failure-First Specification**: Before implementing complex or branching logic, enumerate edge cases and failure modes directly as FAILING test assertions (RED). Production code exists only to satisfy these checks (GREEN).
- **E2E as Ground Truth**: Do not rely solely on unit tests with heavy mocking. Every feature must culminate in an end-to-end verification step that produces a verifiable, repeatable artifact (file, persistent DB state, or serialized response).
- **Unit Tests for Dense Logic Only**: Use isolated tests exclusively for pure computation, data transformation, and edge-case error branches that are prohibitively slow or flaky to orchestrate in E2E.
- **Zero Bargaining**: Never relax an assertion, widen tolerances, or raise timeouts to resolve a failure. If a test is genuinely flawed or contradictory, output `[HALT_TEST_CONTRADICTION: <path> — <rationale>]` and halt immediately.

## 2. Project Harness & Execution

- **Fast Inner-Loop (< 5s)**: `<FAST_TEST_CMD>`
- **Final E2E Verification**: `<E2E_TEST_CMD>`
- **Expected Artifact**: `<ARTIFACT_TYPE>`
