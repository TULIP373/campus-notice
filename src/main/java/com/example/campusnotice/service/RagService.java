package com.example.campusnotice.service;

import com.example.campusnotice.dto.RagSource;
import com.example.campusnotice.entity.Notice;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.stereotype.Service;

/** 教学用稀疏向量检索：字/相邻双字的TF-IDF，不调用额外embedding服务。 */
@Service
public class RagService {
    private static final int CHUNK_SIZE = 450;
    private static final int OVERLAP = 80;
    private static final double MIN_SCORE = 0.12;

    public static List<String> split(String text) {
        if (text == null || text.isBlank()) { return List.of(); }
        List<String> chunks = new ArrayList<>();
        for (int start = 0; start < text.length(); start += CHUNK_SIZE - OVERLAP) {
            int end = Math.min(start + CHUNK_SIZE, text.length());
            chunks.add(text.substring(start, end));
            if (end == text.length()) { break; }
        }
        return chunks;
    }

    public List<RagSource> retrieve(List<Notice> notices, long courseId, String question) {
        if (notices == null || question == null || question.isBlank()) { return List.of(); }
        List<Chunk> chunks = new ArrayList<>();
        for (Notice notice : notices) {
            // 先隔离课程，再计算向量，其他课程不能成为回答依据。
            if (notice == null || notice.getId() == null || notice.getCourseId() == null
                    || notice.getCourseId() != courseId) { continue; }
            List<String> texts = split(document(notice));
            for (int index = 0; index < texts.size(); index++) {
                chunks.add(new Chunk(notice, index, texts.get(index), frequencies(texts.get(index)), notice.getTitle(), notice.getSource()));
            }
            int index = texts.size();
            for (var attachment : notice.getAttachments()) {
                if (attachment.content() == null || attachment.content().isBlank()) { continue; }
                // 保留附件的章节边界，避免评分或格式要求埋在长通知中而无法命中。
                for (String section : attachment.content().split("(?=[一二三四五六七八九十]+、)")) {
                    for (String part : split(section)) {
                        String text = "附件：" + attachment.filename() + "\n" + part;
                        chunks.add(new Chunk(notice, index++, text, frequencies(text),
                                notice.getTitle() + " · " + attachment.filename(), notice.getSource()));
                    }
                }
            }
        }
        if (chunks.isEmpty()) { return List.of(); }
        Map<String, Integer> documentFrequency = new HashMap<>();
        for (Chunk chunk : chunks) {
            chunk.frequencies().keySet().forEach(token -> documentFrequency.merge(token, 1, Integer::sum));
        }
        Map<String, Double> queryVector = vector(frequencies(question), documentFrequency, chunks.size());
        if (queryVector.isEmpty()) { return List.of(); }
        List<RagSource> results = new ArrayList<>();
        for (Chunk chunk : chunks) {
            double score = cosine(queryVector, vector(chunk.frequencies(), documentFrequency, chunks.size()));
            if (score >= MIN_SCORE) {
                Notice notice = chunk.notice();
                results.add(new RagSource(courseId, notice.getId(), chunk.title(), chunk.source(),
                        chunk.text(), score, chunk.index()));
            }
        }
        return results.stream().sorted(Comparator.comparingDouble(RagSource::score).reversed()
                .thenComparingLong(RagSource::noticeId).thenComparingInt(RagSource::chunkIndex)).limit(3).toList();
    }

    public List<RagSource> overview(Notice notice, long courseId) {
        if (notice == null || notice.getId() == null || notice.getCourseId() == null || notice.getCourseId() != courseId) { return List.of(); }
        List<RagSource> result = new ArrayList<>();
        List<String> body = split(document(notice));
        for (int index = 0; index < Math.min(2, body.size()); index++) {
            result.add(new RagSource(courseId, notice.getId(), notice.getTitle(), notice.getSource(), body.get(index), 0, index));
        }
        if (!notice.getAttachments().isEmpty()) {
            var attachment = notice.getAttachments().get(0);
            List<String> texts = split(attachment.content());
            if (!texts.isEmpty()) {
                result.add(new RagSource(courseId, notice.getId(), notice.getTitle() + " · " + attachment.filename(),
                        notice.getSource(), "附件：" + attachment.filename() + "\n" + texts.get(0), 0, body.size()));
            }
        }
        return List.copyOf(result);
    }

    private String document(Notice notice) {
        StringBuilder text = new StringBuilder();
        append(text, "标题", notice.getTitle());
        append(text, "正文", notice.getContent());
        append(text, "提交要求", notice.getSubmissionRequirements());
        append(text, "报告格式", notice.getReportFormat());
        append(text, "截止时间", notice.getDeadline() == null ? null : notice.getDeadline().toString());
        append(text, "来源", notice.getSource());
        return text.toString();
    }

    private void append(StringBuilder result, String label, String value) {
        if (value != null && !value.isBlank()) { result.append(label).append('：').append(value).append('\n'); }
    }

    private Map<String, Integer> frequencies(String text) {
        Map<String, Integer> result = new HashMap<>();
        String normalized = text.toLowerCase(Locale.ROOT);
        Character previous = null;
        for (int index = 0; index < normalized.length(); index++) {
            char current = normalized.charAt(index);
            if (!Character.isLetterOrDigit(current)) { previous = null; continue; }
            result.merge("u:" + current, 1, Integer::sum);
            if (previous != null) { result.merge("b:" + previous + current, 1, Integer::sum); }
            previous = current;
        }
        return result;
    }

    private Map<String, Double> vector(Map<String, Integer> frequencies, Map<String, Integer> df, int total) {
        Map<String, Double> result = new HashMap<>();
        frequencies.forEach((token, count) -> {
            double tf = 1.0 + Math.log(count);
            double idf = 1.0 + Math.log((total + 1.0) / (df.getOrDefault(token, 0) + 1.0));
            // 双字比单字更能区分主题；未知问题词也保留在分母，降低无关问题得分。
            result.put(token, tf * idf * (token.startsWith("b:") ? 2.0 : 1.0));
        });
        return result;
    }

    private double cosine(Map<String, Double> left, Map<String, Double> right) {
        double dot = 0, leftSquare = 0, rightSquare = 0;
        for (Map.Entry<String, Double> item : left.entrySet()) {
            dot += item.getValue() * right.getOrDefault(item.getKey(), 0.0);
            leftSquare += item.getValue() * item.getValue();
        }
        for (double weight : right.values()) { rightSquare += weight * weight; }
        if (leftSquare == 0 || rightSquare == 0) { return 0; }
        return Math.min(1.0, dot / Math.sqrt(leftSquare * rightSquare));
    }

    private record Chunk(Notice notice, int index, String text, Map<String, Integer> frequencies, String title, String source) {
    }
}
