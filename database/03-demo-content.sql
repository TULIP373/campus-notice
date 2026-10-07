-- 显式执行此脚本才录入演示数据，不代表教师真实发布了通知。
INSERT INTO courses (name, description) VALUES
('软件项目实训（二）', '演示课程：用简化课程通知平台完成五个个人实验。'),
('数据库原理', '演示课程：关系模型、SQL、事务与索引基础。'),
('软件测试', '演示课程：测试用例、边界分析与缺陷报告。')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT id,'[演示] 五个个人实验提交说明',
'这是一条演示通知，根据项目作者已提供的提交要求整理，用于体验集中查看信息。个人项目完成五个实验：搭建Java Web基础项目，完成Vue与REST接口交互，练习Git协作流程，加入登录权限控制，接入大模型并进行课程资料检索问答。团队项目不在本演示范围内。五个实验报告合并为一个文档，文件名使用学号和姓名。源码、数据库SQL与环境配置说明放入压缩文件；还需提交GitHub链接，由本人最终推送后填写。具体上交时间没有收到确认，界面应显示待教师通知，不能自行编造日期。查看通知时先核对信息来源，再核对最新要求。这里展示的账号、页面和课程记录只用于本机演示，不是学校正式教务平台。',
'五个个人实验报告合并为一个文档；源码、数据库配置、环境配置说明打包压缩；GitHub链接由本人推送后填写。',
'DOCX文档，文件名使用学号和姓名；五实验写在同一份报告。',NULL,'演示数据：根据用户提供的提交说明整理','NOTICE'
FROM courses WHERE name='软件项目实训（二）' AND NOT EXISTS
(SELECT 1 FROM notices n WHERE n.course_id=courses.id AND n.title='[演示] 五个个人实验提交说明');

INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT id,'[演示资料] Web项目分层与接口入门',
'课程资料关键字：实训分层。Spring Boot负责启动和组织后端服务，Java17是编译运行环境，Maven管理依赖与构建。Entity是数据库记录的Java表示，用户实体对应用户表中的一行。Mapper把数据库操作写成参数绑定的SQL，不能用用户输入拼接SQL。Service保存业务规则，例如密码哈希、检查用户是否存在、避免重复用户名。Controller接收浏览器发来的HTTP请求并调用Service，将Java对象作为JSON返回。用户创建使用POST，查询使用GET，修改使用PUT，删除使用DELETE。HTTP201代表创建成功，204代表删除成功且没有响应体，400表示输入不合要求，404表示目标记录不存在，409表示用户名重复。前端Vue展示课程与通知，Axios发送HTTP请求，前后端分别运行。浏览器跨域访问需要服务器允许指定来源，不能为了省事对所有网站放行。MySQL把数据持久保存到磁盘，后端重启后仍应读取到之前创建的记录。测试应实际连接MySQL验证中文、增删改查和重启持久化，内存假数据不能证明数据库功能。Git把真实修改分次提交，每次摘要标明实验编号，让老师能看到步骤。密码必须保存BCrypt哈希，浏览器返回内容中不能包含密码或哈希。登录令牌应有限期，教师才能维护通知，学生只能查询。资料问答先按课程筛选，把原文切成短块，用向量相似度检索相关片段，再让模型根据这些片段作答并引用来源；资料没有的信息应明确说不知道。',
'学习资料，无单独上交要求。','阅读原文，理解Entity、Mapper、Service、Controller职责。',NULL,'演示资料：作者编写的Web基础说明','MATERIAL'
FROM courses WHERE name='软件项目实训（二）' AND NOT EXISTS
(SELECT 1 FROM notices n WHERE n.course_id=courses.id AND n.title='[演示资料] Web项目分层与接口入门');

INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT id,'[演示] 图书借阅数据库设计作业',
'本通知完全用于演示，不是老师真实布置的作业。数据库原理课程专属题目为图书借阅数据库设计。请绘制图书、读者、借阅记录的关系模型，编写建表SQL和不少于三条查询，解释主键和外键。演示截止时间为2026年11月10日22点。其他课程的提交时间和格式不适用本作业。',
'数据库课演示专属要求：图书借阅ER图、建表SQL、三条查询，打包为图书借阅设计.zip。',
'PDF设计说明和.sql脚本放入同一个ZIP。','2026-11-10 22:00:00','演示数据：作者虚构的数据库课作业','NOTICE'
FROM courses WHERE name='数据库原理' AND NOT EXISTS
(SELECT 1 FROM notices n WHERE n.course_id=courses.id AND n.title='[演示] 图书借阅数据库设计作业');

INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT id,'[演示资料] 主键外键事务基础',
'课程资料关键字：图书借阅。关系数据库把数据放在表中，一行表示一条记录，一列表示一种属性。主键唯一标识记录，不能重复。外键让借阅记录引用真实存在的读者和图书。SQL的SELECT查询数据，INSERT新增，UPDATE修改，DELETE删除。WHERE限定条件，缺少条件的修改或删除可能影响整个表。参数绑定把输入当作数据，不让恶意输入改变SQL结构。事务把多次修改作为一个整体，例如借阅记录创建和图书库存减少应该一起成功，失败时一起回滚。索引帮助按条件查找，常用查询字段可以考虑建立索引；索引也占空间，修改记录时要维护，所以不是越多越好。建表前先弄清每张表的职责及相互关联，不要把全部信息塞在一张表中。数据库课程演示作业的主线是图书借阅关系模型，与Web分层和软件测试缺陷报告属于不同课程范围。',
'学习资料，无单独上交要求。','阅读SQL示例与关系模型。',NULL,'演示资料：作者编写的数据库基础说明','MATERIAL'
FROM courses WHERE name='数据库原理' AND NOT EXISTS
(SELECT 1 FROM notices n WHERE n.course_id=courses.id AND n.title='[演示资料] 主键外键事务基础');

INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT id,'[演示] 登录边界测试作业',
'本通知完全用于演示，不是老师真实布置的作业。软件测试课程专属作业是登录边界测试。选择一个登录表单，列出正常、空输入、错误密码、过长输入和无权限访问等场景。记录预期与实际结果，给出一份缺陷报告。演示截止时间为2026年11月18日18点。不要把数据库课的图书借阅作业混入本课程报告。',
'测试课演示专属要求：登录边界测试用例表、执行结果和一份缺陷报告。',
'XLSX测试用例表和DOCX缺陷说明放入登录边界测试.zip。','2026-11-18 18:00:00','演示数据：作者虚构的软件测试课作业','NOTICE'
FROM courses WHERE name='软件测试' AND NOT EXISTS
(SELECT 1 FROM notices n WHERE n.course_id=courses.id AND n.title='[演示] 登录边界测试作业');

INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT id,'[演示资料] 等价类与边界值测试',
'课程资料关键字：登录边界。测试用例需要写清前置条件、操作步骤、输入数据、预期结果和实际结果，方便别人复现。等价类把输入分成有效和无效类别，例如正确用户名和不存在的用户名。边界值关注允许范围两端及刚好越界的数据，例如长度要求8至72时检查7、8、72、73。正常登录成功不能证明权限安全，还应验证错误密码拒绝、未登录401、无权限403。测试结果必须来自真正执行的程序，不可以直接把预期结果复制成实际结果。缺陷报告要有能重现问题的步骤、期待行为、实际行为和环境信息。修复后重新执行原用例以验证问题消失，再检查附近功能没有受到影响。这是回归测试。自动化测试适合反复验证稳定逻辑，真实页面截图帮助说明用户看到的界面。软件测试课演示作业重点是登录边界用例和缺陷说明，与数据库课程的图书借阅关系模型不同。',
'学习资料，无单独上交要求。','阅读测试设计示例，理解预期和实际的区别。',NULL,'演示资料：作者编写的软件测试基础说明','MATERIAL'
FROM courses WHERE name='软件测试' AND NOT EXISTS
(SELECT 1 FROM notices n WHERE n.course_id=courses.id AND n.title='[演示资料] 等价类与边界值测试');
