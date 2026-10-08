# 模型接入依据

用户指定使用GPT Plus，本机官方Codex曾实际确认ChatGPT登录。项目使用官方Python openai-codex==0.161.0及随包固定CLI，封装localhost HTTP服务；不读取/复制登录凭据，不抓取网页，不使用非官方订阅API。

SDK的ask(question)从Thread.run的final_response提取真实返回。System规则与User问题/当前课程检索原文分开。Java通过POST /ask请求SDK桥，模型失败返回非成功状态，不能用固定回答替代。精确安装与权限验证见model-service/README.md。

ChatGPT订阅与独立API Key属于不同认证及计费方式。默认路径不自动切换API；可选API模式必须本人明确配置，当前未进行真实API模式测试。真实模型及权限探针结果以reports/2026-10-08中实际证据为准。

官方依据（2026-10-08核对）：
- [官方Codex SDK](https://learn.chatgpt.com/docs/codex-sdk)
- [官方认证方式](https://learn.chatgpt.com/docs/auth)
- [App Server](https://learn.chatgpt.com/docs/app-server)
- [权限profile](https://learn.chatgpt.com/docs/permissions)
- [Spring Boot3.5系统要求](https://docs.spring.io/spring-boot/3.5/system-requirements.html)
- [MyBatis Spring Boot Starter](https://github.com/mybatis/spring-boot-starter/releases)

Python高层SDK0.161尚未完整暴露实验性permissions字段，本桥用官方底层request创建命名权限线程，再交给官方Thread.run。运行时权限失败时关闭本次请求；配置覆盖仅作用于子进程。
