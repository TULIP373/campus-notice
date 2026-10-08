# 课程问答服务

Java 后端通过本地8787端口请求模型服务，发送课程资料和问题，获得回答。默认使用本机已登录的 Codex 和官方 Python SDK。

## 本机启动

双击 tools 文件夹中的 `tools\start-model.cmd`。前后端仍用 `tools\start.cmd` 启动。

`GET /health` 表示 HTTP 服务已经启动，实际能否回答需要在页面提问确认。模型不可用时返回错误，不自动更换接口。

## 安装

在项目根目录打开 PowerShell：

```powershell
python -m venv .runtime/sdk-research
.runtime/sdk-research/Scripts/python.exe -m pip install -r model-service/requirements.txt
.\tools\Start-ModelBridge.ps1
```

需要先在本机完成 Codex 登录。停止模型服务使用 `.\tools\Stop-ModelBridge.ps1`。

启动后可做权限检查，此命令不会请求模型：

```powershell
.runtime/sdk-research/Scripts/python.exe -I model-service/bridge.py --check-safety
```

模型只接收问题和检索到的课程原文。SDK 工作进程清理秘密环境变量，禁用工具，并在调用前检查运行权限；检查失败则拒绝调用。它用于本机课程演示，不应开放到公网。

## 接口

`POST /ask` 接收 JSON：`{"system":"回答规则","user":"课程资料和问题"}`，成功返回 `{"answer":"回答内容"}`。一次处理一个请求，忙时返回503；单次工作进程超时返回504。Java 后端的等待时间为120秒，前端为150秒。

可选 API 接口通过 `MODEL_PROVIDER=openai`、`OPENAI_BASE_URL`、`OPENAI_MODEL` 和 `OPENAI_API_KEY` 环境变量配置。API 使用自己的账户计费，ChatGPT 订阅不能作为 API Key。当前项目没有实际验证此模式。
