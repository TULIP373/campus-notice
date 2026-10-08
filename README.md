# 课程通知平台

余家祥，202232110113，软外241。五个个人实验在同一个项目中按步骤开发，中文 Git 提交以 `[实验一-序号]` 至 `[实验五-序号]` 区分实验。

学生按课程集中查看老师的通知、提交要求、报告格式、截止时间和学习资料。教师手动维护通知。三门演示课程：软件项目实训（二）、数据库原理、软件测试。当前课程问答先检索本课程原文，再请求模型回答并显示引用。

## 当前验证状态

实验一至四已完成真实 MySQL CRUD、Vue/Axios 联调、真实 feature 分支冲突合并、JWT/BCrypt/RBAC。40 项 Java 测试通过。实验五的检索、问答接口、页面与 SDK 桥已实现；Windows 权限探针及真实模型提交要求问答已通过，缺资料/跨课程/注入也明确拒答。单测中的 HTTP 桩另用于格式和故障检查，不冒充实际模型。最终检查以 `docs/acceptance-report.md` 和 `docs/PROGRESS.md` 为准。

## 这台电脑启动

在项目目录打开 PowerShell。数据库和私有配置已准备好，日常启动不需要再次导入 SQL：

```powershell
./tools/Start-Database.ps1
./tools/Start-Backend.ps1
./tools/Start-Frontend.ps1
```

打开 `http://127.0.0.1:5173/`。账号密码在本机 `.runtime/demo-accounts.json`，该文件不提交；教师和学生分别登录体验。刷新页面会清除内存中的登录令牌，需重新登录。后端 `http://127.0.0.1:8080/api/health` 不要求登录，其余业务接口需要 JWT。

```powershell
./tools/Stop-Frontend.ps1
./tools/Stop-Backend.ps1
./tools/Stop-Database.ps1
```

Windows 重打 JAR 前先停止后端；执行 `npm ci` 前先停止前端，避免正在使用的文件被占用。本机 `.runtime` 包含开发软件、数据库数据和私有配置，Git/ZIP 都排除它。ASCII 目录联接 `.local/campus-notice-runtime` 指向同一份运行文件，解决 MySQL 的中文路径兼容问题。

## 其他电脑从源码运行

1. 安装 JDK17、MySQL8、Node.js24、Python3.11+（Python仅模型桥需要）。Maven 使用仓库里的 Wrapper，不必另外安装。
2. 用 Navicat 或 MySQL 客户端创建 `campus_notice` 数据库和单独的开发账户，再依次执行 `database/01-users.sql`、`02-courses-notices.sql`、`03-demo-content.sql`、`04-security.sql`。SQL 不在后端启动时自动执行。
3. 自行在项目根目录创建 `.runtime`，复制 `config/database.example.properties` 为 `.runtime/database.properties`，填写自己的数据库地址、账户、密码；复制 `config/security.example.properties` 为 `.runtime/security.properties`，填写随机 JWT 密钥（至少32个UTF8字节）。这些私有文件已被忽略。也可以使用下面的环境变量。
4. 设置 Java，构建后执行初始化脚本，生成本机随机学生、教师演示账号：

```powershell
$env:JAVA_HOME='你的JDK17目录'
$env:DB_URL='jdbc:mysql://127.0.0.1:3306/campus_notice?characterEncoding=UTF-8&serverTimezone=Asia/Shanghai'
$env:DB_USER='你的数据库开发账户'
$env:DB_PASSWORD='在本机填写数据库密码'
$env:APP_JWT_SECRET='在本机生成并填写至少32字节的随机密钥'
./mvnw.cmd -B -ntp verify
./tools/Init-DemoAccounts.ps1
./tools/Start-Backend.ps1 -SkipBuild
```

数据库使用你自行安装的服务；`Start-Database.ps1` 仅适用于本机已准备的 MySQL 运行库，源码包不包含运行库。前端可独立启动：

```powershell
cd frontend
npm ci
npm run dev -- --host 127.0.0.1
```

Vite默认端口5173，Java默认8080。前端 Axios 默认调用8080；可通过 `.env.local` 中的 `VITE_API_BASE_URL` 调整，另需同步后端 CORS 允许来源。

## 实验五模型接入

按照 `model-service/README.md` 安装固定官方 Python Codex SDK，并先执行 `--check-safety`。默认使用官方 ChatGPT 登录；不读取或复制登录凭据、不自动切换收费 API。仅 HTTP 健康检查成功不能证明模型接通。无法验证权限时接口返回明确错误，不能用固定答案代替。

可选兼容 API 模式需要本人明确选择并提供自己的 API 账户配置，ChatGPT 订阅不能充当 API Key。代码支持该模式，当前未进行实际 API 模式验证。System/User 练习见 `docs/提示词练习.md`，检索和边界用例见 `docs/test-cases.md`。

## 检查和提交材料

```powershell
./mvnw.cmd -B -ntp verify
python tools/check_api.py --stage final
# 仅真实模型可用时运行，不会模拟回答
python tools/check_api.py --stage final --model
python tools/Build-Submission.py
```

接口文档在 `docs/openapi.json`，SQL配置在 `database/`、`config/`；实验步骤对照在 `docs/teacher-steps.md`，真实测试证据在 `reports/2026-10-08/`。

五实验合订报告为 `deliverables/202232110113余家祥.docx`，源码、SQL和环境配置说明整理到上一级 `202232110113余家祥_源代码.zip`。本地 Git 仓库保留完整提交历史，ZIP 不含 `.git`；提交历史文本进入源码包。尚未创建远程仓库、推送、执行远程 PR 或云端 CI，GitHub 链接待本人推送后填写。

AI 辅助生成和检查代码、测试、文档。提交前本人仍需阅读并理解代码，复述“页面 → Controller → Service → Mapper → MySQL”的调用过程，并核对实验结果。
