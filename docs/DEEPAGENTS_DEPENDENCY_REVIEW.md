# DeepAgents 依赖评审与优化建议

> 文档创建日期: 2026-01-30
> 评审范围: `server/` 目录下的 LangGraph Agent 实现

## 1. 背景

本项目 (Augo) 是一个基于 **LangGraph + FastAPI** 的金融助手 Agent。当前在 `pyproject.toml` 中声明了 `deepagents>=0.3.0` 依赖。

本文档记录了对该依赖使用情况的深入评审，以及相应的优化建议。

---

## 2. DeepAgents 项目概述

[DeepAgents](https://github.com/langchain-ai/deepagents) 是 LangChain 团队开源的 **Agent Harness（智能体运行框架）**，设计灵感来自 Claude Code、Deep Research、Manus 等产品。

### 2.1 DeepAgents 的核心组件

| 组件 | 功能 | 模块路径 |
|------|------|---------|
| **TodoListMiddleware** | 任务规划 (write_todos / read_todos) | `langchain.agents.middleware` |
| **FilesystemMiddleware** | 虚拟文件系统 (ls, read_file, write_file, edit_file) | `deepagents.middleware.filesystem` |
| **SubAgentMiddleware** | 子智能体管理 (task tool) | `deepagents.middleware.subagents` |
| **SummarizationMiddleware** | 上下文压缩 | `deepagents.middleware.summarization` |
| **SkillsMiddleware** | 技能系统 (Anthropic Agent Skills 规范) | `deepagents.middleware.skills` |
| **MemoryMiddleware** | 长期记忆 | `deepagents.middleware.memory` |
| **FilesystemBackend** | 文件系统后端抽象 | `deepagents.backends.filesystem` |
| **StateBackend** | 状态后端 (LangGraph State 内存储) | `deepagents.backends.state` |

### 2.2 官方定位

> LangGraph 核心团队成员曾在多次讨论中提到，像 DeepAgents 这样高度封装的项目更多是作为 **Reference Implementation（参考实现）** 或 **Harness（运行支架）** 存在，目的是展示如何组合这些复杂的模式。对于具体的业务应用，社区更提倡从参考代码中"剪裁"（pluck）出你需要的模式。

参考资料:
- [Deep Agents - LangChain Blog](https://blog.langchain.com/deep-agents/) (2025-07-30)
- [DeepAgents Quickstart | LangChain Docs](https://python.langchain.com/docs/versions/v0_3/deepagents/)

---

## 3. 本项目使用情况分析

### 3.1 依赖使用矩阵

| DeepAgents 组件 | 本项目是否使用 | 使用方式 |
|----------------|---------------|---------|
| `FilesystemMiddleware` | ❌ 未使用 | - |
| `SubAgentMiddleware` | ❌ 未使用 | - |
| `SummarizationMiddleware` | ❌ 未使用 | - |
| `SkillsMiddleware` | ❌ 未使用 | 自研实现: `app/core/langgraph/middleware/skill.py` |
| `MemoryMiddleware` | ❌ 未使用 | 自研实现: `app/core/langgraph/middleware/memory.py` |
| `FilesystemBackend` | ✅ 使用 | `app/core/langgraph/tools/filesystem_tools.py` |
| `SandboxBackendProtocol` | ✅ 使用 (仅接口) | 自研实现 `execute()` 方法 |

### 3.2 实际使用的代码

唯一使用 `deepagents` 的文件是 `server/app/core/langgraph/tools/filesystem_tools.py`:

```python
from deepagents.backends.filesystem import FilesystemBackend
from deepagents.backends.protocol import ExecuteResponse
from deepagents.backends.sandbox import SandboxBackendProtocol

class LocalFilesystemBackend(FilesystemBackend, SandboxBackendProtocol):
    def execute(self, command: str) -> ExecuteResponse:
        # 自定义实现，使用 subprocess
        ...

fs_backend = LocalFilesystemBackend(root_dir=PROJECT_ROOT, virtual_mode=False)
```

**实际使用的功能**:
- `FilesystemBackend.read()` - 读取文件
- `FilesystemBackend.write()` - 写入文件
- `FilesystemBackend.ls_info()` - 列出目录
- `ExecuteResponse` - 命令执行结果数据类
- `SandboxBackendProtocol` - 仅作为类型注解

### 3.3 本项目的 Skills 实现

本项目已经 **完整自研** 了 Anthropic Agent Skills 规范的实现：

| 组件 | 文件路径 | 说明 |
|------|---------|------|
| SkillLoader | `app/core/skills/loader.py` | SKILL.md 解析器 |
| SkillMiddleware | `app/core/langgraph/middleware/skill.py` | 技能目录注入 |
| load_skill 工具 | `app/core/langgraph/tools/skill_tools.py` | 按需加载技能 |
| SKILL.md 文件 | `app/skills/*/SKILL.md` | 4 个业务技能定义 |

**实现评价**: ✅ 非常优秀，完全符合 Anthropic Agent Skills 规范

---

## 4. 问题诊断

### 4.1 依赖冗余

当前状态:
- 安装了完整的 `deepagents>=0.3.0` 包
- 只使用了其中 `backends/filesystem.py` 的约 3 个方法
- `deepagents` 会引入以下间接依赖:
  - `langchain-anthropic>=1.3.1`
  - `langchain-google-genai>=4.1.3`
  - `wcmatch`

### 4.2 潜在风险

1. **版本冲突**: `deepagents` 锁定的 langchain 版本可能与项目需求冲突
2. **依赖膨胀**: 引入了不需要的 Anthropic/Google GenAI SDK
3. **认知负担**: 其他开发者看到依赖可能误以为使用了完整功能

---

## 5. 优化建议

### 5.1 推荐方案: 移除 deepagents 依赖

**步骤 1**: 创建自研的简化版 FilesystemBackend

```python
# server/app/core/langgraph/tools/filesystem_backend.py

"""Minimal filesystem backend without deepagents dependency.

This is a simplified implementation that replaces deepagents.backends.filesystem
for our specific use case (read, write, ls, execute).
"""

from __future__ import annotations

import os
import subprocess  # nosec B404
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class FileInfo:
    """Information about a file or directory."""

    name: str
    is_dir: bool
    size: int | None = None


@dataclass
class ExecuteResponse:
    """Response from command execution."""

    output: str
    exit_code: int


class SimpleFilesystemBackend:
    """Minimal filesystem backend for Skills execution.

    Provides:
    - read(): Read file content
    - write(): Write file content
    - ls_info(): List directory contents
    - execute(): Execute shell commands

    Security:
    - Path traversal protection via _resolve_path()
    - Restricted to root_dir subtree
    """

    def __init__(self, root_dir: Path | str):
        """Initialize with root directory.

        Args:
            root_dir: Base directory for all operations
        """
        self.root_dir = Path(root_dir).resolve()
        self.cwd = self.root_dir  # For execute() working directory

    def _resolve_path(self, path: str) -> Path:
        """Safely resolve path within root_dir.

        Args:
            path: Relative or absolute path

        Returns:
            Resolved absolute path

        Raises:
            ValueError: If path would escape root_dir
        """
        # Handle absolute paths by making them relative to root
        if path.startswith("/"):
            path = path.lstrip("/")

        full_path = (self.root_dir / path).resolve()

        # Security: Ensure path is within root_dir
        if not str(full_path).startswith(str(self.root_dir)):
            raise ValueError(f"Path traversal not allowed: {path}")

        return full_path

    def read(self, path: str, offset: int = 0, limit: int | None = None) -> str:
        """Read file content.

        Args:
            path: File path relative to root_dir
            offset: Line offset (0-based)
            limit: Maximum lines to read (None for all)

        Returns:
            File content as string
        """
        file_path = self._resolve_path(path)

        if not file_path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        if file_path.is_dir():
            raise IsADirectoryError(f"Cannot read directory: {path}")

        content = file_path.read_text(encoding="utf-8")

        # Apply offset and limit if specified
        if offset > 0 or limit is not None:
            lines = content.splitlines(keepends=True)
            if offset > 0:
                lines = lines[offset:]
            if limit is not None:
                lines = lines[:limit]
            content = "".join(lines)

        return content

    def write(self, path: str, content: str) -> dict[str, Any]:
        """Write content to file.

        Args:
            path: File path relative to root_dir
            content: Content to write

        Returns:
            Dict with path and success status
        """
        file_path = self._resolve_path(path)

        # Create parent directories if needed
        file_path.parent.mkdir(parents=True, exist_ok=True)

        file_path.write_text(content, encoding="utf-8")

        return {"path": str(file_path.relative_to(self.root_dir)), "success": True}

    def ls_info(self, path: str = ".") -> list[FileInfo]:
        """List directory contents.

        Args:
            path: Directory path relative to root_dir

        Returns:
            List of FileInfo objects
        """
        dir_path = self._resolve_path(path)

        if not dir_path.exists():
            raise FileNotFoundError(f"Directory not found: {path}")

        if not dir_path.is_dir():
            raise NotADirectoryError(f"Not a directory: {path}")

        result = []
        for item in sorted(dir_path.iterdir(), key=lambda x: (not x.is_dir(), x.name)):
            try:
                size = item.stat().st_size if item.is_file() else None
                result.append(FileInfo(name=item.name, is_dir=item.is_dir(), size=size))
            except PermissionError:
                continue

        return result

    def execute(self, command: str, env: dict[str, str] | None = None) -> ExecuteResponse:
        """Execute a shell command.

        Args:
            command: Bash command to execute
            env: Optional environment variables to add

        Returns:
            ExecuteResponse with output and exit code
        """
        try:
            # Merge with current environment
            exec_env = os.environ.copy()
            if env:
                exec_env.update(env)

            result = subprocess.run(  # nosec B602 B607
                command,
                shell=True,
                cwd=self.cwd,
                env=exec_env,
                capture_output=True,
                text=True,
                timeout=30,
            )

            output = result.stdout
            if result.stderr:
                output += f"\nstderr:\n{result.stderr}"

            return ExecuteResponse(output=output, exit_code=result.returncode)

        except subprocess.TimeoutExpired:
            return ExecuteResponse(
                output="Error: Command execution timed out after 30 seconds",
                exit_code=124,
            )
        except Exception as e:
            return ExecuteResponse(output=f"Error executing command: {e!s}", exit_code=1)
```

**步骤 2**: 更新 `filesystem_tools.py`

```python
# 替换原有的 import
# from deepagents.backends.filesystem import FilesystemBackend
# from deepagents.backends.protocol import ExecuteResponse
# from deepagents.backends.sandbox import SandboxBackendProtocol

from app.core.langgraph.tools.filesystem_backend import (
    SimpleFilesystemBackend,
    ExecuteResponse,
    FileInfo,
)

# 替换 backend 实例化
# fs_backend = LocalFilesystemBackend(root_dir=PROJECT_ROOT, virtual_mode=False)
fs_backend = SimpleFilesystemBackend(root_dir=PROJECT_ROOT)
```

**步骤 3**: 移除 pyproject.toml 中的 deepagents 依赖

```diff
 dependencies = [
     ...
-    "deepagents>=0.3.0",
     ...
 ]
```

**步骤 4**: 运行测试确认功能正常

```bash
cd server
uv sync
uv run pytest tests/unit_tests/tools/
```

### 5.2 替代方案: 保留依赖但文档化

如果未来计划使用 DeepAgents 的其他功能（如 Sub-agents、Summarization），可以保留依赖，但建议:

1. 在 `pyproject.toml` 添加注释:
   ```toml
   dependencies = [
       # NOTE: Currently only using deepagents.backends.filesystem
       # Consider replacing with SimpleFilesystemBackend if not using other features
       "deepagents>=0.3.0",
   ]
   ```

2. 创建 ADR (Architecture Decision Record) 文档说明选择理由

---

## 6. Skills 实现优化建议

### 6.1 当前实现评价

| 检查项 | 状态 | 说明 |
|-------|------|------|
| SKILL.md 格式 | ✅ | YAML frontmatter + Markdown body |
| allowed-tools 格式 | ✅ | 空格分隔字符串 |
| Progressive Disclosure | ✅ | 只注入 name + description |
| load_skill 工具 | ✅ | 通过 Command 更新 state |
| SkillMiddleware | ✅ | before_invoke 注入技能目录 |

### 6.2 建议增强: allowed-tools 强制执行

当前 `SkillMiddleware.after_invoke` 只做日志记录。建议在此处增加 `allowed-tools` 约束的强制检查:

```python
# app/core/langgraph/middleware/skill.py

async def after_invoke(
    self,
    result: dict[str, Any],
    config: dict[str, Any],
) -> dict[str, Any]:
    """Check for skill activation and enforce tool constraints."""
    active_skill = result.get("active_skill")

    if not active_skill:
        return result

    # Get allowed tools for active skill
    allowed = self._allowed_tools_cache.get(active_skill)

    if allowed and "messages" in result:
        # Check last AI message for disallowed tool calls
        messages = result["messages"]
        for msg in reversed(messages):
            if hasattr(msg, "tool_calls") and msg.tool_calls:
                for tc in msg.tool_calls:
                    if tc.get("name") not in allowed:
                        logger.warning(
                            "skill_tool_constraint_violated",
                            skill=active_skill,
                            tool=tc.get("name"),
                            allowed=list(allowed),
                        )
                        # Option 1: Log warning only (current behavior)
                        # Option 2: Raise exception to block execution
                        # Option 3: Filter out disallowed tool calls

    return result
```

---

## 7. 后续行动清单

- [ ] 评估是否采用方案 5.1 (移除 deepagents 依赖)
- [ ] 如采用，创建 `app/core/langgraph/tools/filesystem_backend.py`
- [ ] 更新 `filesystem_tools.py` 使用新的 backend
- [ ] 移除 `pyproject.toml` 中的 deepagents 依赖
- [ ] 运行完整测试套件确认无回归
- [ ] (可选) 增强 SkillMiddleware 的 allowed-tools 约束执行

---

## 8. 参考资料

- [DeepAgents GitHub Repository](https://github.com/langchain-ai/deepagents)
- [Anthropic Agent Skills Specification](https://agentskills.io/specification)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Deep Agents Blog Post](https://blog.langchain.com/deep-agents/)

---

# 附录：深度技术解析

> 以下内容对 DeepAgents 核心组件进行源码级分析，并与本项目实现进行详细对比。

---

## 附录 A: FilesystemMiddleware 中间件详解

### A.1 FilesystemMiddleware 不仅仅是工具集合

`FilesystemMiddleware` 是一个完整的 LangGraph Middleware，提供以下功能：

| 功能层 | FilesystemMiddleware 提供的功能 | 本项目当前实现 |
|--------|-------------------------------|---------------|
| **工具注册** | 自动注册 7 个工具 (ls, read_file, write_file, edit_file, glob, grep, execute) | ✅ 手动注册 4 个工具 |
| **状态管理** | 通过 `FilesystemState` 将文件内容存储到 LangGraph 状态 (`files` 键) | ❌ 直接读写本地文件系统，无状态追踪 |
| **后端抽象** | 支持多种后端切换 (StateBackend, FilesystemBackend, SandboxBackend, CompositeBackend) | ⚠️ 只使用 FilesystemBackend |
| **大结果驱逐** | 自动将超大工具结果保存到文件系统，并返回摘要 + 文件路径 | ❌ 无此功能 |
| **系统提示词注入** | 自动注入 `## Filesystem Tools` 说明到系统提示词 | ❌ 手动写在系统提示词中 |
| **execute 工具条件启用** | 仅当后端实现 `SandboxBackendProtocol` 时才暴露 `execute` 工具 | ⚠️ 始终暴露 execute |

### A.2 核心设计：文件变更存储在 LangGraph State 中

```python
# DeepAgents 的方式：文件变更存储在 LangGraph State 中
class FilesystemState(AgentState):
    files: Annotated[NotRequired[dict[str, FileData]], _file_data_reducer]

# 当 write_file 执行后，返回 Command 更新状态
return Command(
    update={
        "files": res.files_update,  # 文件内容存入 state
        "messages": [ToolMessage(...)]
    }
)
```

**这意味着**：
- DeepAgents 可以使用 **虚拟文件系统**（`StateBackend`），文件只存在于会话状态中
- 会话结束后文件自动消失（临时工作空间）
- 或者通过 `StoreBackend` 将文件持久化到 LangGraph Store
- 可以利用 LangGraph 的 checkpointing 进行回滚

**本项目当前方式**：
- 所有文件直接写入本地文件系统
- 没有会话隔离（不同用户可能互相影响）
- 无法回滚（没有利用 LangGraph 的 checkpointing）

### A.3 大结果驱逐机制

当工具返回结果超过 token 阈值时，自动驱逐到文件系统：

```python
# FilesystemMiddleware 配置
tool_token_limit_before_evict: int | None = 20000  # 默认 20k tokens

# 驱逐后的消息格式
TOO_LARGE_TOOL_MSG = """Tool result too large, the result was saved at: {file_path}
You can read the result using read_file tool with offset and limit parameters.

Here is a preview showing the head and tail of the result:
{content_sample}
"""
```

---

## 附录 B: execute 实现对比

### B.1 结构对比

| 特性 | 本项目实现 | DeepAgents 官方 |
|------|-----------|----------------|
| **执行环境** | 本地 subprocess (同一机器) | 抽象的 Sandbox 后端 (Docker/Modal/Runloop/Daytona) |
| **安全隔离** | ❌ 无（直接在 host 执行） | ✅ 通过沙箱隔离 |
| **异步支持** | ❌ 仅同步 (subprocess.run) | ✅ 同步 + 异步 (execute / aexecute) |
| **输出截断** | 简单 JSON 解析 | 官方 truncation + 驱逐到文件 |
| **错误处理** | 基础 (try/except) | 详细的 exit code mapping |
| **环境注入** | ✅ USER_ID, LANG | 依赖沙箱配置 |

### B.2 官方 BaseSandbox 设计哲学

```python
class BaseSandbox(SandboxBackendProtocol, ABC):
    """所有方法都基于 execute() 实现"""

    @abstractmethod
    def execute(self, command: str) -> ExecuteResponse:
        """唯一需要子类实现的方法"""
        ...

    def read(self, file_path, offset, limit):
        """通过执行 python3 脚本读取文件"""
        cmd = _READ_COMMAND_TEMPLATE.format(...)
        return self.execute(cmd)

    def write(self, file_path, content):
        """通过执行 python3 脚本写入文件"""
        cmd = _WRITE_COMMAND_TEMPLATE.format(...)
        return self.execute(cmd)
```

**核心理念**：
- 只需实现一个 `execute()` 方法，就自动获得所有文件操作能力
- 所有操作都在**沙箱内部执行**，与宿主机隔离
- 可以用 Docker、Modal、Runloop 等替换执行环境，代码无需改动

### B.3 适用场景

| 场景 | 推荐方式 |
|------|---------|
| 受信任的内部环境 | 本项目方式 (直接 subprocess) |
| 快速原型开发 | 本项目方式 |
| 面向公众的 SaaS 产品 | 官方沙箱方式 |
| 需要资源限制 (CPU/内存/网络) | 官方沙箱方式 |
| 多租户隔离 (每个用户一个沙箱) | 官方沙箱方式 |

---

## 附录 C: Skills 实现对比

### C.1 详细功能对比

| 特性 | 本项目实现 (`app/core/skills/`) | DeepAgents 官方 (`middleware/skills.py`) |
|------|--------------------------------|----------------------------------------|
| **架构** | 独立 Middleware + Tool | LangGraph Middleware (with AgentState) |
| **技能发现** | 启动时一次性加载 | 每次 `before_agent` 重新扫描 |
| **技能存储** | 本地文件系统固定路径 | 可配置多个 sources + 后端抽象 |
| **优先级覆盖** | ❌ 无 | ✅ 后加载的 source 覆盖先前的同名技能 |
| **技能名验证** | ⚠️ 只提取 name，无格式验证 | ✅ 完整规范验证 (lowercase, 64 char, hyphen rule) |
| **描述长度限制** | ❌ 无 | ✅ 自动截断到 1024 字符 |
| **状态管理** | 通过 `skills_loaded` 状态键 | 通过 `skills_metadata` PrivateStateAttr |
| **加载方式** | `load_skill` 工具 (Command 返回) | `read_file` 读取 SKILL.md |
| **约束执行** | ⚠️ 只缓存，未强制过滤 | ⚠️ 未实现（官方也只是解析） |

### C.2 代码质量对比

**本项目 SkillLoader (179 行)**：

```python
def _parse_skill_md(self, file_path: str) -> SkillMetadata | None:
    # 简洁直接，但缺少规范验证
    if content.startswith("---"):
        parts = content.split("---", 2)
        data = yaml.safe_load(frontmatter_str)

        return SkillMetadata(
            name=data.get("name", "unknown"),  # 无验证
            description=data.get("description", ""),  # 无长度限制
            ...
        )
```

**官方 _parse_skill_metadata (90 行)**：

```python
def _parse_skill_metadata(...) -> SkillMetadata | None:
    # 严格的 Agent Skills 规范验证
    if len(content) > MAX_SKILL_FILE_SIZE:
        logger.warning("Skipping %s: content too large", ...)
        return None

    is_valid, error = _validate_skill_name(str(name), directory_name)
    if not is_valid:
        logger.warning("... does not follow Agent Skills specification: %s", error)

    if len(description_str) > MAX_SKILL_DESCRIPTION_LENGTH:
        description_str = description_str[:MAX_SKILL_DESCRIPTION_LENGTH]
```

### C.3 综合评价

| 维度 | 赢家 | 原因 |
|------|------|------|
| **规范合规性** | 官方 | 完整的 Agent Skills 规范验证 |
| **灵活性** | 官方 | 多 source + 后端抽象 + 优先级覆盖 |
| **可维护性** | 本项目 | 更简洁直接，易于理解 |
| **实用性** | **平局** | 官方功能更全，但本项目足够满足业务需求 |
| **性能** | 本项目 | 启动时加载一次 vs 每次请求重新扫描 |

**结论**：官方实现更 **"正确"**，但本项目实现更 **"务实"**。对于 4 个业务技能的场景，当前实现完全够用。

---

## 附录 D: 沙箱机制分析

### D.1 沙箱解决的核心问题

#### D.1.1 安全隔离

```
┌─────────────────────────────────────────────────────────────┐
│                     无沙箱场景 (当前方式)                     │
├─────────────────────────────────────────────────────────────┤
│  用户 A 输入: "rm -rf /"                                     │
│  → subprocess.run("rm -rf /", shell=True)                  │
│  → 💀 服务器死亡                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     有沙箱场景 (Docker/Modal)                 │
├─────────────────────────────────────────────────────────────┤
│  用户 A 输入: "rm -rf /"                                     │
│  → docker exec container_a bash -c "rm -rf /"              │
│  → 容器被清空（但主机安全）                                    │
│  → 重启容器，用户 A 重新开始                                  │
└─────────────────────────────────────────────────────────────┘
```

#### D.1.2 资源隔离

```python
# Modal Sandbox 示例配置
sandbox = modal.Sandbox.create(
    image=image,
    cpu=1.0,          # 限制 CPU
    memory=512,       # 限制内存 (MB)
    timeout=300,      # 最大执行时间
    network_file_systems={...},  # 隔离文件系统
)
```

#### D.1.3 多租户隔离

```
用户 A 的沙箱          用户 B 的沙箱
┌────────────┐       ┌────────────┐
│ /workspace │       │ /workspace │
│ ├── code/  │       │ ├── data/  │
│ └── data/  │       │ └── code/  │
└────────────┘       └────────────┘
    独立容器              独立容器
```

#### D.1.4 可审计性

```python
# 官方沙箱实现返回完整信息
@dataclass
class ExecuteResponse:
    output: str
    exit_code: int
    signal: int | None = None    # 被信号终止
    truncated: bool = False      # 输出被截断
```

### D.2 是否必须使用沙箱？

| 场景 | 是否需要沙箱 |
|------|------------|
| 内部工具 / B2B 产品，用户可信 | ❌ 不需要 |
| 面向公众的 AI Agent 产品 | ✅ 必须 |
| 执行用户提供的代码 | ✅ 必须 |
| 只执行预定义的脚本 | ⚠️ 可选（但推荐） |
| 开发/测试环境 | ❌ 不需要 |

### D.3 本项目的风险点

当前的 execute 实现：

```python
@tool("execute", args_schema=ExecuteInput)
def execute_tool(command: str) -> Any:
    response = fs_backend.execute(command)
    # ...
```

**潜在风险**：
1. 如果 LLM 被提示词注入，可能执行恶意命令
2. 如果 Skills 脚本有漏洞，可能被利用
3. 没有资源限制，恶意脚本可能 DOS 服务器

### D.4 务实的折中方案

对于当前 B2B 场景，以下安全加固措施可以在不引入完整沙箱的情况下提升安全性：

#### 方案 1: 命令白名单

```python
# 在 execute_tool 中添加
ALLOWED_COMMAND_PREFIXES = [
    "uv run python app/skills/",
    "python app/skills/",
]

def execute_tool(command: str) -> Any:
    if not any(command.startswith(prefix) for prefix in ALLOWED_COMMAND_PREFIXES):
        return {"error": "Command not allowed", "exit_code": 1}
    # ... 继续执行
```

#### 方案 2: 更严格的超时

```python
result = subprocess.run(
    command,
    timeout=10,  # 从 30 秒改为 10 秒
    ...
)
```

#### 方案 3: 资源限制 (Linux cgroups)

```python
import resource

def execute_with_limits(command: str):
    def set_limits():
        # 限制 CPU 时间
        resource.setrlimit(resource.RLIMIT_CPU, (10, 10))
        # 限制内存
        resource.setrlimit(resource.RLIMIT_AS, (256 * 1024 * 1024, 256 * 1024 * 1024))

    result = subprocess.run(
        command,
        preexec_fn=set_limits,
        ...
    )
```

---

## 附录 E: 总结对照表

| 问题 | 本项目现状 | DeepAgents 官方 | 建议 |
|------|-----------|----------------|------|
| **FilesystemMiddleware** | 仅使用 Backend 读写 | 完整状态集成 + 后端抽象 | 当前足够，无需改动 |
| **execute 实现** | 本地 subprocess 执行 | 沙箱隔离 + 多环境支持 | 添加命令白名单 |
| **Skills 实现** | 简洁务实 | 规范完整 | 当前足够，可选添加规范验证 |
| **沙箱机制** | 无 | 完整支持 | B2B 场景不必须，可选加固 |

---

## 附录 F: 决策树

```
你是否面向公众提供服务？
│
├── 是 → 必须使用沙箱 (Docker/Modal/等)
│
└── 否 (B2B/内部)
    │
    ├── 用户是否可以输入任意命令？
    │   │
    │   ├── 是 → 强烈建议使用沙箱
    │   │
    │   └── 否 (只执行预定义脚本)
    │       │
    │       ├── 添加命令白名单 ✓
    │       ├── 添加超时限制 ✓
    │       └── 当前实现可接受
    │
    └── 是否需要多租户隔离？
        │
        ├── 是 → 使用沙箱或 Docker
        │
        └── 否 → 当前实现可接受
```
