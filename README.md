# Mini-Agent

一个从零实现的轻量级 AI Agent 框架，用少量 Python 代码展示 Agent 的核心工作流：LLM 推理、工具调用、工具结果回传、多轮对话和 CLI 交互。

这个项目定位为学习型实现，而不是对 LangChain、CrewAI 等成熟框架的封装。代码刻意保持简单，方便面试官快速看到 Agent loop、tool registry、function calling 和异步执行的具体实现。

## Highlights

- 从零实现 `perceive -> think -> act -> observe` Agent 循环
- 基于 DeepSeek 的 OpenAI-compatible function calling
- 可扩展工具系统：抽象 `Tool` 基类、注册表、统一 JSON Schema 描述
- 内置 5 个工具：Python 执行、文件读写、计算器、模拟搜索
- 支持多轮对话上下文和 `/reset` 重置
- 使用 `asyncio` 封装 LLM 调用和工具执行
- 带单元测试，覆盖工具注册、计算器安全边界和 Agent tool-call 流程

## Architecture

```text
User
  |
  v
CLI / REPL
  |
  v
Agent.run()
  |
  +--> LLMClient.chat(messages, tools)
  |       |
  |       +--> text response ---------------> final answer
  |       |
  |       +--> tool_calls
  |              |
  |              v
  |        ToolRegistry.execute()
  |              |
  |              v
  |        tool result messages
  |              |
  +--------------+
```

## Project Structure

```text
.
├── mini_agent/
│   ├── __init__.py       # Public package exports
│   ├── __main__.py       # Enables module execution
│   ├── cli.py            # CLI / REPL entrypoint
│   ├── agent.py          # Core Agent loop and conversation state
│   ├── llm.py            # DeepSeek/OpenAI-compatible chat client
│   └── tools.py          # Tool abstraction, registry, built-in tools
├── tests/                # Unit tests for tools and agent loop
├── pyproject.toml        # Package metadata, console script, pytest config
└── .env.example          # API key template
```

## Quick Start

### 1. Install dependencies

Using conda:

```bash
conda create -n mini-agent python=3.11
conda activate mini-agent
pip install -e ".[dev]"
```

### 2. Configure API key

```bash
cp .env.example .env
export DEEPSEEK_API_KEY="your-deepseek-api-key"
```

### 3. Run the agent

```bash
mini-agent
```

Example prompts:

```text
计算 (15 * 23 + sqrt(144)) / 2 的结果
在当前目录创建一个 hello.py，内容是打印 "Hello Agent"
读取刚才创建的 hello.py，然后用 Python 执行它
帮我分析一下：1 米/秒 的风速下，一个半径 5 米的水平轴风力发电机理论功率是多少？用贝茨极限算。
```

## Commands

```text
/help   Show CLI commands
/tools  List available tools
/reset  Clear conversation history
/quit   Exit the CLI
```

## Tests

Run tests:

```bash
pytest
```

The tests use a fake LLM for the Agent loop, so they do not require a real API key.

## Core Design

### Agent loop

`mini_agent/agent.py` keeps the conversation state and repeatedly calls the LLM until it receives a final text response or reaches the iteration limit. When the LLM returns tool calls, the agent executes them through `ToolRegistry` and appends results back into the message history.

### Tool system

Each tool implements:

- `name`: function name exposed to the LLM
- `description`: natural-language instruction for when to use it
- `parameters`: JSON Schema argument definition
- `execute()`: async implementation

This mirrors OpenAI-compatible function calling while keeping the implementation easy to inspect.

### LLM client

`mini_agent/llm.py` wraps the OpenAI SDK and points it at DeepSeek's compatible endpoint. The wrapper normalizes model responses into a small `LLMResponse` dataclass so the rest of the project does not depend on SDK-specific response objects.

## Built-in Tools

| Tool | Purpose |
| --- | --- |
| `execute_python` | Runs a self-contained Python snippet in a subprocess |
| `read_file` | Reads UTF-8 text files with output truncation |
| `write_file` | Creates or overwrites text files |
| `calculator` | Evaluates math expressions with a restricted namespace |
| `web_search` | Simulated search placeholder for demonstrating tool flow |

## Interview Talking Points

- Why implement the Agent loop directly instead of hiding it behind a framework
- How function calling maps to tool registration and tool result messages
- Why the project uses async interfaces even though the demo is small
- How iteration limits and structured error strings prevent simple failure loops
- Where production hardening would be added: filesystem sandboxing, user confirmation before writes, real search API, streaming output, persistent memory, and observability

## Security Notes

This is a local learning project. `execute_python` runs code in a subprocess, but it is not a full security sandbox. In production, code execution and file writing should be isolated with stricter permissions, path allowlists, resource limits, and explicit user confirmation.
