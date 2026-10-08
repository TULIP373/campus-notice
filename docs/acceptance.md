# 验收标准
- **AC-E1-01** Java17/Spring Boot3/Web/MyBatis/MySQL依赖及分层存在，Maven验证与JAR启动通过。证据 reports/2026-10-08/backend-build.log。
- **AC-E1-02** 真实MySQL用户增查改删、中文、重复与非法输入拒绝、重启持久化；不泄露密码。证据 reports/2026-10-08/api-check.json。内存替代不通过。
- **AC-E2-01** Vue+Axios真实调用，三门课切换、要求格式截止时间资料详情；维护后刷新显示，真实学生教师截图。证据 reports/2026-10-08/student.png 与 teacher.png。静态冒充不通过。
- **AC-E2-02** 指定来源CORS允许、其他拒绝、前后端分别构建、错误响应和OpenAPI一致。证据 reports/2026-10-08/api-check.json 与 frontend-build.log。
- **AC-E3-01** 至少20条有内容的中文实验序号提交，feature分支真实冲突解决合并；PR模板与构建测试CI；未推送如实说明。证据 reports/2026-10-08/git-history.txt 与 git-conflict.log。伪造历史不通过。
- **AC-E4-01** MySQL用户角色权限、BCrypt/JWT/@PreAuthorize；登录成功失败、401/403、过期篡改令牌、学生不能维护验证。证据 reports/2026-10-08/security-check.json。
- **AC-E4-02** 令牌仅内存，密码密钥不进Git/ZIP，问答注入及输入校验验证。证据 reports/2026-10-08/security-check.json 与 archive-check.json。
- **AC-E5-01** System/User练习与SDK ask(question)真实模型响应；切块向量课程检索引用可观察、界面真实演示。证据 reports/2026-10-08/model-check.json 与 rag.png。模拟和固定答案不通过。
- **AC-E5-02** 缺资料、跨课程、注入、模型故障明确处理，记录实际错误观察与应对。证据 reports/2026-10-08/model-check.json 与 ai-reflection.md。禁止伪造幻觉案例。
- **AC-DOC-01** 单一DOCX五实验步骤、技术设计、代码、真实截图结果AI反思，身份准确待填字段说明、模板版式每页渲染检查。证据 reports/2026-10-08/document-check.json。
- **AC-PKG-01** ZIP源码SQL配置示例启动测试齐全且排除秘密运行库缓存，解包清单验证、工作区干净未推送。证据 reports/2026-10-08/archive-check.json。
- **AC-RUN-01** CMD可从含中文和空格的项目路径及其他工作目录启动前后端；已运行服务复用，其他程序占端口明确拒绝；停止后可重新启动，不重置数据，已有JAR不重复构建、缺失则构建。证据 reports/2026-10-08/demo-launch-check.json。
- **AC-PKG-02** README、环境和模型说明简明可操作；精简包包含源码测试SQL配置示例CI/PR启动文件及报告，排除内部代理模板和过程文件；旧完整包和开发记录保留，业务源码与实验报告不变。证据 reports/2026-10-08/cleanup-check.json。
## 修订记录
2026-10-08 建立用户指定个人项目基线。
2026-10-08 用户新增CMD演示启动及目录文字精简要求，增加AC-RUN-01和AC-PKG-02。原业务和报告验收口径保留，包装对象按新范围重新核对。
