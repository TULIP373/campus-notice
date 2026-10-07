# 模型接入依据
用户此前指定使用GPT Plus，本机codex login status实际输出Logged in using ChatGPT。将优先采用官方Codex SDK程序化调用，然后封装本地问答服务；不复制登录凭据，不使用网页抓取或非官方订阅API。

订阅认证与独立API Key为不同接入方式，报告按实际验证路径说明。可另配置兼容OpenAI协议服务，尚无Key时不宣称完成API Key测试。

官方文档：
- https://learn.chatgpt.com/docs/codex-sdk （Node18+，@openai/codex-sdk，startThread/run与finalResponse）
- https://learn.chatgpt.com/docs/auth （ChatGPT与API Key认证方式）
- https://docs.spring.io/spring-boot/3.5/system-requirements.html （Spring Boot3.5.16至少Java17）
- https://github.com/mybatis/spring-boot-starter/releases （MyBatis Spring Boot3.0.x版本系列）

已检查日期2026-10-08。真实模型调用、SDK安装和项目桥接尚未执行，范围确认后按实验五推进。
