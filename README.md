# 课程通知平台

个人项目实训作业。后端使用 Java 17、Spring Boot、MyBatis 和 MySQL，前端使用 Vue 3。

学生可以按课程查看通知、学习资料和提交要求；教师可以维护通知。问答功能从当前课程资料中检索内容，再给出带原文引用的回答。

## 在这台电脑上演示

双击项目根目录的 `start.cmd`，等待启动完成后会打开浏览器。也可以在 CMD 中输入：

```cmd
start.cmd
```

| 文件 | 用途 |
| --- | --- |
| start.cmd | 启动数据库、后端和前端，并打开网页 |
| stop.cmd | 停止前后端，保留数据库服务 |

已经启动的服务会直接复用。已有 JAR 时不再编译；首次启动没有 JAR 时会自动构建。启动失败会在窗口中显示原因，详细日志在 `.runtime`。

网页地址：`http://127.0.0.1:5173/`。后端检查地址：`http://127.0.0.1:8080/api/health`。

学生和教师账号在本机 `.runtime/demo-accounts.json`。刷新网页后需要重新登录。演示问答前在 PowerShell 运行 `.\tools\ps1\Start-Demo.ps1 -Mode Model`；模型服务启动后，首次提问可能需要等待。

如果只是想通过命令运行、不打开浏览器和暂停窗口，在命令后加 `-NoPause`，例如 `start.cmd -NoPause`。

## 项目目录

- `src`：后端代码和测试。
- `frontend`：Vue 页面和接口调用。
- `database`：建表、权限和演示数据 SQL。
- `config`：数据库、JWT 和模型配置示例。
- `model-service`：课程问答的本地模型接口。
- `docs`：接口、Git约定和提示词练习。
- `tools/ps1`：启动、停止和初始化的 PowerShell 脚本。
- `tools/Build-Submission.py`：源码打包脚本。
- `deliverables`：五个实验的合订报告。

## 换一台电脑运行

1. 安装 JDK 17、MySQL 8 和 Node.js。模型服务另外需要 Python 3.11 以上版本。
2. 创建 `campus_notice` 数据库，按顺序执行 `database/01-users.sql` 至 `04-security.sql`。
3. 创建 `.runtime` 文件夹，将 `config/database.example.properties` 和 `security.example.properties` 复制为 `.runtime/database.properties` 和 `security.properties`，填写自己的数据库连接和至少32字节的 JWT 密钥。
4. 在 PowerShell 中构建并初始化演示账户：

```powershell
.\mvnw.cmd -B -ntp package
.\tools\ps1\Init-DemoAccounts.ps1
.\tools\ps1\Start-Backend.ps1 -SkipBuild
.\tools\ps1\Start-Frontend.ps1
```

换电脑时使用自己安装的 MySQL 服务。`start.cmd` 中的数据库便捷启动仅适用于当前电脑已经准备好的本地运行库；源码包不含数据库软件和数据文件。模型服务安装方法见 `model-service/README.md`。

## 检查和交付

后端测试：`.\mvnw.cmd -B -ntp verify`。
前端构建：进入 `frontend` 后运行 `npm ci` 和 `npm run build`。
后端40项测试及前端构建已通过，启动脚本已检查重复启动、端口冲突、冷启动和自动构建。

报告在 `deliverables/202232110113余家祥.docx`。源码包还包含 SQL、配置示例和运行说明。GitHub 地址在本人推送仓库后补充；目前未进行远程 PR 或云端 CI。
