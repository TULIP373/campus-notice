Verified-Commit: 7e7443c70270bfd35a52eded66718e9aa6e2610a

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
| AC-DOC-01 | PASS | `reports/2026-10-08/document-check.json` `reports/2026-10-08/documentQA/typography-check.json` `reports/2026-10-08/documentQA/code-excerpt-check.json` `reports/2026-10-08/documentQA/toc-polish-check.json` | 单一21页五实验报告；实际宋体12磅正文和三级黑体标题，目录等距点引导与实测页码一致。13处79段摘录完整源行匹配；独立逐页视觉复核通过，消除实验三孤立尾页。 |
| AC-PKG-01 | PASS | `reports/2026-10-08/archive-check.json` `reports/2026-10-08/polish-package-check.json` `reports/2026-10-08/resume-archive-build-check.json` | 精修报告及生成器入新ZIP，真实解包逐文件校验与私有值排除通过。93个应用源码/测试/配置/SQL/前端/模型及运行脚本与此前实际构建解包版逐字节一致，继承40项Java测试及npm ci/build证据。 |

## 证据版本和复核范围

`reports/2026-10-08/final-version-binding.json`列明版本对应关系。373c8db至本轮精修版的非验收变更仅为报告生成器与DOCX；应用、测试、数据库、配置、前端和模型桥不变。此前恢复阶段实际重跑40项Java测试、Vue构建与10项API冒烟，并在真实解包版完成Java40项及npm ci/build。本次字体排版请求重新检验DOCX实际字体、结构、源码摘录、21页渲染及目录；独立review绑定7e7443c，后续仅允许验收产物变更。

本次未重复真实模型或业务构建。原真实模型、重启、UI和安全证据仍对应未变实现；93个应用及运行文件与此前成功构建的真实解包版逐字节相同。当前8787健康not_checked仅表示HTTP启动，不冒充新模型生成验证。

初稿字体辅助函数未写入eastAsia，旧自动字体验证误判PASS；独立review判FAIL后修复，并保留严格断言的旧版FAIL与新版PASS。实验三稀疏尾页已消除。目录双位页码点引导及间距经实际渲染发现并修复，角色权限三行短表现于第13页完整同页；最终21页全部目视通过；旧失败原文与修复前图完整留于history。

## 已知边界

兼容API Key模式、远程PR、云端CI及学生本人代码理解未验证，均按规格如实说明；未push、未提交学习通。GitHub链接由本人推送后填写，截止时间仍待教师通知。本轮资料内注入通过只证明已执行用例，引用编号存在仍需逐项核对事实。秘密配置与本机运行库只留在忽略的.runtime。

最终通过要求真实测试、独立复核和harness final同时成立；机械检查结果存入 `reports/2026-10-08/harness-final.log`。Git收尾提交之后再次检查工作区干净和版本绑定；ZIP只排除其自引用的archive-check.json，最终SHA在该文件中。
