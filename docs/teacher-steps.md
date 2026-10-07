# 老师建议步骤与提交顺序
来源：课程目录《团队规范项目实训》课程实践方案.docx个人实验章节。用户要求五实验合并一份报告，本地中文提交，远程操作自己完成。

| 实验 | 建议顺序 | 本地实现与提交计划 |
| --- | --- | --- |
| 一 | 创建Maven/SpringBoot3，Web/MyBatis/MySQL；application.yml数据源；Entity/Mapper/Service/Controller；AI脚手架单测人工验证；启动或JAR部署验证CRUD | 01基础项目；02环境脚本；03规格验收；04独立测试与模板核对；05依赖数据源SQL；06Entity/Mapper；07Service/Controller；08CRUD测试打包 |
| 二 | RestController JSON；Vue组件Axios；CORS；分别构建联调；AI生成组件OpenAPI核对边界 | 01课程通知REST；02Vue骨架Axios；03课程筛选详情；04教师维护；05CORS接口文档；06构建联调 |
| 三 | git init/feature分支/merge/冲突/远程；PR模板CI；AI审查人工最终责任 | 01分支功能；02主分支修改；03真实冲突合并；04PR模板审查；05CI构建测试。远程不执行 |
| 四 | 用户角色权限表；SpringSecurity；BCrypt；JWT签发验证；PreAuthorize；输入注入防护 | 01RBAC表；02密码登录；03JWT安全链；04接口权限；05前端内存令牌；06安全边界测试 |
| 五 | System/User练习；SDK ask(question)；切块向量检索拼提示；接入原型；模型错误幻觉反思 | 01提示与SDK；02切块向量检索；03模型接口；04页面问答；05注入引用兜底；06真实验证反思；07报告；08归档 |

步骤必须产生真实变更再提交，不虚构过去操作；每条以[实验N-序号]中文摘要命名，root负责所有提交。学生还需阅读并复述代码，报告不能代替个人理解。远程PR与CI未运行不冒充已完成。
