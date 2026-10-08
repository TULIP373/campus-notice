Verified-Commit: f679beba7ae984da4b16ad984968cad735ef9472

# 最终验收报告

2026-10-08，Asia/Shanghai。主代理以磁盘实际文件和执行结果逐项复核。独立验收及代码质量审查原文见 `docs/review-record.md`，结论PASS；首轮失败及修复证据完整保留。

| AC | 结果 | 证据 | 说明 |
| --- | --- | --- | --- |
| AC-E1-01 | PASS | `reports/2026-10-08/resume-backend-build.log` `reports/2026-10-08/resume-smoke/api-check.json` | JDK17真实verify：40项测试，零失败/错误；打包JAR启动及健康检查通过，实际分层和依赖复核。 |
| AC-E1-02 | PASS | `reports/2026-10-08/api-check.json` `reports/2026-10-08/resume-smoke/api-check.json` `reports/2026-10-08/final-restart.json` | 真实MySQL中文CRUD、重复与非法输入、重启持久化及响应排密通过。 |
| AC-E2-01 | PASS | `reports/2026-10-08/ui-check.json` `reports/2026-10-08/student.png` `reports/2026-10-08/teacher.png` | 真实Vue/Axios三课程、通知资料详情、教师维护和刷新读取；独立复核亲自查看截图。 |
| AC-E2-02 | PASS | `reports/2026-10-08/resume-smoke/api-check.json` `reports/2026-10-08/resume-frontend-build.log` `reports/2026-10-08/openapi-check.json` | CORS指定来源允许、其他拒绝；前后端实际构建，错误和公开接口文档一致。 |
| AC-E3-01 | PASS | `reports/2026-10-08/git-history-final.txt` `reports/2026-10-08/git-conflict.log` `reports/2026-10-08/resume-git-private-check.json` | 超过20条真实非空中文实验序号提交，真实双父冲突合并、PR模板与CI；无远程推送。 |
| AC-E4-01 | PASS | `reports/2026-10-08/resume-smoke/security-check.json` `reports/2026-10-08/database-security-check.json` | BCrypt、有限期JWT及数据库权限链路；真实登录、401/403、学生禁写、篡改和过期拒绝。 |
| AC-E4-02 | PASS | `reports/2026-10-08/security-check.json` `reports/2026-10-08/ui-check.json` `reports/2026-10-08/model-check.json` `reports/2026-10-08/archive-check.json` | 内存令牌及刷新清除，输入与注入检查；Git、DOCX内部和ZIP按实际私有值扫描。 |
| AC-E5-01 | PASS | `reports/2026-10-08/model-check.json` `reports/2026-10-08/final-sdk-check.json` `reports/2026-10-08/prompt-check.json` `reports/2026-10-08/rag.png` | 原真实模型及SDK记录与未变化的生产代码对应；450/80 TF-IDF课程Top3检索和原文引用已验证。 |
| AC-E5-02 | PASS | `reports/2026-10-08/model-check.json` `reports/2026-10-08/model-semantic-review.json` `reports/2026-10-08/ai-reflection.md` | 缺资料/跨课/注入拒答，资料内真实攻击不执行，停服503无假答案；实际引用问题及修正如实记录。 |
| AC-DOC-01 | UNVERIFIED | `reports/2026-10-08/document-check.json` `reports/2026-10-08/documentQA/code-excerpt-check.json` `reports/2026-10-08/documentQA/structure-check.json` | 单一18页五实验报告。修复代码硬切，79段摘录完整源行匹配；7个变化页目视复核，另11页与此前逐页图字节一致。 |
| AC-PKG-01 | UNVERIFIED | `reports/2026-10-08/archive-check.json` `reports/2026-10-08/resume-archive-build-check.json` `reports/2026-10-08/resume-archive-backend-build.log` `reports/2026-10-08/resume-archive-frontend-build.log` | 新源码包实际解包逐文件校验、40项Java测试及npm ci/build通过；终版仅增补验收产物，再作真实内容和排密校验并收尾提交。 |

## 证据版本和复核范围

`reports/2026-10-08/final-version-binding.json`列明版本对应关系。373c8db至f679beb的非验收产物变更仅为报告生成器与DOCX；应用、测试、数据库、配置、前端和模型桥保持一致。原真实模型、重启、UI和安全证据仍适用；本轮额外重跑40项Java测试、Vue构建与10项真实接口冒烟。修复报告后再次实际解包构建。其后仅允许项目流程列明的验收产物变更。

本轮未重复真实模型调用；当前8787健康为not_checked，仅表示HTTP服务已恢复，不冒充本轮生成验证。独立复核重新查看原模型完整回答、攻击原文、SDK事件及未变化的调用代码。

## 已知边界

兼容API Key模式、远程PR、云端CI及学生本人代码理解未验证，均按规格如实说明；未push、未提交学习通。GitHub链接由本人推送后填写，截止时间仍待教师通知。本轮资料内注入通过只证明已执行用例，引用编号存在仍需逐项核对事实。秘密配置与本机运行库只留在忽略的.runtime。

最终通过要求真实测试、独立复核和harness final同时成立；机械检查结果存入 `reports/2026-10-08/harness-final.log`。Git收尾提交之后再次检查工作区干净和版本绑定；ZIP只排除其自引用的archive-check.json，最终SHA在该文件中。
