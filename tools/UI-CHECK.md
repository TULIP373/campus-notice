# 真实网页检查（可选开发验证）

`check_ui.cjs` 使用本机已安装的 Microsoft Edge 和 Playwright，启动独立的无头浏览器上下文访问真实 Vue、Spring Boot 和 MySQL。不控制用户浏览器、不模拟 API、不改写页面状态。Playwright 仅属于检查环境，不是正常运行依赖；无需修改前端依赖或锁文件。

前置条件：后端 `127.0.0.1:8080`、前端 `127.0.0.1:5173`、本项目 MySQL 已启动；私有 `.runtime/demo-accounts.json` 已初始化；当前 Node 能加载 Playwright。检查环境已有 Playwright 时可通过 `NODE_PATH` 指定模块目录，或通过 `PLAYWRIGHT_MODULE` 指定模块入口。`EDGE_PATH` 可覆盖已安装浏览器路径，脚本不会下载浏览器。

```powershell
node tools/check_ui.cjs
# 正常模型服务已启动，回答及引用另外与真实模型日志交叉核对
node tools/check_ui.cjs --model-live
# 主代理先主动停止真实模型服务；完成后由主代理恢复
node tools/check_ui.cjs --model-unavailable
```

默认检查学生三门课通知/资料/搜索/详情、教师新建编辑删除、学生刷新重新登录并读到更新、浏览器存储无令牌、无资料/跨课程/注入拒答。教师只删除当前运行创建的 `[测试]` 通知。账号和令牌仅在内存读取，截图只取登录后页面。

结果输出 `reports/2026-10-08/ui-check.json` 和真实截图，历史报告保存在 `history/`。报告带实际 Git HEAD、代码未提交状态、逐步结果和时间；提交前的通过不能视为版本绑定通过。默认拒答路径不证明真实模型成功，`--model-live` 仍需真实模型日志佐证。`UI_REPORT_DIR` 可覆盖报告目录，`UI_BASE_URL`/`API_BASE_URL` 可覆盖地址。

截图必须逐图人工查看；自动断言通过不代替视觉复核。新版本验证前先提交实现、测试和配置，再执行本脚本。
