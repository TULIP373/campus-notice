# 数据库配置与建表

使用真实MySQL8，数据库campus_notice，本机端口3307。数据库软件及数据目录属于本地运行环境，不随源码提交。换电脑请用自行安装的MySQL/已有Navicat连接，不需要本机MySQL便捷脚本。

先创建数据库和仅能访问本库的开发账户，再依次执行：

1. 01-users.sql：用户表、唯一用户名、BCrypt密码哈希、角色、创建时间。
2. 02-courses-notices.sql：课程、通知、参考附件和任课关系表。
3. 03-demo-content.sql：八门演示课程、24条通知及资料、16处附件关联；日期为模拟安排。
4. 04-security.sql：roles、permissions、role_permissions；STUDENT/TEACHER权限映射和用户角色外键。
5. 05-demo-update.sql：已有旧版演示数据时使用，将旧种子通知更新为当前内容，并补充新课程；不覆盖教师自行录入的通知。

6. 06-demo-review-fix.sql：已有早期手工样例时使用，统一“作业1”的演示截止时间说明，并把旧通知中的仓库占位提示替换为实际地址。只匹配指定旧内容，重复执行不会改动其他通知。

本机已执行过SQL，日常启动不重复导入。可以在Navicat打开各SQL按顺序执行；也可以在项目目录显式指定本地导入脚本：

```powershell
.\tools\ps1\Start-Database.ps1
.\tools\ps1\Init-Database.ps1 -SqlFile database/01-users.sql
.\tools\ps1\Init-Database.ps1 -SqlFile database/02-courses-notices.sql
.\tools\ps1\Init-Database.ps1 -SqlFile database/03-demo-content.sql
.\tools\ps1\Init-Database.ps1 -SqlFile database/04-security.sql
```

Init-Database.ps1读取.runtime/mysql-app.cnf私有配置，只接受本项目database目录的SQL，不显示密码。它使用已安装的本机运行库，不会安装软件。SQL初始化模式never，后端启动不会自动建表或重置数据。导入前检查连接的是本项目开发库。

通过DB_URL、DB_USER、DB_PASSWORD环境变量或.runtime/database.properties填写自己的数据源，示例见config/database.example.properties。默认空密码只是占位，不表示账户没有密码。账号密码、完整BCrypt哈希、JWT密钥都不应截图或提交。

表导入完成后，构建JAR并运行 tools/ps1/Init-DemoAccounts.ps1，创建一名学生、八名任课教师的本地演示账号及JWT密钥，并建立教师与课程的关联；已有密码保留。账号可查看根目录“演示账号.txt”。JWT密钥至少32字节；如已有security.properties占位，必须先填写有效密钥。
