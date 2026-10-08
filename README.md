# 课程通知平台

余家祥，202232110113，软外241。五个个人实验在同一个小项目中逐步完成。

学生按课程查看通知、提交要求、报告格式、截止时间和学习资料；教师手动维护内容。问答根据当前课程资料检索并给出来源。开发与验证以 `docs/teacher-steps.md` 和 `docs/acceptance.md` 为准。

## 当前阶段

实验一已验证用户 CRUD、BCrypt 和真实 MySQL 重启持久化；实验二已完成 Vue 页面、课程通知维护、Axios 联调、CORS 和 OpenAPI。后续实验仍按顺序进行。

## 本机实验一运行

在此项目目录使用 PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Start-Database.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Init-Database.ps1 -SqlFile database/01-users.sql
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Init-Database.ps1 -SqlFile database/02-courses-notices.sql
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Init-Database.ps1 -SqlFile database/03-demo-content.sql
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Start-Backend.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Start-Frontend.ps1
```

健康接口为 `http://127.0.0.1:8080/api/health`。用户接口 `/api/users` 与 `/api/users/{id}`，方法 GET、POST、PUT、DELETE；后续实验四加入登录和教师权限。用户名、姓名、角色与密码由请求填写，数据库仅保存 BCrypt 哈希，接口不返回密码哈希。

本机数据库软件、数据、私有配置在 `.runtime`，已被 Git 忽略。ASCII 目录联接 `.local/campus-notice-runtime` 指向同一份本机文件，解决 Windows MySQL 对中文路径的兼容问题。

页面地址为 `http://127.0.0.1:5173/`；前端单独运行，后端在8080。通知接口与错误格式见 `docs/openapi.json`。Windows 重新打包前先运行 `tools/Stop-Backend.ps1`，否则运行中的 JAR 会被占用。

## 其他电脑配置

安装 JDK17、MySQL8、Node.js；Maven 使用仓库里的 Wrapper。MySQL 创建 `campus_notice` 数据库和单独的开发账户，按 `database/README.md` 执行 SQL。通过 `DB_URL`、`DB_USER`、`DB_PASSWORD` 环境变量配置数据源，或自行创建忽略提交的 `.runtime/database.properties`。不必使用本机 `.runtime` 程序，也不要复制其他人的私有账户文件。

```powershell
$env:JAVA_HOME='你的JDK17目录'
$env:DB_URL='jdbc:mysql://127.0.0.1:3306/campus_notice?characterEncoding=UTF-8&serverTimezone=Asia/Shanghai'
$env:DB_USER='你的数据库开发账户'
$env:DB_PASSWORD='在本机填写数据库密码'
.\mvnw.cmd -B -ntp verify
.\mvnw.cmd spring-boot:run
```

## Git 与提交材料

摘要使用 `[实验一-序号]` 至 `[实验五-序号]` 中文前缀。提交是实际开发变更，不回填历史。仅本地提交，由本人最后创建 GitHub 仓库并推送；远程 PR 和云端 CI 未执行不能写成已通过。

最终报告将为 `202232110113余家祥.docx`，源码、SQL、配置示例和环境说明整理为 ZIP。报告中的 GitHub 地址待推送后填写。五实验与交付验收尚在进行，最终状态见 `docs/PROGRESS.md`。

AI 辅助生成和检查代码、测试、文档。自动验证不能代替本人理解；提交前应阅读各层职责、复述接口调用流程，并复核报告中的真实结果。
