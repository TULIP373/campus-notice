# 进度记录

## 当前状态
- 五个个人实验及个人项目本地交付已完成，用户已确认范围；没有处理团队项目，没有push或提交学习通。
- 11项AC全部PASS；独立review和代码质量复核通过，原文docs/review-record.md；主代理报告docs/acceptance-report.md；harness final真实通过11项。
- 应用/测试/配置/SQL与原完整证据保持一致。本轮重跑40项Java测试、Vue构建及10项真实API检查通过；修复并验证报告代码摘录，源行一致性由旧16段失败到新79段全部匹配。
- 单一DOCX为deliverables/202232110113余家祥.docx，共18页；修复后7个变化页主代理及独立reviewer均分批查看通过，其他11张PNG与此前逐页验收图字节一致，目录页码未变。
- 修订源码ZIP已真实解包并通过40项Java测试和npm ci/build。终版在相同已审源码/DOCX上仅增补验收产物，实际刷新、逐文件解包核对、排密和增量比较后随收尾提交交付；最终SHA见reports/2026-10-08/archive-check.json。
- 实际服务已恢复：MySQL3307、后端8080、Vue5173、模型桥8787。模型健康not_checked仅表示HTTP启动；本轮未重跑模型，真实生成依据仍为未变化应用的原模型/SDK证据。
- 已知未执行：兼容API Key模式、远程PR、云端CI及学生本人理解核验；报告如实说明。GitHub链接待本人推送后填写，账号和秘密配置仅在忽略的.runtime。
- 下一步：交付后由本人阅读报告和关键代码，按需要自行推送远程并填写GitHub链接。无需继续开发或补验收。

## 里程碑
| 实验 | 实际状态 |
| --- | --- |
| 一 | Java17/SpringBoot3/MyBatis/MySQL分层；真实用户CRUD、8项初始单测与重启持久化通过 |
| 二 | Vue/Axios三课程通知及资料、教师真实增改删、CORS与接口文档、浏览器联调和生产构建 |
| 三 | feature/commit-convention真实同一行冲突，dec915d双父合并；PR模板及CI配置；本地构建命令已执行，远程未执行 |
| 四 | MySQL角色权限、BCrypt登录、JWT、过滤器及PreAuthorize；登录/401/403/篡改/过期与页面内存令牌验证 |
| 五 | TF-IDF450/80切块、当前课程Top3检索、System/User、引用检查与拒答、SDK桥；真实模型、资料内注入、拒答及停服证据验收通过 |
| 报告与ZIP | 18页报告代码摘录修复并视觉复核通过；源码ZIP真实解包构建和终版增量校验通过 |

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
- 无未解决验收阻断。首轮报告硬换行缺陷已经修复，失败原文和修复前后断言均保留，未降低标准。

## 2026-10-08 本次磁盘恢复
- 恢复基线 HEAD 0a09ded，初始工作区干净；旧记录中的服务实际均未运行，已按现有脚本恢复 MySQL3307、后端8080、Vue5173和模型桥8787。未重新导入SQL或改动用户原有数据。
- ready及coverage实际通过11项；JDK17全量verify真实40项零失败，Vue生产构建与10项最终API冒烟通过，证据resume-*.log及resume-smoke/。
- 373c8db至恢复基线仅验收产物变化，代码、测试、配置、SQL和DOCX完全未变；旧模型、重启、截图和18页文档证据继续适用，绑定核对见resume-version-check.json。本轮另抽查报告16/18页，无版式缺陷。
- 本轮没有重复真实模型调用；模型桥健康仅表示HTTP启动，真实模型通过结论仍基于此前完整SDK和模型证据。
- 收尾：独立review已PASS并原样保存，主代理11项报告全部PASS，harness final已通过；终版仅刷新验收产物、真实校验并本地提交。
- 独立review在904a577判AC-DOC-01失败：textwrap默认硬切破坏代码标识符和字符串。已移除硬切，仅Word软折行；旧报告源行一致性断言88段中16段不匹配，新报告79段全部匹配，失败/恢复证据code-excerpt-check.json。重新导出18页，七张改变页面已分批目视通过，另十一页PNG字节不变，目录页码未变。初审原文保留history/review-904a577-FAIL.md。

- 最终复核：reviewer独立重建13处摘录，79段按顺序/路径/完整源码行匹配；亲自查看全部7个改变页，另11页字节不变；代码质量第二阶段无阻断。review绑定f679beb，后续提交仅验收产物。
- 解包构建：修订300项ZIP实际解包，JDK17 verify40项零失败/错误，npm ci和生产构建通过；终版源码、生成器和DOCX与该构建包保持逐字节一致。
- 辅助核对踩坑：Windows Python默认GBK解码Git UTF-8及Git默认路径转义造成临时证据脚本断言错误；显式UTF-8和core.quotepath=false后核对通过，未更改源码或验收标准。
- 收尾证据：harness-final.log、final-version-binding.json、resume-archive-build-check.json及archive-check.json；终版ZIP包括独立复核和最终验收报告，只有自引用archive-check.json不入包。最终提交后再运行final并核对工作区干净。
