# 数据库配置与建表

使用真实MySQL8，数据库campus_notice，本机端口3307。数据库软件及数据目录属于本地运行环境，不随源码提交。换电脑请用自行安装的MySQL/已有Navicat连接，不需要本机MySQL便捷脚本。

先创建数据库和仅能访问本库的开发账户，再依次执行：

1. 01-users.sql：用户表、唯一用户名、BCrypt密码哈希、角色、创建时间。
2. 02-courses-notices.sql：课程及通知表、课程外键、要求/报告格式/截止时间/资料来源等字段。
3. 03-demo-content.sql：三门演示课程、通知及资料；演示日期不代表真实教师交期。
4. 04-security.sql：roles、permissions、role_permissions；STUDENT/TEACHER权限映射和用户角色外键。

本机已执行过SQL，日常启动不重复导入。可以在Navicat打开各SQL按顺序执行；也可以在项目目录显式指定本地导入脚本：

```powershell
./tools/Start-Database.ps1
./tools/Init-Database.ps1 -SqlFile database/01-users.sql
./tools/Init-Database.ps1 -SqlFile database/02-courses-notices.sql
./tools/Init-Database.ps1 -SqlFile database/03-demo-content.sql
./tools/Init-Database.ps1 -SqlFile database/04-security.sql
```

Init-Database.ps1读取.runtime/mysql-app.cnf私有配置，只接受本项目database目录的SQL，不显示密码。它使用已安装的本机运行库，不会安装软件。SQL初始化模式never，后端启动不会自动建表或重置数据。导入前检查连接的是本项目开发库。

通过DB_URL、DB_USER、DB_PASSWORD环境变量或.runtime/database.properties填写自己的数据源，示例见config/database.example.properties。默认空密码只是占位，不表示账户没有密码。账号密码、完整BCrypt哈希、JWT密钥都不应截图或提交。

表导入完成后，构建JAR并运行tools/Init-DemoAccounts.ps1，创建本地随机演示账号及JWT密钥；已有账号保留，脚本不是全库重置。账号查看.runtime/demo-accounts.json。JWT密钥至少32字节；如已有security.properties占位，必须先填写有效密钥。
