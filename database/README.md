# 数据库配置与建表

本项目使用真实 MySQL，开发库名称为 `campus_notice`，本机端口为 `3307`。先启动 MySQL，再依次执行 SQL。

```powershell
./tools/Start-Database.ps1
./tools/Init-Database.ps1 -SqlFile database/01-users.sql
```

`Init-Database.ps1` 使用已配置的 `.runtime/mysql-app.cnf` 私有凭据，以开发账号执行指定 SQL。该文件不进入 Git 或提交压缩包；脚本不会显示密码。当前脚本只接受本项目 `database` 目录内的 `.sql` 文件，不会自动执行其他 SQL。

也可以在 Navicat 中连接 `127.0.0.1:3307`，选择 `campus_notice`，打开 `01-users.sql` 后执行。连接密码从自己的私有配置中填写，不要截图或提交密码。

换电脑时先创建数据库和仅能访问该库的账号，再用自己的配置。`src/main/resources/application.yaml` 支持 `DB_URL`、`DB_USER`、`DB_PASSWORD` 环境变量；默认密码为空作为占位，并不代表开发账号没有密码。本机 `.runtime/database.properties` 存储实际连接配置，优先于 YAML 默认值；不要提交此私有文件。SQL 初始化模式为 `never`，启动后端不会自动创建或删除表。

`users` 表包含主键、唯一用户名、姓名、密码哈希、角色、创建时间。实验四扩展角色权限表及登录控制；实验一先完成用户增删改查。
