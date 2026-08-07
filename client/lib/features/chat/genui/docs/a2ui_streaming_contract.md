# 标准 A2UI v0.9 协议 SSE 流式 UI 后端契约指南 (A2UI v0.9 SSE Streaming Protocol Specification)

本指南旨在规范 Finvo AI 助手后端 (Python / LangChain / Agent Service) 在通过 SSE (Server-Sent Events) 输出动态生成式 UI 时需要遵循的标准 A2UI v0.9 协议契约与渐进式推送规范。

---

## 1. 核心交互理念 (3-Stage Progressive Streaming)

后端 Agent 在进行动态 UI 渲染时，**切勿等待所有计算与写库操作全部完成后再一次性输出打包 JSON**。为了向前端用户提供零延迟响应的流畅体验，后端必须采用 **三阶段渐进式推送**：

1. **Stage 1 (意图确定, ~0ms)**: 发送 `createSurface`。前端收到后立即渲染出与设计系统一致的 Shimmer 骨架屏占位卡片。
2. **Stage 2 (结构确定, ~200ms)**: 发送 `updateComponents`。前端将骨架屏平滑过渡为具体组装的控件节点（如 `TransactionSuccessCard`）。
3. **Stage 3 (数据完成/更新, ~500ms+)**: 发送 `updateDataModel` 或终态 `updateComponents`。实时填充最终交易金额、分类、时间戳与状态。

---

## 2. SSE 事件数据格式 (SSE Line Protocol)

所有 A2UI 消息均以 SSE `type: "a2ui_message"` 的 JSON 格式包输出。每段事件以空行结束：

```http
data: {"type": "a2ui_message", "data": { ...A2UI Payload... }}

```

---

## 3. 三阶段 JSON Payload 契约范例 (JSON Payloads)

### Stage 1: 创建 Surface 表面 (`createSurface`)
在检测到用户有记账、账单生成或图表显示意图时立即输出：

```json
{
  "type": "a2ui_message",
  "data": {
    "version": "v0.9",
    "createSurface": {
      "surfaceId": "surf_tx_987654",
      "catalogId": "basic"
    }
  }
}
```

---

### Stage 2: 填充控件节点结构 (`updateComponents`)
在确定要使用的 Widget 类型后输出控件树：

```json
{
  "type": "a2ui_message",
  "data": {
    "version": "v0.9",
    "updateComponents": {
      "surfaceId": "surf_tx_987654",
      "components": [
        {
          "id": "root",
          "component": "TransactionSuccessCard",
          "amount": 0.00,
          "transaction_type": "expense",
          "currency": "CNY",
          "status": "processing"
        }
      ]
    }
  }
}
```

---

### Stage 3: 数据实效填充与增量更新 (`updateDataModel` 或 最终 `updateComponents`)
在数据库落盘、AI Agent 计算结束时输出最终真实数据：

```json
{
  "type": "a2ui_message",
  "data": {
    "version": "v0.9",
    "updateComponents": {
      "surfaceId": "surf_tx_987654",
      "components": [
        {
          "id": "root",
          "component": "TransactionSuccessCard",
          "amount": 128.50,
          "category": "餐饮",
          "merchant": "星巴克",
          "transaction_type": "expense",
          "currency": "CNY",
          "status": "success",
          "timestamp": "2026-08-08 05:40:00"
        }
      ]
    }
  }
}
```

---

## 4. 后端 Agent 开发注意事项 (Backend Checklist)

1. **唯一 Surface ID**: 每次对话产生的 Surface 推荐使用 `surf_` 作为前缀结合 UUID，确保全局不重复。
2. **零延迟刷新 (Flush Buffer)**: 在输出每个 `a2ui_message` 后，后端 SSE 服务器（如 FastAPI / Flask / Node.js）必须调用 `response.flush()`，防止 HTTP 缓存机制导致多条消息在网络层被打包堆积。
3. **结合 `text_delta`**: 支持 UI 消息与 `text_delta` 文本流交错发送，先输出说明文本，再流式生成卡片。
