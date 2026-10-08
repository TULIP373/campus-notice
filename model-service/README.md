# 实验五本地模型桥

默认 `MODEL_PROVIDER=codex` 使用官方 Python `openai-codex==0.161.0`，复用本机官方 Codex 的 ChatGPT 登录；不读取、复制或输出 auth.json，不会因 SDK 故障自动转用收费 API Key。Python 需要 3.11+（本项目用 3.12），HTTP 部分只使用标准库。

安装与启动（项目根目录）：

```powershell
python -m venv .runtime/sdk-research
.runtime/sdk-research/Scripts/python.exe -m pip install -r model-service/requirements.txt
# 如未登录，使用本机官方 codex login；不要把凭据放进项目。
./tools/Start-ModelBridge.ps1
# 以下仅做 SDK 登录、权限配置和公开 canary 探针，不调用模型。
.runtime/sdk-research/Scripts/python.exe -I model-service/bridge.py --check-safety
./tools/Stop-ModelBridge.ps1
```

SDK 安装会下载固定 CLI 运行时。默认使用该运行时。必要时 `Start-ModelBridge.ps1 -CodexBin '本机 codex.exe 绝对路径'` 明确选择其他版本，仍必须通过权限检查；不要把不同版本当作固定运行时已验证。手动运行时可设置 `CAMPUS_CODEX_BIN`。

Java 调用 `POST http://127.0.0.1:8787/ask`，发送 `application/json`：`{"system":"仅根据资料回答并引用原文","user":"公开演示课程资料和问题"}`。成功为 `{"answer":"真实模型回答"}`；故障为 `{"message":"明确错误"}`。最多 32KB，并发一条，忙时 503；单次工作进程最多 110 秒，超时 504 并终止自己的进程树，早于 Java 的 120 秒和前端的 150 秒超时。`GET /health` 只表示 HTTP 服务启动，`model=not_checked` 不代表模型可用。拒绝带 Origin 的请求，浏览器通过 Java 后端调用。

`sdk_adapter.ask(question)` 由官方 SDK `Thread.run(question).final_response` 提取真实答案。每次使用独立 ephemeral thread。SDK 0.161 的高层方法未暴露实验性 `permissions` 和 `activePermissionProfile`，因此通过 SDK 底层 request 创建带命名权限的线程，再使用官方 Thread.run。

安全边界：子进程启动前移除 API/数据库/JWT 等秘密环境变量，SDK 构造前再次清理。关闭 shell、Apps、plugins、hooks、多代理、记忆、web、图像与技能依赖安装，并只解析本机 Codex TOML 中的 MCP/插件名称逐个禁用。进程内配置覆盖不修改全局配置。原生 Windows elevated profile 保留系统根目录只读，项目、运行目录、Codex 凭据目录与 `.ssh` 显式 deny，网络关闭；这是本机公开演示的有限隔离，不是整机读取隔离。模型 cwd 使用系统临时目录中的项目专属 `campus-notice-question-only-<路径摘要>` 空目录并只允许读取，避免 Windows 项目 deny ACL 继承导致无法进入 cwd。目录非空立即失败，不清除原有文件。

仅 SDK 工作进程的 `LOCALAPPDATA` 设为 `.runtime/model-appdata`，该目录仍在项目 deny 内；`USERPROFILE` 和 `CODEX_HOME` 保留官方登录。此客户端关闭 CUA，因此无需修改桌面程序正占用的 CUA runtime DLL ACL。原生 Windows setup 使用 `LOCALAPPDATA/OpenAI/Codex/runtimes` 作为应用运行时扫描来源；该子进程路径不含桌面运行时和凭据。命令环境仍使用 `inherit=none`，仅显式保留 `SYSTEMROOT`、`WINDIR`、`PROGRAMDATA`、`TEMP`、`TMP` 五项 Windows 启动必需变量，避免 PowerShell 初始化错误，不继承数据库或认证变量。

返回的权限 profile、审批模式、自动加载文件来源必须通过检查；通过 app-server 运行固定公开探针，验证空目录可读、外部公开 canary 不可读、空目录不可写。无法执行或验证时明确失败，不退回宽松 sandbox。官方 SDK 结果包含输入回显 userMessage、reasoning 与 agentMessage；出现其他事件则拒绝交付，所有工具事件仍被拒绝。运行日志仅记录事件类型，不记录请求、回答、配置或底层错误。2026-10-08 曾试查官方 MXC 后端：readiness 为 ready，但真实 PowerShell 探针以 `HRESULT 0x80070003` 启动失败，因此未采用；可用性查询不能替代边界探针。

Windows 的权限 profile 仍为 beta；某些平台 sandbox 无法执行 split read/write 策略，会拒绝请求。本服务把这种情况作为模型不可用。平台最小路径不是完整虚拟机隔离；canary 验证是针对实际运行时的边界检查，不证明所有可能工具完全消失。只用于本机公开课程演示，不能公开暴露此 Codex 服务。

可选兼容 API 模式：只有显式设置 `MODEL_PROVIDER=openai` 时才请求 `OPENAI_BASE_URL`（默认 `https://api.openai.com/v1`）的 `/chat/completions`，使用 System/User messages。同时在环境变量提供 `OPENAI_MODEL` 和 `OPENAI_API_KEY`，不要写入源码或提交。此模式按 API 账户计费，ChatGPT 订阅不能代替；当前无 Key，未进行真实 API 模式验证。HTTPS 地址不允许内嵌凭据，禁止重定向携带认证。默认 codex 路径绝不自动 fallback 到 API。

官方依据：[Codex SDK](https://learn.chatgpt.com/docs/codex-sdk)、[认证](https://learn.chatgpt.com/docs/auth)、[权限 profile](https://learn.chatgpt.com/docs/permissions)、[App Server](https://learn.chatgpt.com/docs/app-server)、[Chat API](https://developers.openai.com/api/reference/resources/chat)。
