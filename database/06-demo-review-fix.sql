-- 修正早期手工录入的课堂样例，保持正文与结构化截止时间一致。
-- 仅匹配指定课程、标题、来源和旧正文，不改动其他通知。
UPDATE notices n
JOIN courses c ON c.id = n.course_id
SET n.content = '本条为课堂演示通知。作业提交时间尚未确定，待老师通知。',
    n.submission_requirements = '演示作业，具体提交内容与时间以老师正式通知为准。',
    n.deadline = NULL
WHERE c.name = '软件项目实训（二）'
  AND n.title = '作业1'
  AND n.source = '本地演示：教师手动录入'
  AND TRIM(n.content) = '10.8号提交';

UPDATE notices n
JOIN courses c ON c.id = n.course_id
SET n.content = REPLACE(n.content, '仓库链接请在完成推送后填写。',
    '项目仓库：https://github.com/TULIP373/campus-notice。')
WHERE c.name = '软件项目实训（二）'
  AND n.title = '课程项目提交要求'
  AND n.source = '陈老师 · 课程群'
  AND n.content LIKE '%仓库链接请在完成推送后填写。%';
