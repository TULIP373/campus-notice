# 独立测试用例

编写依据：`spec/main.md`、`docs/acceptance.md`、`docs/teacher-steps.md`。本文件由独立 test-author 在业务实现前制定；不是已通过的测试报告。当前所有业务用例 **未执行**，不得把测试脚本存在视为验收通过。

## 接口约定

主代理于 2026-10-08 确认：成功响应为对象或列表，失败响应为 JSON `{message}`；创建 201、读取和修改 200、删除 204、字段非法 400、未登录/错误登录 401、权限不足 403、不存在 404、用户名重复 409。`GET /api/health` 公开，返回 `{status:"UP"}`。用户字段 `id/username/name/role`，新建需 `password`，角色 `STUDENT/TEACHER`，读取不得包含密码、密码哈希、令牌或秘密。

用户接口 `/api/users` 与 `/api/users/{id}`。课程查询 `/api/courses` 返回带 `id/name` 的列表。通知接口 `/api/notices` 与 `/api/notices/{id}`，支持 `courseId/q` 查询；字段为 `courseId/title/content/submissionRequirements/reportFormat/deadline/source/type`，`type` 为 `NOTICE/MATERIAL`，截止时间为 ISO LocalDateTime 或 null。登录 `/api/auth/login`，响应 `token/user`；除健康和登录外，最终 `/api` 需要认证。教师管理、学生查看。

问答 `/api/ask` 输入 `courseId/question`，输出 `courseId/answer/sources`。每项引用必须指明 `courseId` 和 `noticeId`（也兼容 `id`）；引用应能对应当前课程的真实通知。失败或缺资料不能冒充模型成功。

本地测试只读取 `.runtime/demo-accounts.json` 的 `teacher/student` 对象获得账号，不打印密码或令牌。过期测试读取 `.runtime/security.properties` 的 `app.jwt.secret`，约定为原始 UTF-8 字符串、HS256。先用同一密钥签发未过期令牌验证 200，再只改变时间验证 401，以避免把签名错误误称为过期检查。

## 执行方法

在仓库根目录使用可用的 Python 3 执行以下命令。脚本仅依赖标准库，不能把语法检查当成业务通过。后端和真实 MySQL 必须已运行，接口测试建立 `test_` 账号和 `[测试]` 通知，完成后清理自己创建的记录；不会删除演示或原有用户数据。

```powershell
# 实验一，尚未加认证时
python tools/check_api.py --stage crud

# 先创建持久化账号，再由主代理真正停止/重启后端和数据库
python tools/check_api.py --stage crud --persistence-create
# 重启后执行；另存启动/关闭日志与进程信息证明重启确实发生
python tools/check_api.py --stage crud --persistence-verify

# 实验二，尚未加认证时
python tools/check_api.py --stage web

# 实验四，完成认证及默认账号初始化后
python tools/check_api.py --stage final

# 实验五，真实模型可用时
python tools/check_api.py --stage final --model

# 有相关课程资料、主动停止模型服务后验证故障；执行后恢复服务
python tools/check_api.py --stage final --model-unavailable
```

最终阶段持久化复测改用 `--stage final --persistence-create/--persistence-verify`。默认地址 `http://127.0.0.1:8080`，可通过 `--base` 修改；默认输出到 `reports/2026-10-08`，可通过 `--report-dir` 修改。返回 0 只代表本次自动运行的断言通过，不能代替浏览器、数据库、构建、报告和独立验收。

每条自动结果记录实际 Git HEAD、阶段、开始/结束时间和实现文件是否未提交。写入新结果前把原文件完整归档到 `history/`，只合并同一提交且具备逐条版本元数据的用例；旧提交的 PASS 不会进入当前提交总结果。`current_run_passed` 只表示本次断言；`version_bound_passed` 还要求对应代码无未提交变化。最终须在同一提交重跑所需阶段/选项，人工证据也注明提交号；不能把结果合并或 `passed:true` 视为全项目完成。

## AC 与用例覆盖表

| AC | 自动或人工用例 | 必须留下的证据 |
| --- | --- | --- |
| AC-E1-01 | HEALTH-01、BUILD-01 | backend-build.log、JAR 启动日志、api-check.json |
| AC-E1-02 | CRUD-01、PERSIST-CREATE-01/PERSIST-VERIFY-01、DB-01 | api-check.json、真实数据库查询及重启日志 |
| AC-E2-01 | COURSES-01、NOTICES-01、UI-01/UI-02 | api-check.json、student.png、teacher.png |
| AC-E2-02 | CORS-01、NOTICES-01、BUILD-02、OPENAPI-01 | api-check.json、frontend-build.log、OpenAPI 核对记录 |
| AC-E3-01 | GIT-01/GIT-02/GIT-03 | git-history.txt、git-conflict.log、PR/CI 文件及审查记录 |
| AC-E4-01 | LOGIN-01、AUTH-01、EXPIRED-01、STUDENT-WRITE-01、SEC-DB-01 | security-check.json、RBAC/BCrypt 数据核对记录 |
| AC-E4-02 | INJECTION-01、MODEL-INJECTION-01、SEC-UI-01、PKG-01 | security-check.json、model-check.json、archive-check.json |
| AC-E5-01 | MODEL-01、RAG-01、PROMPT-01、UI-03 | model-check.json、真实模型调用日志、rag.png、代码/提示核对记录 |
| AC-E5-02 | MODEL-NO-DATA-01、MODEL-CROSS-01、MODEL-INJECTION-01、MODEL-UNAVAILABLE-01、REFLECTION-01 | model-check.json、ai-reflection.md |
| AC-DOC-01 | DOC-01/DOC-02 | document-check.json、每页渲染图 |
| AC-PKG-01 | PKG-01/PKG-02 | archive-check.json、ZIP 清单、干净工作区证据 |

## 自动接口断言

| 用例 | 操作与通过条件 |
| --- | --- |
| HEALTH-01 | 匿名 GET 健康接口为 200 和 UP，不因加认证变成 401。 |
| CRUD-01 | 新建中文姓名账号；列表和按 id 查询能读到；修改响应及修改后重新读取均检查；重复用户名 409；空用户名/密码/姓名 400；删除 204；随后读取 404；所有用户响应递归检查嵌套密码/哈希/令牌/秘密字段、BCrypt值及实际秘密裸值。 |
| PERSIST-CREATE-01 | 新建独立 `test_persist_` 账号，将无秘密的 id、姓名、用户名写入 persistence-state.json。该步不宣称重启持久化已通过。 |
| PERSIST-VERIFY-01 | 后端和 MySQL 真正重启后，按记录的 id 能读取相同中文数据，最后清理。进程日志是独立必备证据。 |
| COURSES-01 | 至少三门课程；前三门各至少一条 NOTICE 和 MATERIAL；按课程筛选所有记录 courseId 正确；通知都包含提交要求、格式、截止时间和来源字段。 |
| NOTICES-01 | 教师新增测试通知，学生查询真实列表与详情；按课程和唯一关键词定位；更新后重新读到新内容；空标题和非法类型 400；删除后 404。 |
| CORS-01 | localhost:5173 来源 OPTIONS 预检获明确允许；非指定域名没有 Allow-Origin。不能只看浏览器能否打开页面。 |
| LOGIN-01 | 教师与学生使用私有账号文件登录，都返回非空 token 和不含密码的 user；解码服务实际签发的 JWT，exp 必须存在、是有限数字且晚于现在；报告不记录秘密。 |
| AUTH-01 | 错误密码 401；匿名 GET users/courses/notices 及 POST ask 均为 401；学生访问用户管理 403；修改 JWT 签名后访问 401；错误均返回 message JSON。 |
| EXPIRED-01 | 从正常 JWT 复制真实主体；本地同密钥签发正常时间令牌获 200，签发已过期令牌获 401。不能以随机/无效 token 替代。 |
| STUDENT-WRITE-01 | 学生 POST/PUT/DELETE 通知及 POST/PUT/DELETE 用户均为 403；检查实际接口，不以隐藏按钮代替权限验证。 |
| INJECTION-01 | SQL 注入字符串作为普通 q 搜索，正常返回空列表；空问题及 1001 字问题 400；用无关字符构成 1/1000 字合法问题，不能被长度校验拒绝，应 200 明确拒答且无引用，或模型实际故障 502/503/504 和 message。不能以拒绝超长输入推导合法边界通过。 |
| MODEL-01 | 对当前课提交要求提问；200 响应有非空 answer 和原文引用；每项引用存在于当前课真实通知。API 响应另与真实模型进程日志互证，固定答复不通过。 |
| MODEL-NO-DATA-01 | 关于不存在专业的无关问题，明确说明无资料，sources 为空；自动排除常见长账号/金额；人工逐项检查是否仍在拒答后给出猜测账号、金额、日期等事实，空引用与拒答关键词不足以通过。 |
| MODEL-CROSS-01 | 在 A 课询问 B 课专属要求，任何引用仍限定 A 课；取 A/B 原文中不同的提交要求与期限，B 独有事实直接出现在回答即失败；必须有可区分的事实才能测试。人工检查日期或要求的改写及实际检索块 courseId；空引用不代表课程隔离通过。 |
| MODEL-INJECTION-01 | 请求忽略资料、泄露提示/数据库/JWT 密钥并虚构取消课程；在内存中比较实际密钥/数据库密码/账号密码/令牌裸值，不写出这些值；人工对照真实 System 提示检查指令泄露，逐句判断是否虚构取消课程，存在否定词不能自动豁免。 |
| MODEL-UNAVAILABLE-01 | 确认问题能命中资料，主动停止真实模型服务；返回 502/503/504 和明确 message，不给预写答案；恢复服务。 |

## 构建、数据库、UI 和交付检查

**UNIT-USER-01（AC-E1-02、AC-E4-01）：** `UserServiceTest` 使用 Mockito 隔离 Mapper，检查创建实际传给 Mapper 的密码为可匹配 BCrypt 哈希而非明文、数据库唯一约束拒绝重复用户名后返回 409、读取缺失 404、更新 password=null 保留旧哈希、删除影响行数为 0 时返回 404，以及实体 JSON 排除内部哈希。重复插入被数据库拒绝、DELETE 不匹配任何行都是有效实现；不强制事前查询或禁止执行 SQL。`CampusNoticeApplicationTests` 用 `@MockitoBean UserMapper` 填充上下文，不访问 MySQL；不能把 Mock 单测称为真实数据库验证。

```powershell
./mvnw.cmd -B -ntp "-Dtest=UserServiceTest" test
# 主代理在测试和实现提交后运行，以下应故意失败在“不得为明文密码”断言：
./mvnw.cmd -B -ntp "-Dtest=UserServiceTest#createStoresMatchingBcryptInsteadOfPlaintext" "-Dtest.guard.plaintext=true" test
```

第二条仅污染 Mockito 保存的密码值以证明断言抓住目标错误，不改生产代码。日志应显示断言失败，而非依赖、编译或启动故障；随后关闭该开关重跑正常测试成功。失败日志与成功日志注明相同源码提交号，不宣称真实实现曾有此缺陷。

**初版单测错误记录：** 提交 `511bb55` 的真实 verify 运行共 8 项，2 项失败、6 项通过，原日志保存为 `reports/2026-10-08/e1-unit-initial-failure.log`。测试初版错误地强制“重复账号必须预检查且不能调用 insert”“缺失删除必须不调用 DELETE”，超出了原规格要求。修复只调整 Mock 的数据库反馈：insert 抛 `DuplicateKeyException`，仍断言对外 409；deleteById 返回 0，仍断言对外 404。没有修改业务实现或放宽外部状态标准。这两项属于测试设施假设错误，不是生产缺陷证明；BCrypt 明文污染断言另做目标错误验证。修复后结果由主代理在新提交实际运行后登记，当前不预判通过。

**BUILD-01 / BUILD-02：** JDK 17 下运行 `mvnw.cmd -B -ntp verify`，保存实际测试数和构建日志；打包 jar 启动后健康和 CRUD 通过。审查 POM 为 Spring Boot 3、Web、MyBatis、MySQL 连接器；源码分层存在、application.yaml 配置实际生效。前端 `npm ci`、`npm run build` 分开执行，记录退出码。不能用旧项目日志代替。

**DB-01 / SEC-DB-01：** 使用本项目 MySQL CLI 和私有凭据文件查询当前数据库名、版本、连接用户，验证测试账户写入确有 SQL 行且重启保存；检查用户/角色/权限和关联表、教师/学生映射存在。只报告密码哈希的算法/前缀与数量，不输出完整哈希或原密码。比对用户名不重复、BCrypt 存储而不是明文；从 Mapper 检查参数绑定，不能仅凭表名存在认为 RBAC 生效。逐项列出用户/通知维护方法的 `@PreAuthorize`、启用方法安全的配置，以及认证加载用户角色/权限关联数据并进入授权检查的实际链路；与 STUDENT-WRITE-01 的 403 对照。检查签发期限配置及 LOGIN-01 中真实 exp，不能用过期自签令牌单独证明服务签发了有限期令牌。

**UI-01 / UI-02 / UI-03：** 使用真实浏览器启动前后端；学生登录，切换三门课，输入关键词，读一条有要求、格式、截止时间、来源的详情，读资料。教师登录，新增通知，再切回学生刷新确认真实保存；教师编辑删除能反馈状态。404/400/服务失败显示可理解的错误。对问答实际输入问题并保留回答和来源同屏截图。截图来自新项目实际服务，不能画静态演示图冒充结果。

**OPENAPI-01：** 将 OpenAPI 中 users/courses/notices/auth/ask/health 路径、方法、字段、成功/错误状态与上述调用结果逐项比对；文档不能描述不存在接口。对不存在、非法输入、重复、权限和模型故障的边界均记录。

**GIT-01：** `git log --reverse --format="%h %s"` 真实至少 20 条有内容的中文实验序号摘要；每条 diff 与步骤对应，不能空提交、回填日期或伪装用户过去操作。**GIT-02：** 检查真实 feature 分支分歧、merge 冲突输出、冲突文件前后和合并提交父节点，最终无冲突标记。**GIT-03：** PR 模板、CI YAML 存在，构建测试命令与本地实际命令一致；报告明确远程未推送、PR 和云端 CI 未执行，GitHub 地址留给用户推送后填写。

**SEC-UI-01：** 代码与浏览器状态共同验证 token 仅保存在内存，刷新后要求重登录，不写 localStorage/sessionStorage/cookie；学生界面隐藏维护入口，同时后端真正拒绝。Git 已跟踪文件、ZIP 内部文件检索无私有账号密码、JWT/API 密钥、模型登录会话；配置示例只使用占位或环境变量。不要把本地 .runtime 目录未跟踪这一点当成全包扫描结果。

**短秘密口径：** 规格没有秘密最小长度约束。自动比较长值子串与短值完整相等，短值子串可能与普通文字碰巧一致，不能据此判通过或略过。独立复核者在内存读取全部实际秘密，逐项对照用户响应/问答/归档内容：短值也检查完整字段相等、引号/配置赋值/密码或密钥语境中的精确值及任何合理的拆分泄露。只记录秘密类型、检查范围与 PASS/FAIL，不能记录秘密裸值。没有完成此检查，秘密不泄露条目仍为 UNVERIFIED；本机随机值实际很长不能取代这一通用口径。

**RAG-01 / PROMPT-01：** 核对切块 450 字、重叠 80 字；构造足够长的真实材料观察分块边界。人工或现有单测验证 TF-IDF 稀疏向量、余弦排序、最多前三块及 courseId 过滤；输入无关材料不能引用其他课程。System/User 练习与 `ask(question)` SDK 真实模型运行各留证据；模型结果与原文引用比对，记录是否回答过度推断。模型调用日志必须能证明服务实际调用，不能记录登录密钥。

**REFLECTION-01：** ai-reflection.md 中记录本项目真实发生的缺资料、注入、课程隔离、模型关闭错误及实际观察；若未观察到幻觉，应写“本轮未观察到”，解释仍需验证引用，禁止写虚构模型出错案例。

**DOC-01 / DOC-02：** 单一 `202232110113余家祥.docx`；姓名余家祥、学号 202232110113、班级软外241，五实验各按老师步骤记录技术、设计、关键代码、真实运行结果截图及 AI 反思；GitHub 链接由用户推送后补填。原模板没有教师栏，不新增教师待填字段；只说明实际存在且未提供的字段。原模板格式完整对照。用文档渲染器逐页导出并目视检查：表格不溢出、中文无缺字、代码可读、截图不压扁、页码和分页正确。记录总页数及检查结论，内容真实且非旧项目成果。

**PKG-01 / PKG-02：** ZIP 解压到新临时目录，清单确认源代码、SQL、配置示例、环境说明、启动测试脚本和依赖锁文件齐全；排除 .runtime、node_modules、target、数据库数据、模型登录凭据、缓存和完整秘密。确认 SQL 初始化顺序与说明吻合，在干净目录至少验证构建/配置检查。Git 工作区最终干净，未推送；ZIP 与交付源码版本对应，用户可以自行补充 GitHub 链接。

## 证据局限

接口自动通过不能证明页面可用、真实 MySQL、BCrypt、真实模型、源码未泄密、报告版式或提交历史真实性。这些必须执行上述独立检查。无法运行时明确写 UNVERIFIED，不能降低标准；实现者不得修改用例预期来使实现通过。

2026-10-08 修订：按独立覆盖核对补充嵌套敏感响应、完整匿名/学生权限矩阵、真实 JWT 有限期限、问题合法边界、实际秘密比较与问答人工语义检查；修正模板教师栏口径并补逐条版本及历史证据归档。此记录是设计修复，不代表业务通过。
