package com.example.campusnotice.entity;

import java.time.LocalDateTime;
import java.util.List;

/** 一张表同时保存通知和学习资料，用 type 区分。 */
public class Notice {
    private Long id;
    private Long courseId;
    private String title;
    private String content;
    private String submissionRequirements;
    private String reportFormat;
    private LocalDateTime deadline;
    private String source;
    private String type;
    private LocalDateTime createdAt;
    private List<NoticeAttachment> attachments = List.of();
    public List<NoticeAttachment> getAttachments() { return attachments; }
    public void setAttachments(List<NoticeAttachment> value) { attachments = value == null ? List.of() : value; }
    public String getSummary() {
        String text = submissionRequirements == null || submissionRequirements.isBlank() ? content : submissionRequirements;
        if (text == null) { return ""; }
        text = text.replaceAll("\\s+", " ").trim();
        return text.length() <= 140 ? text : text.substring(0, 140) + "…";
    }
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getCourseId() { return courseId; }
    public void setCourseId(Long courseId) { this.courseId = courseId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getSubmissionRequirements() { return submissionRequirements; }
    public void setSubmissionRequirements(String value) { submissionRequirements = value; }
    public String getReportFormat() { return reportFormat; }
    public void setReportFormat(String reportFormat) { this.reportFormat = reportFormat; }
    public LocalDateTime getDeadline() { return deadline; }
    public void setDeadline(LocalDateTime deadline) { this.deadline = deadline; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
