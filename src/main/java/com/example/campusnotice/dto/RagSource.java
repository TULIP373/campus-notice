package com.example.campusnotice.dto;

/** 保留原文、相似度和通知编号，让学生能够核对回答出处。 */
public record RagSource(long courseId, long noticeId, String title, String source,
                        String text, double score, int chunkIndex) {
}
