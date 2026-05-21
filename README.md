# Mini-Agent

一个从零搭建的 AI Agent 学习项目，用 ~300 行 Python 实现完整的 **感知→思考→行动** 循环。

## 架构

```
用户输入
  │
  ▼
┌─────────────────────────────────────┐
│            Agent Loop               │
│                                     │
│  ┌──────────┐    ┌──────────────┐   │
│  │  LLM     │◄───│ Conversation │   │
│  │ (DeepSeek)│    │  History     │   │
│  └────┬─────┘    └──────────────┘   │
│       │                              │
│       │ text? ──────────► 返回用户   │
│       │ tool_calls?                  │
│       ▼                              │
│  ┌──────────┐                       │
│  │  Tools   │                       │
│  │ Registry │                       │
│  └────┬─────┘                       │
│       │                              │
│       │ 工具执行结果                  │
│       ▼                              │
│  回到 LLM ←──────────────────────    │
└─────────────────────────────────────┘
```

## 文件结构

| 文件 | 职责 | 行数 |
|------|------|------|
| `llm.py` | DeepSeek API 封装，支持 tool calling | ~100 |
| `tools.py` | 工具抽象基类 + 5 个内置工具 + 注册表 | ~200 |
| `agent.py` | 核心 Agent 循环 + 对话管理 | ~100 |
| `main.py` | CLI 入口 + REPL 交互界面 | ~100 |
| `requirements.txt` | 仅依赖 openai SDK | - |

## 内置工具

| 工具 | 功能 |
|------|------|
| `execute_python` | 在子进程中执行 Python 代码 |
| `read_file` | 读取文件内容 |
| `write_file` | 写入内容到文件 |
| `calculator` | 安全地计算数学表达式 |
| `web_search` | 模拟搜索（可替换为真实 API） |

## 快速开始

### 1. 创建 conda 环境（推荐）

```bash
# 方式 A：一键脚本
bash setup.sh

# 方式 B：手动
conda env create -f environment.yml
conda activate mini-agent
```

或者用 pip 直接装：

```bash
pip install -r requirements.txt
```

### 2. 设置 API Key

```bash
export DEEPSEEK_API_KEY="sk-你的key"
```

### 3. 运行

```bash
python main.py
```

### 4. 试试这些例子

```
You > 计算 (15 * 23 + sqrt(144)) / 2 的结果
You > 在当前目录创建一个 hello.py，内容是打印 "Hello Agent"
You > 读取刚才创建的 hello.py，然后用 Python 执行它
You > 帮我分析一下：1 米/秒 的风速下，一个半径 5 米的水平轴风力发电机理论功率是多少？用贝茨极限算。
```

## 核心设计决策

### 为什么自己写框架而不是用 LangChain？

LangChain 抽象层太多，不容易看清 Agent 循环的本质。这个项目把所有核心机制暴露在 ~300 行代码里，你可以直接读到每一步在做什么。

### 为什么用 DeepSeek？

- API 格式兼容 OpenAI，迁移成本低
- 支持完整的 function calling
- 价格便宜，适合学习阶段大量调用

### 为什么用异步（asyncio）？

真实生产环境的 Agent 系统几乎全是异步的——你需要同时调多个工具、处理流式响应、管理长时间运行的任务。虽然这个 demo 体量不大，但从一开始就用 async 是正确的习惯。

## Agent 循环详解

每次 `agent.run(user_input)` 被调用时：

1. **重置对话**：messages 设为 `[system_prompt, user_message]`
2. **调用 LLM**：发送 messages + 工具定义
3. **判断返回**：
   - 如果是纯文本 → 返回给用户，结束
   - 如果有 tool_calls → 执行每个工具，把结果插回 messages，回到步骤 2
4. **循环上限**：最多 10 次迭代，防止死循环

关键代码在 `agent.py` 的 `run()` 方法，只有 ~40 行。

## 如何扩展

1. **添加新工具**：继承 `Tool` 基类，实现 `name/description/parameters/execute`，注册到 `ToolRegistry`
2. **添加任务规划**：在 system prompt 中要求 LLM 先输出计划再执行
3. **添加记忆系统**：把重要信息持久化到文件，跨会话加载
4. **添加流式输出**：用 `stream=True` 逐 token 显示 LLM 的思考过程
5. **支持多轮对话**：去掉 `reset()` 调用，让 messages 跨 `run()` 累积
6. **添加安全确认**：对 write_file 等操作要求用户确认后才执行

## 与 Claude Agent SDK 的对应关系

学习这个项目时，可以对照你之前了解的 Claude Agent 架构：

| Claude Agent | Mini-Agent 对应 |
|-------------|----------------|
| 系统提示词 + 用户消息 | `agent.messages` |
| 工具清单注入 | `tools.list_definitions()` |
| tool_call 输出 | `LLMResponse.tool_calls` |
| tool_result 回传 | `messages.append(tool_result)` |
| 感知→思考→行动循环 | `agent.run()` 中的 for 循环 |
| 子 Agent 委托 | 未实现（留给你的练习） |
| Memory 系统 | 未实现（留给你的练习） |
| 上下文压缩 | 未实现（留给你的练习） |
