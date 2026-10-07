package com.example.campusnotice.service;

import com.example.campusnotice.dto.NoticeRequest;
import com.example.campusnotice.entity.Notice;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.NoticeMapper;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class NoticeService {
    private final NoticeMapper mapper;
    private final CourseService courseService;
    public NoticeService(NoticeMapper mapper, CourseService courseService) {
        this.mapper = mapper;
        this.courseService = courseService;
    }
    public List<Notice> list(Long courseId, String q) {
        if (courseId != null) { courseService.get(courseId); }
        if (q != null && q.length() > 200) { throw new ApiException(HttpStatus.BAD_REQUEST, "搜索关键词最多200字"); }
        return mapper.findAll(courseId, q == null ? null : q.trim());
    }
    public Notice get(Long id) {
        requireId(id);
        Notice notice = mapper.findById(id);
        if (notice == null) { throw new ApiException(HttpStatus.NOT_FOUND, "通知不存在"); }
        return notice;
    }
    public Notice create(NoticeRequest request) {
        validate(request);
        Notice notice = new Notice();
        apply(notice, request);
        mapper.insert(notice);
        return get(notice.getId());
    }
    public Notice update(Long id, NoticeRequest request) {
        validate(request);
        Notice notice = get(id);
        apply(notice, request);
        if (mapper.update(notice) == 0) { throw new ApiException(HttpStatus.NOT_FOUND, "通知不存在"); }
        return get(id);
    }
    public void delete(Long id) {
        requireId(id);
        if (mapper.deleteById(id) == 0) { throw new ApiException(HttpStatus.NOT_FOUND, "通知不存在"); }
    }
    private void validate(NoticeRequest request) {
        if (request == null) { throw new ApiException(HttpStatus.BAD_REQUEST, "通知内容不能为空"); }
        courseService.get(request.courseId());
        required(request.title(), 200, "标题");
        required(request.content(), 10000, "正文");
        required(request.source(), 255, "来源");
        optional(request.submissionRequirements(), 2000, "提交要求");
        optional(request.reportFormat(), 1000, "报告格式");
        if (!List.of("NOTICE", "MATERIAL").contains(request.type() == null ? "" : request.type())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "类型必须为NOTICE或MATERIAL");
        }
    }
    private void required(String value, int maximum, String label) {
        if (value == null || value.isBlank() || value.length() > maximum) {
            throw new ApiException(HttpStatus.BAD_REQUEST, label + "不能为空且最多" + maximum + "字");
        }
    }
    private void optional(String value, int maximum, String label) {
        if (value != null && value.length() > maximum) { throw new ApiException(HttpStatus.BAD_REQUEST, label + "最多" + maximum + "字"); }
    }
    private void requireId(Long id) {
        if (id == null || id <= 0) { throw new ApiException(HttpStatus.BAD_REQUEST, "通知编号必须为正整数"); }
    }
    private void apply(Notice notice, NoticeRequest request) {
        notice.setCourseId(request.courseId());
        notice.setTitle(request.title().trim());
        notice.setContent(request.content());
        notice.setSubmissionRequirements(request.submissionRequirements());
        notice.setReportFormat(request.reportFormat());
        notice.setDeadline(request.deadline());
        notice.setSource(request.source().trim());
        notice.setType(request.type());
    }
}
