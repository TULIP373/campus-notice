-- 旧版演示数据升级：仅更新旧种子通知，不覆盖老师后续创建的内容。

START TRANSACTION;

UPDATE notices n JOIN courses c ON c.id=n.course_id SET title='课程项目提交要求',content='各位同学：

本学期课程项目统一采用“课程通知平台”作为实践题目，个人完成前后端开发，并能说明自己的实现过程。报告中按实验一至五依次记录基础项目搭建、前后端交互、Git 协作、登录权限和课程资料问答。

请将实验一至五写在同一份报告中，不要拆成多个项目分别提交。报告使用学号和姓名命名，正文要有关键代码说明、实际运行截图、问题记录和自己的分析。源码压缩包内附建表 SQL 和环境配置说明；项目仓库：https://github.com/TULIP373/campus-notice。

提交时间暂未确定，后续在课程群另行通知。先按附件中的目录检查材料，课堂演示时需要现场登录、查看通知、切换教师账号，并说明问答引用的来源。不要把本机账号密码、数据库密码或密钥放进提交包。

陈老师
10月8日',submission_requirements='完成课程通知平台，将实验一至五合并为一份报告；同时提交源码压缩包、数据库 SQL、环境说明和 GitHub 仓库链接。',report_format='DOCX 报告命名为“学号姓名.docx”；源码、SQL、环境说明打包为“学号姓名_源代码.zip”。',deadline=NULL,source='陈老师 · 课程群',type='NOTICE' WHERE c.name='软件项目实训（二）' AND n.title='[演示] 五个个人实验提交说明' AND n.source LIKE '演示%';

UPDATE notices n JOIN courses c ON c.id=n.course_id SET title='课程项目提交要求参考资料',content='陈老师：

一、报告结构
封面填写班级、学号、姓名；正文按实验一至五排列，每个实验包含目的、环境、步骤、结果和问题分析。
二、项目材料
源代码、数据库建表 SQL、环境说明和运行方法放在同一压缩包。报告单独提交。GitHub 链接应指向本人完成推送的仓库。
三、课堂演示
先演示学生查看通知和附件，再演示教师维护自己的课程，最后演示 AI 根据原文回答并展示引用。
四、提交检查
报告命名为学号姓名.docx，源码包命名为学号姓名_源代码.zip。不得提交真实账号密码和密钥。具体截止时间待课程群通知。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。',submission_requirements='阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。',report_format='PDF 参考附件，可查看原文或下载保存。',deadline=NULL,source='陈老师 · 课程资料',type='MATERIAL' WHERE c.name='软件项目实训（二）' AND n.title='[演示资料] Web项目分层与接口入门' AND n.source LIKE '演示%';

UPDATE notices n JOIN courses c ON c.id=n.course_id SET title='图书借阅数据库设计作业',content='同学们好：

本次作业设计一个小型图书借阅数据库，至少包含图书、读者、借阅记录三类实体。请先画 ER 图，再转换为关系模式，明确主键、外键以及图书和借阅记录之间的联系。

SQL 文件应能在 MySQL 8 上执行，包含建表、测试数据和不少于六条查询，其中至少有连接查询、分组统计和逾期借阅查询。请实际执行并截取结果，不要只写 SQL 而不验证。借阅和归还涉及库存变化时，应说明如何使用事务。

10月20日22:00前上传课程平台。提交内容和评分比例见附件；文件不齐的同学先对照清单补全，有疑问在下次实验课提出。

林老师
10月8日',submission_requirements='提交图书借阅 ER 图、建表 SQL、至少六条业务查询及运行截图，压缩包命名为“学号姓名_数据库设计.zip”。',report_format='设计说明使用 PDF，SQL 单独保存为 UTF-8 的 .sql 文件，截图放入设计说明。',deadline='2026-10-20 22:00:00',source='林老师 · 课程群',type='NOTICE' WHERE c.name='数据库原理' AND n.title='[演示] 图书借阅数据库设计作业' AND n.source LIKE '演示%';

UPDATE notices n JOIN courses c ON c.id=n.course_id SET title='图书借阅数据库设计作业参考资料',content='林老师：

一、表结构要求
图书表包含图书编号、书名、作者和可借库存；读者表包含读者编号、姓名和联系方式；借阅表包含借阅编号、读者编号、图书编号、借出时间和应还时间。主键和外键必须完整。
二、查询清单
完成图书检索、读者借阅记录、当前未还记录、逾期列表、图书借阅次数统计和读者借阅排行六条查询。
三、评分比例
关系模型与约束占40%，SQL 正确性占40%，运行结果和说明占20%。
四、提交
10月20日22:00前提交 PDF 设计说明和 UTF-8 SQL 文件，打包为学号姓名_数据库设计.zip。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。',submission_requirements='阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。',report_format='PDF 参考附件，可查看原文或下载保存。',deadline=NULL,source='林老师 · 课程资料',type='MATERIAL' WHERE c.name='数据库原理' AND n.title='[演示资料] 主键外键事务基础' AND n.source LIKE '演示%';

UPDATE notices n JOIN courses c ON c.id=n.course_id SET title='登录功能测试与缺陷报告',content='各位同学：

本周围绕登录功能进行测试设计。请从有效登录、错误密码、空输入、长度边界、未登录访问和角色权限六个方面设计用例，总数不少于十二条。

每条用例要写清前置条件、输入、步骤、预期结果和实际结果。至少选择一个实际发现的问题写成缺陷报告，附可复现步骤、环境和截图；如果没有发现缺陷，请写明已执行的范围和未覆盖的部分，不要编造缺陷。

本次提交截止到10月23日18:00。附件给出了用例字段、缺陷报告结构及评分要求，提交前请检查“实际结果”一列确实来自运行。

周老师
10月8日',submission_requirements='设计至少十二条登录测试用例，记录执行结果；提交测试用例表和一份包含复现步骤的缺陷报告。',report_format='测试用例表可使用 XLSX；缺陷报告使用 DOCX，两者打包为“学号姓名_登录测试.zip”。',deadline='2026-10-23 18:00:00',source='周老师 · 课程群',type='NOTICE' WHERE c.name='软件测试' AND n.title='[演示] 登录边界测试作业' AND n.source LIKE '演示%';

UPDATE notices n JOIN courses c ON c.id=n.course_id SET title='登录功能测试与缺陷报告参考资料',content='周老师：

一、用例字段
编号、功能点、前置条件、步骤、输入数据、预期结果、实际结果、是否通过和备注。至少十二条用例，必须覆盖空输入、错误密码和长度边界。
二、权限场景
未登录访问应被拒绝；学生不能发布通知；任课教师不能修改其他教师的通知。
三、缺陷报告
包含标题、严重程度、测试环境、复现步骤、预期行为、实际行为、截图和回归结果。无真实缺陷时提交测试结论与覆盖范围。
四、评分与提交
用例设计40%，实际执行与证据40%，报告条理20%。10月23日18:00前提交用例表和缺陷报告。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。',submission_requirements='阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。',report_format='PDF 参考附件，可查看原文或下载保存。',deadline=NULL,source='周老师 · 课程资料',type='MATERIAL' WHERE c.name='软件测试' AND n.title='[演示资料] 等价类与边界值测试' AND n.source LIKE '演示%';

DELETE FROM notices WHERE title='[测试] 浏览器联调通知' AND source='本地演示：教师手动录入';

COMMIT;

-- 课堂演示数据。通知和教师姓名为模拟内容，实际要求以任课教师发布为准。

START TRANSACTION;

INSERT INTO courses(name,description) VALUES
('软件项目实训（二）','Java Web 项目开发、前后端联调、权限控制与课程资料问答。'),
('数据库原理','关系模型、SQL 查询、事务与索引，结合图书借阅场景练习。'),
('软件测试','测试设计、缺陷复现与回归，围绕登录及课程通知功能练习。'),
('Java程序设计','面向对象、集合、异常处理与文件读写。'),
('数据结构','线性表、树与图，重点练习实现过程和复杂度分析。'),
('计算机网络','协议分层、IP 地址与 TCP，结合抓包实验理解通信过程。'),
('操作系统','进程线程、调度与同步，结合生产者消费者模型实验。'),
('Web前端开发','HTML、CSS、Vue 组件与接口交互，练习课程信息页面。')
ON DUPLICATE KEY UPDATE description=VALUES(description);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'课程项目提交要求','各位同学：

本学期课程项目统一采用“课程通知平台”作为实践题目，个人完成前后端开发，并能说明自己的实现过程。报告中按实验一至五依次记录基础项目搭建、前后端交互、Git 协作、登录权限和课程资料问答。

请将实验一至五写在同一份报告中，不要拆成多个项目分别提交。报告使用学号和姓名命名，正文要有关键代码说明、实际运行截图、问题记录和自己的分析。源码压缩包内附建表 SQL 和环境配置说明；项目仓库：https://github.com/TULIP373/campus-notice。

提交时间暂未确定，后续在课程群另行通知。先按附件中的目录检查材料，课堂演示时需要现场登录、查看通知、切换教师账号，并说明问答引用的来源。不要把本机账号密码、数据库密码或密钥放进提交包。

陈老师
10月8日','完成课程通知平台，将实验一至五合并为一份报告；同时提交源码压缩包、数据库 SQL、环境说明和 GitHub 仓库链接。','DOCX 报告命名为“学号姓名.docx”；源码、SQL、环境说明打包为“学号姓名_源代码.zip”。',NULL,'陈老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='软件项目实训（二）' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='课程项目提交要求');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'课程项目提交要求参考说明.pdf','course-1-reference.pdf','一、报告结构
封面填写班级、学号、姓名；正文按实验一至五排列，每个实验包含目的、环境、步骤、结果和问题分析。
二、项目材料
源代码、数据库建表 SQL、环境说明和运行方法放在同一压缩包。报告单独提交。GitHub 链接应指向本人完成推送的仓库。
三、课堂演示
先演示学生查看通知和附件，再演示教师维护自己的课程，最后演示 AI 根据原文回答并展示引用。
四、提交检查
报告命名为学号姓名.docx，源码包命名为学号姓名_源代码.zip。不得提交真实账号密码和密钥。具体截止时间待课程群通知。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='软件项目实训（二）' AND n.title='课程项目提交要求'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'课程项目提交要求参考资料','陈老师：

一、报告结构
封面填写班级、学号、姓名；正文按实验一至五排列，每个实验包含目的、环境、步骤、结果和问题分析。
二、项目材料
源代码、数据库建表 SQL、环境说明和运行方法放在同一压缩包。报告单独提交。GitHub 链接应指向本人完成推送的仓库。
三、课堂演示
先演示学生查看通知和附件，再演示教师维护自己的课程，最后演示 AI 根据原文回答并展示引用。
四、提交检查
报告命名为学号姓名.docx，源码包命名为学号姓名_源代码.zip。不得提交真实账号密码和密钥。具体截止时间待课程群通知。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'陈老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='软件项目实训（二）' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='课程项目提交要求参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'课程项目提交要求参考说明.pdf','course-1-reference.pdf','一、报告结构
封面填写班级、学号、姓名；正文按实验一至五排列，每个实验包含目的、环境、步骤、结果和问题分析。
二、项目材料
源代码、数据库建表 SQL、环境说明和运行方法放在同一压缩包。报告单独提交。GitHub 链接应指向本人完成推送的仓库。
三、课堂演示
先演示学生查看通知和附件，再演示教师维护自己的课程，最后演示 AI 根据原文回答并展示引用。
四、提交检查
报告命名为学号姓名.docx，源码包命名为学号姓名_源代码.zip。不得提交真实账号密码和密钥。具体截止时间待课程群通知。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='软件项目实训（二）' AND n.title='课程项目提交要求参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'下次课项目进度检查','各位同学：

下次课请带电脑，准备展示登录、课程列表和通知详情；每人用三分钟说明一个已完成的功能和一个待解决的问题。暂时不收最终报告。

陈老师
10月8日','下次课请带电脑，准备展示登录、课程列表和通知详情；每人用三分钟说明一个已完成的功能和一个待解决的问题。暂时不收最终报告。','','2026-10-15 14:00:00','陈老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='软件项目实训（二）' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='下次课项目进度检查');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'图书借阅数据库设计作业','同学们好：

本次作业设计一个小型图书借阅数据库，至少包含图书、读者、借阅记录三类实体。请先画 ER 图，再转换为关系模式，明确主键、外键以及图书和借阅记录之间的联系。

SQL 文件应能在 MySQL 8 上执行，包含建表、测试数据和不少于六条查询，其中至少有连接查询、分组统计和逾期借阅查询。请实际执行并截取结果，不要只写 SQL 而不验证。借阅和归还涉及库存变化时，应说明如何使用事务。

10月20日22:00前上传课程平台。提交内容和评分比例见附件；文件不齐的同学先对照清单补全，有疑问在下次实验课提出。

林老师
10月8日','提交图书借阅 ER 图、建表 SQL、至少六条业务查询及运行截图，压缩包命名为“学号姓名_数据库设计.zip”。','设计说明使用 PDF，SQL 单独保存为 UTF-8 的 .sql 文件，截图放入设计说明。','2026-10-20 22:00:00','林老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='数据库原理' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='图书借阅数据库设计作业');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'图书借阅数据库设计作业参考说明.pdf','course-2-reference.pdf','一、表结构要求
图书表包含图书编号、书名、作者和可借库存；读者表包含读者编号、姓名和联系方式；借阅表包含借阅编号、读者编号、图书编号、借出时间和应还时间。主键和外键必须完整。
二、查询清单
完成图书检索、读者借阅记录、当前未还记录、逾期列表、图书借阅次数统计和读者借阅排行六条查询。
三、评分比例
关系模型与约束占40%，SQL 正确性占40%，运行结果和说明占20%。
四、提交
10月20日22:00前提交 PDF 设计说明和 UTF-8 SQL 文件，打包为学号姓名_数据库设计.zip。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='数据库原理' AND n.title='图书借阅数据库设计作业'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'图书借阅数据库设计作业参考资料','林老师：

一、表结构要求
图书表包含图书编号、书名、作者和可借库存；读者表包含读者编号、姓名和联系方式；借阅表包含借阅编号、读者编号、图书编号、借出时间和应还时间。主键和外键必须完整。
二、查询清单
完成图书检索、读者借阅记录、当前未还记录、逾期列表、图书借阅次数统计和读者借阅排行六条查询。
三、评分比例
关系模型与约束占40%，SQL 正确性占40%，运行结果和说明占20%。
四、提交
10月20日22:00前提交 PDF 设计说明和 UTF-8 SQL 文件，打包为学号姓名_数据库设计.zip。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'林老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='数据库原理' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='图书借阅数据库设计作业参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'图书借阅数据库设计作业参考说明.pdf','course-2-reference.pdf','一、表结构要求
图书表包含图书编号、书名、作者和可借库存；读者表包含读者编号、姓名和联系方式；借阅表包含借阅编号、读者编号、图书编号、借出时间和应还时间。主键和外键必须完整。
二、查询清单
完成图书检索、读者借阅记录、当前未还记录、逾期列表、图书借阅次数统计和读者借阅排行六条查询。
三、评分比例
关系模型与约束占40%，SQL 正确性占40%，运行结果和说明占20%。
四、提交
10月20日22:00前提交 PDF 设计说明和 UTF-8 SQL 文件，打包为学号姓名_数据库设计.zip。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='数据库原理' AND n.title='图书借阅数据库设计作业参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'实验课分组与数据准备','各位同学：

下次实验课练习连接查询。请提前在本机创建图书借阅测试库，每张表准备至少十条数据。课堂只检查本机运行结果，不额外提交报告。

林老师
10月8日','下次实验课练习连接查询。请提前在本机创建图书借阅测试库，每张表准备至少十条数据。课堂只检查本机运行结果，不额外提交报告。','','2026-10-12 08:00:00','林老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='数据库原理' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='实验课分组与数据准备');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'登录功能测试与缺陷报告','各位同学：

本周围绕登录功能进行测试设计。请从有效登录、错误密码、空输入、长度边界、未登录访问和角色权限六个方面设计用例，总数不少于十二条。

每条用例要写清前置条件、输入、步骤、预期结果和实际结果。至少选择一个实际发现的问题写成缺陷报告，附可复现步骤、环境和截图；如果没有发现缺陷，请写明已执行的范围和未覆盖的部分，不要编造缺陷。

本次提交截止到10月23日18:00。附件给出了用例字段、缺陷报告结构及评分要求，提交前请检查“实际结果”一列确实来自运行。

周老师
10月8日','设计至少十二条登录测试用例，记录执行结果；提交测试用例表和一份包含复现步骤的缺陷报告。','测试用例表可使用 XLSX；缺陷报告使用 DOCX，两者打包为“学号姓名_登录测试.zip”。','2026-10-23 18:00:00','周老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='软件测试' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='登录功能测试与缺陷报告');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'登录功能测试与缺陷报告参考说明.pdf','course-3-reference.pdf','一、用例字段
编号、功能点、前置条件、步骤、输入数据、预期结果、实际结果、是否通过和备注。至少十二条用例，必须覆盖空输入、错误密码和长度边界。
二、权限场景
未登录访问应被拒绝；学生不能发布通知；任课教师不能修改其他教师的通知。
三、缺陷报告
包含标题、严重程度、测试环境、复现步骤、预期行为、实际行为、截图和回归结果。无真实缺陷时提交测试结论与覆盖范围。
四、评分与提交
用例设计40%，实际执行与证据40%，报告条理20%。10月23日18:00前提交用例表和缺陷报告。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='软件测试' AND n.title='登录功能测试与缺陷报告'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'登录功能测试与缺陷报告参考资料','周老师：

一、用例字段
编号、功能点、前置条件、步骤、输入数据、预期结果、实际结果、是否通过和备注。至少十二条用例，必须覆盖空输入、错误密码和长度边界。
二、权限场景
未登录访问应被拒绝；学生不能发布通知；任课教师不能修改其他教师的通知。
三、缺陷报告
包含标题、严重程度、测试环境、复现步骤、预期行为、实际行为、截图和回归结果。无真实缺陷时提交测试结论与覆盖范围。
四、评分与提交
用例设计40%，实际执行与证据40%，报告条理20%。10月23日18:00前提交用例表和缺陷报告。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'周老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='软件测试' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='登录功能测试与缺陷报告参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'登录功能测试与缺陷报告参考说明.pdf','course-3-reference.pdf','一、用例字段
编号、功能点、前置条件、步骤、输入数据、预期结果、实际结果、是否通过和备注。至少十二条用例，必须覆盖空输入、错误密码和长度边界。
二、权限场景
未登录访问应被拒绝；学生不能发布通知；任课教师不能修改其他教师的通知。
三、缺陷报告
包含标题、严重程度、测试环境、复现步骤、预期行为、实际行为、截图和回归结果。无真实缺陷时提交测试结论与覆盖范围。
四、评分与提交
用例设计40%，实际执行与证据40%，报告条理20%。10月23日18:00前提交用例表和缺陷报告。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='软件测试' AND n.title='登录功能测试与缺陷报告参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'测试用例课堂互审安排','各位同学：

下次课两人一组互审测试用例，重点检查步骤能否复现、边界是否遗漏、预期是否清楚。请带可编辑的用例表，不需要提前上传。

周老师
10月8日','下次课两人一组互审测试用例，重点检查步骤能否复现、边界是否遗漏、预期是否清楚。请带可编辑的用例表，不需要提前上传。','','2026-10-16 10:00:00','周老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='软件测试' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='测试用例课堂互审安排');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'学生成绩管理程序练习','同学们：

请用本周学习的集合和异常处理实现一个控制台成绩管理程序。学生信息至少包含学号、姓名及三门课程成绩，支持新增、按学号查询、修改成绩和计算平均分。

成绩范围限定为0至100，重复学号和非法输入需要给出清楚提示。程序退出前把记录保存为 UTF-8 文本，下次启动能够读回。不要把数据写死在代码中。

10月19日21:00前提交源码及运行说明，说明中至少展示正常输入、非法成绩和重新启动后的结果。附件列出了功能清单及检查方式。

王老师
10月8日','用 Java 完成成绩录入、查询、平均分统计及文件保存，提交源码和一页运行说明。','源码保持标准目录；运行说明使用 PDF，压缩包命名为“学号姓名_成绩管理.zip”。','2026-10-19 21:00:00','王老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='Java程序设计' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='学生成绩管理程序练习');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'学生成绩管理程序练习参考说明.pdf','course-4-reference.pdf','一、数据结构
使用 Student 类表示学生，集合保存多名学生；学号唯一，姓名不可为空，成绩范围0至100。
二、功能清单
新增、按学号查询、修改成绩、计算平均分、保存文本、启动时加载。文件统一采用 UTF-8。
三、运行证据
展示至少三名学生的数据；演示重复学号、非法成绩输入以及退出后重新启动读回记录。
四、评分与提交
功能完整性60%，异常处理20%，代码结构和说明20%。10月19日21:00前提交源码和 PDF 运行说明。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='Java程序设计' AND n.title='学生成绩管理程序练习'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'学生成绩管理程序练习参考资料','王老师：

一、数据结构
使用 Student 类表示学生，集合保存多名学生；学号唯一，姓名不可为空，成绩范围0至100。
二、功能清单
新增、按学号查询、修改成绩、计算平均分、保存文本、启动时加载。文件统一采用 UTF-8。
三、运行证据
展示至少三名学生的数据；演示重复学号、非法成绩输入以及退出后重新启动读回记录。
四、评分与提交
功能完整性60%，异常处理20%，代码结构和说明20%。10月19日21:00前提交源码和 PDF 运行说明。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'王老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='Java程序设计' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='学生成绩管理程序练习参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'学生成绩管理程序练习参考说明.pdf','course-4-reference.pdf','一、数据结构
使用 Student 类表示学生，集合保存多名学生；学号唯一，姓名不可为空，成绩范围0至100。
二、功能清单
新增、按学号查询、修改成绩、计算平均分、保存文本、启动时加载。文件统一采用 UTF-8。
三、运行证据
展示至少三名学生的数据；演示重复学号、非法成绩输入以及退出后重新启动读回记录。
四、评分与提交
功能完整性60%，异常处理20%，代码结构和说明20%。10月19日21:00前提交源码和 PDF 运行说明。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='Java程序设计' AND n.title='学生成绩管理程序练习参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'集合与异常处理课前准备','各位同学：

下次课讲解 ArrayList、HashMap 和自定义异常。请复习学生类的封装写法，准备一个“学号不存在时如何处理”的小例子，课堂讨论。

王老师
10月8日','下次课讲解 ArrayList、HashMap 和自定义异常。请复习学生类的封装写法，准备一个“学号不存在时如何处理”的小例子，课堂讨论。','',NULL,'王老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='Java程序设计' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='集合与异常处理课前准备');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'顺序表与链表对比实验','各位同学：

本次实验用相同接口实现顺序表和单链表，至少包含头部插入、尾部插入、按位置删除及按值查询。不要直接调用现成链表容器替代实现。

使用1000、10000和100000条数据测试，每种操作重复五次取平均值。报告中解释时间差异，结合算法步骤分析复杂度。越界位置、空表删除等情况也需要测试。

10月22日22:00前上传代码和 PDF 报告。附件中的计时注意事项请先读，避免把打印输出的耗时算入操作时间。

赵老师
10月8日','分别实现顺序表和单链表的插入、删除与查询，比较不同数据规模下的运行时间，提交代码与实验报告。','报告使用 PDF，记录实验环境、数据规模及计时结果；压缩包命名为“学号姓名_线性表实验.zip”。','2026-10-22 22:00:00','赵老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='数据结构' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='顺序表与链表对比实验');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'顺序表与链表对比实验参考说明.pdf','course-5-reference.pdf','一、接口要求
顺序表和单链表使用一致的插入、删除、查询接口，处理空表和越界位置。
二、数据规模
分别使用1000、10000、100000条数据；每项操作重复五次取平均值。
三、计时方法
先准备测试数据，再开始计时；循环内禁止打印。分别比较头部与尾部插入，并分析访问和修改的复杂度。
四、评分与提交
实现正确性50%，实验数据与分析30%，边界测试20%。10月22日22:00前提交代码和 PDF 报告。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='数据结构' AND n.title='顺序表与链表对比实验'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'顺序表与链表对比实验参考资料','赵老师：

一、接口要求
顺序表和单链表使用一致的插入、删除、查询接口，处理空表和越界位置。
二、数据规模
分别使用1000、10000、100000条数据；每项操作重复五次取平均值。
三、计时方法
先准备测试数据，再开始计时；循环内禁止打印。分别比较头部与尾部插入，并分析访问和修改的复杂度。
四、评分与提交
实现正确性50%，实验数据与分析30%，边界测试20%。10月22日22:00前提交代码和 PDF 报告。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'赵老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='数据结构' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='顺序表与链表对比实验参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'顺序表与链表对比实验参考说明.pdf','course-5-reference.pdf','一、接口要求
顺序表和单链表使用一致的插入、删除、查询接口，处理空表和越界位置。
二、数据规模
分别使用1000、10000、100000条数据；每项操作重复五次取平均值。
三、计时方法
先准备测试数据，再开始计时；循环内禁止打印。分别比较头部与尾部插入，并分析访问和修改的复杂度。
四、评分与提交
实现正确性50%，实验数据与分析30%，边界测试20%。10月22日22:00前提交代码和 PDF 报告。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='数据结构' AND n.title='顺序表与链表对比实验参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'线性表实验答疑安排','各位同学：

周四16:00在实验室集中答疑。请带上插入或删除操作的最小复现代码及输入数据，先说明链表指针是如何变化的，再提问。

赵老师
10月8日','周四16:00在实验室集中答疑。请带上插入或删除操作的最小复现代码及输入数据，先说明链表指针是如何变化的，再提问。','','2026-10-15 16:00:00','赵老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='数据结构' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='线性表实验答疑安排');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'TCP 三次握手抓包实验','同学们好：

本次实验观察 TCP 的三次握手和连接断开。请在自己的测试环境中建立一条连接，使用 Wireshark 过滤该连接，分别截取握手和断开过程。

报告需要标注客户端和服务端、源目的端口、SYN/ACK/FIN 标志位，以及序列号和确认号的变化。解释每一步的作用，不要只粘贴截图。抓包前关闭无关应用，提交前检查是否包含账号、Cookie 或其他私密数据。

10月26日20:00前提交 PDF 报告及脱敏后的 pcapng 文件。附件给出了筛选和报告结构。

孙老师
10月8日','使用 Wireshark 记录 TCP 建连与断开过程，标注标志位、序列号及确认号，提交实验报告和脱敏抓包文件。','报告使用 PDF，抓包文件使用 pcapng；压缩包命名为“学号姓名_TCP抓包.zip”。','2026-10-26 20:00:00','孙老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='计算机网络' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='TCP 三次握手抓包实验');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'TCP 三次握手抓包实验参考说明.pdf','course-6-reference.pdf','一、实验环境
在自己有权限的测试网络中建立 TCP 连接，记录系统、Wireshark 版本和测试地址。
二、观察字段
源目的 IP、源目的端口、SYN/ACK/FIN、相对序列号、相对确认号。握手和断开分别截图并解释。
三、抓包筛选
可按 tcp.port 或 tcp.stream 过滤指定连接，报告注明使用的过滤条件。
四、提交要求
10月26日20:00前提交 PDF 报告和 pcapng 文件。先删除或遮盖令牌、Cookie 与无关通信。过程分析占60%，截图标注占25%，环境和结论占15%。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='计算机网络' AND n.title='TCP 三次握手抓包实验'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'TCP 三次握手抓包实验参考资料','孙老师：

一、实验环境
在自己有权限的测试网络中建立 TCP 连接，记录系统、Wireshark 版本和测试地址。
二、观察字段
源目的 IP、源目的端口、SYN/ACK/FIN、相对序列号、相对确认号。握手和断开分别截图并解释。
三、抓包筛选
可按 tcp.port 或 tcp.stream 过滤指定连接，报告注明使用的过滤条件。
四、提交要求
10月26日20:00前提交 PDF 报告和 pcapng 文件。先删除或遮盖令牌、Cookie 与无关通信。过程分析占60%，截图标注占25%，环境和结论占15%。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'孙老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='计算机网络' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='TCP 三次握手抓包实验参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'TCP 三次握手抓包实验参考说明.pdf','course-6-reference.pdf','一、实验环境
在自己有权限的测试网络中建立 TCP 连接，记录系统、Wireshark 版本和测试地址。
二、观察字段
源目的 IP、源目的端口、SYN/ACK/FIN、相对序列号、相对确认号。握手和断开分别截图并解释。
三、抓包筛选
可按 tcp.port 或 tcp.stream 过滤指定连接，报告注明使用的过滤条件。
四、提交要求
10月26日20:00前提交 PDF 报告和 pcapng 文件。先删除或遮盖令牌、Cookie 与无关通信。过程分析占60%，截图标注占25%，环境和结论占15%。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='计算机网络' AND n.title='TCP 三次握手抓包实验参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'网络实验设备使用提醒','各位同学：

实验时使用本人电脑和指定测试环境，不扫描其他同学设备。开始抓包前关闭聊天和网盘软件，实验结束后及时停止抓包并清理无关数据。

孙老师
10月8日','实验时使用本人电脑和指定测试环境，不扫描其他同学设备。开始抓包前关闭聊天和网盘软件，实验结束后及时停止抓包并清理无关数据。','',NULL,'孙老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='计算机网络' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='网络实验设备使用提醒');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'生产者消费者同步实验','各位同学：\\n
本次实验实现生产者消费者模型。共享缓冲区容量设为五，启动两个生产者和两个消费者，每个线程处理十个任务。请使用互斥与条件同步保证缓冲区不会越界，任务不会重复消费。

记录线程、任务编号、操作类型和操作后的缓冲区长度。在报告中说明缓冲区为空或已满时线程怎样等待，以及结束时如何让所有线程正确退出。

10月28日22:00前提交源码、一次完整运行记录和 PDF 报告。附件中的约束和检查点作为验收依据。

刘老师
10月8日','实现容量为五的共享缓冲区，两个生产者和两个消费者各处理十个任务，提交同步代码、执行记录和分析报告。','报告使用 PDF；执行记录保存为 UTF-8 文本，压缩包命名为“学号姓名_同步实验.zip”。','2026-10-28 22:00:00','刘老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='操作系统' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='生产者消费者同步实验');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'生产者消费者同步实验参考说明.pdf','course-7-reference.pdf','一、实验参数
缓冲区容量五；两个生产者、两个消费者；每个线程处理十个任务。
二、同步约束
缓冲区长度始终处于0至5；空缓冲区不能消费，满缓冲区不能继续生产；共享状态的修改必须互斥。
三、验证记录
输出线程名、任务编号、生产或消费动作及当前长度。最终每个任务仅消费一次，无丢失或重复，所有线程正常结束。
四、评分与提交
同步正确性50%，运行验证30%，分析说明20%。10月28日22:00前提交代码、UTF-8 日志和 PDF 报告。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='操作系统' AND n.title='生产者消费者同步实验'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'生产者消费者同步实验参考资料','刘老师：

一、实验参数
缓冲区容量五；两个生产者、两个消费者；每个线程处理十个任务。
二、同步约束
缓冲区长度始终处于0至5；空缓冲区不能消费，满缓冲区不能继续生产；共享状态的修改必须互斥。
三、验证记录
输出线程名、任务编号、生产或消费动作及当前长度。最终每个任务仅消费一次，无丢失或重复，所有线程正常结束。
四、评分与提交
同步正确性50%，运行验证30%，分析说明20%。10月28日22:00前提交代码、UTF-8 日志和 PDF 报告。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'刘老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='操作系统' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='生产者消费者同步实验参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'生产者消费者同步实验参考说明.pdf','course-7-reference.pdf','一、实验参数
缓冲区容量五；两个生产者、两个消费者；每个线程处理十个任务。
二、同步约束
缓冲区长度始终处于0至5；空缓冲区不能消费，满缓冲区不能继续生产；共享状态的修改必须互斥。
三、验证记录
输出线程名、任务编号、生产或消费动作及当前长度。最终每个任务仅消费一次，无丢失或重复，所有线程正常结束。
四、评分与提交
同步正确性50%，运行验证30%，分析说明20%。10月28日22:00前提交代码、UTF-8 日志和 PDF 报告。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='操作系统' AND n.title='生产者消费者同步实验参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'进程与线程课堂讨论','各位同学：

下次课讨论进程和线程的资源共享差别。每组准备一个需要同步的实际场景，并说明竞争条件可能出现在哪里，课堂口头汇报。

刘老师
10月8日','下次课讨论进程和线程的资源共享差别。每组准备一个需要同步的实际场景，并说明竞争条件可能出现在哪里，课堂口头汇报。','',NULL,'刘老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='操作系统' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='进程与线程课堂讨论');

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'课程通知页面组件化练习','同学们：

本次练习把课程通知页面拆成组件，至少包含课程导航、通知列表、通知详情和搜索框。列表卡片只展示标题、要点和截止时间，点击后在详情区显示完整正文及附件信息。

切换课程后应清空上一门课的选中内容，搜索无结果时要有提示，加载中和请求失败也应明确展示。页面在手机宽度下不能出现横向溢出。

10月30日21:00前提交源码和页面说明。请保证 npm ci、npm run build 能正常执行，不要把 node_modules 打进压缩包。组件划分和检查清单见附件。

许老师
10月8日','用 Vue 制作课程导航、通知摘要卡片和详情区，支持课程切换、关键词搜索及空状态，提交源码和页面截图。','提交可构建的前端源码及 PDF 页面说明，压缩包命名为“学号姓名_通知页面.zip”。','2026-10-30 21:00:00','许老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='Web前端开发' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='课程通知页面组件化练习');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'课程通知页面组件化练习参考说明.pdf','course-8-reference.pdf','一、组件建议
CourseList 负责课程导航，NoticeList 负责摘要卡片，NoticeDetail 负责正文和附件；数据请求由父组件统一管理。
二、交互要求
课程切换清空旧详情；标题和正文关键词搜索；加载、错误和空列表分别提示；点击卡片展示对应原文。
三、显示检查
桌面和手机宽度都能阅读，无横向溢出；表单标签和键盘焦点清楚；长中文正文自动换行。
四、评分与提交
交互功能50%，组件组织25%，页面适配25%。10月30日21:00前提交可构建源码及 PDF 页面说明，排除 node_modules。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='Web前端开发' AND n.title='课程通知页面组件化练习'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'课程通知页面组件化练习参考资料','许老师：

一、组件建议
CourseList 负责课程导航，NoticeList 负责摘要卡片，NoticeDetail 负责正文和附件；数据请求由父组件统一管理。
二、交互要求
课程切换清空旧详情；标题和正文关键词搜索；加载、错误和空列表分别提示；点击卡片展示对应原文。
三、显示检查
桌面和手机宽度都能阅读，无横向溢出；表单标签和键盘焦点清楚；长中文正文自动换行。
四、评分与提交
交互功能50%，组件组织25%，页面适配25%。10月30日21:00前提交可构建源码及 PDF 页面说明，排除 node_modules。

请结合本次通知阅读附件，有问题在课程问答中查看原文依据。','阅读参考文件，按通知中的清单检查作业；本资料无单独提交要求。','PDF 参考附件，可查看原文或下载保存。',NULL,'许老师 · 课程资料','MATERIAL'
FROM courses c WHERE c.name='Web前端开发' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='课程通知页面组件化练习参考资料');

INSERT INTO notice_attachments(notice_id,filename,resource_name,content)
SELECT n.id,'课程通知页面组件化练习参考说明.pdf','course-8-reference.pdf','一、组件建议
CourseList 负责课程导航，NoticeList 负责摘要卡片，NoticeDetail 负责正文和附件；数据请求由父组件统一管理。
二、交互要求
课程切换清空旧详情；标题和正文关键词搜索；加载、错误和空列表分别提示；点击卡片展示对应原文。
三、显示检查
桌面和手机宽度都能阅读，无横向溢出；表单标签和键盘焦点清楚；长中文正文自动换行。
四、评分与提交
交互功能50%，组件组织25%，页面适配25%。10月30日21:00前提交可构建源码及 PDF 页面说明，排除 node_modules。'
FROM notices n JOIN courses c ON c.id=n.course_id WHERE c.name='Web前端开发' AND n.title='课程通知页面组件化练习参考资料'
ON DUPLICATE KEY UPDATE filename=VALUES(filename),content=VALUES(content);

INSERT INTO notices(course_id,title,content,submission_requirements,report_format,deadline,source,type)
SELECT c.id,'页面展示与互评安排','各位同学：

周五课堂展示页面，每人介绍课程切换和详情读取的交互。请准备桌面和手机宽度的页面，互评重点是信息是否好找、正文是否好读。

许老师
10月8日','周五课堂展示页面，每人介绍课程切换和详情读取的交互。请准备桌面和手机宽度的页面，互评重点是信息是否好找、正文是否好读。','','2026-10-23 14:00:00','许老师 · 课程群','NOTICE'
FROM courses c WHERE c.name='Web前端开发' AND NOT EXISTS (SELECT 1 FROM notices n WHERE n.course_id=c.id AND n.title='页面展示与互评安排');

COMMIT;
