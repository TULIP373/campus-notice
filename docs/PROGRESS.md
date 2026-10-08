# 进度记录

## 当前状态
- 用户已确认五个个人实验范围；按老师建议顺序开发，全部只在本地提交、不push。
- 实验一至四已实际完成；实验五RAG、问答接口、页面和SDK桥已实现。40项Java测试及前端构建通过。
- 模型权限探针与真实SDK问答已通过；373c8db最终原文问答、资料内注入、拒答和停服检查均有完整证据。早期SDK失败保留于历史记录。
- 五实验单一DOCX共18页，逐页核对通过；源码ZIP已解压并通过40项Java测试和Vue生产构建。本次恢复已启动全新上下文独立review，尚待结论。
- 实际服务：MySQL3307、后端8080、Vue5173；模型桥8787已启动。启动说明README.md，秘密配置只在.runtime。
- 下一步：独立review结论原文留档，主代理逐项验收报告和harness final，然后刷新源码包并提交收尾证据。

## 里程碑
| 实验 | 实际状态 |
| --- | --- |
| 一 | Java17/SpringBoot3/MyBatis/MySQL分层；真实用户CRUD、8项初始单测与重启持久化通过 |
| 二 | Vue/Axios三课程通知及资料、教师真实增改删、CORS与接口文档、浏览器联调和生产构建 |
| 三 | feature/commit-convention真实同一行冲突，dec915d双父合并；PR模板及CI配置；本地构建命令已执行，远程未执行 |
| 四 | MySQL角色权限、BCrypt登录、JWT、过滤器及PreAuthorize；登录/401/403/篡改/过期与页面内存令牌验证 |
| 五 | TF-IDF450/80切块、当前课程Top3检索、System/User、引用检查与拒答、SDK桥；真实模型最终验收进行中 |
| 报告与ZIP | 正在编制、逐页QA与实际解包检查，最终未宣称完成 |

## 决定记录
- 首次提交保留用户当时实际代码，不虚构日期或空提交；中文摘要带实验编号，root统一commit。
- 不处理团队项目；不复用作废项目业务成果；原始课程文件不改。
- 每名用户一个学生或教师角色、教师手动整理通知；不做聊天平台抓取、自动发送、复杂选课管理。
- TF-IDF为教学稀疏向量实现，不能称为神经网络embedding；模型引用编号检查仍需人工核对原文。
- 模型默认官方ChatGPT登录，API Key仅可选明确配置，不自动切换收费API。
- 模板无教师栏，不添加猜测的教师姓名。GitHub链接由本人推送后填写；远程PR与CI未执行如实写明。
- 原生WindowsSDK权限采用子进程覆盖，保留project/auth deny和实际canary探针；专用空cwd外置解决继承deny，child LOCALAPPDATA隔离无关CUA运行文件，不修改全局配置。

## 短规则
- 不输出.runtime秘密、完整哈希、token；实际秘密扫描在内存完成，仅记录检查结果。
- MySQL通过ASCII联接访问，配置UTF8无BOM；SQL显式执行，不启动重置。
- Windows重打JAR先停后端，npm ci前先停Vite，避免文件占用。
- 测试与实现先commit，验证后留证据；所有最终材料绑定实际commit。不得以HTTP桩冒充模型。

## 踩坑记录
- 初版用户测试强制重复预检查、缺失删除禁止SQL，超出外部标准；独立作者改为数据库反馈409/404，未改业务标准。另保存BCrypt目标污染失败与恢复通过证明。
- 运行JAR导致重打包占用；运行Vite导致npm ci原生模块EPERM。停止对应服务后通过，保留失败日志。旧65aff09中frontend成功文字先于结果已明确纠正，e3-local-ci-frontend.log才是当次实际通过证据。
- 学生非法写请求先MVC校验返回400，调整过滤器先权限拒绝403，再验证通过。
- SDK命令outputBytesCap在Windows不支持已去掉；原生根deny与split读写策略需实际探针验证，未通过时均没有模型调用。
- Windowsruntime权限扫描遇桌面CUA DLL文件占用；独立child LOCALAPPDATA避免无关扫描。项目父级deny使原空cwd无法进入，改项目专属外部空目录；PowerShell启动需五项OS环境，未继承秘密。

## 卡点
- 373c8db最终API、重启持久化、模型资料注入、UI正常与停服均通过；18页报告逐页核对通过。下一步源码ZIP实际解包构建及全新上下文独立review，随后harness final。

## 2026-10-08 本次磁盘恢复
- 恢复基线 HEAD 0a09ded，初始工作区干净；旧记录中的服务实际均未运行，已按现有脚本恢复 MySQL3307、后端8080、Vue5173和模型桥8787。未重新导入SQL或改动用户原有数据。
- ready及coverage实际通过11项；JDK17全量verify真实40项零失败，Vue生产构建与10项最终API冒烟通过，证据resume-*.log及resume-smoke/。
- 373c8db至恢复基线仅验收产物变化，代码、测试、配置、SQL和DOCX完全未变；旧模型、重启、截图和18页文档证据继续适用，绑定核对见resume-version-check.json。本轮另抽查报告16/18页，无版式缺陷。
- 本轮没有重复真实模型调用；模型桥健康仅表示HTTP启动，真实模型通过结论仍基于此前完整SDK和模型证据。
- 待完成：独立review原文、主代理验收报告、harness final、最终ZIP实际刷新与解包构建、收尾提交。
