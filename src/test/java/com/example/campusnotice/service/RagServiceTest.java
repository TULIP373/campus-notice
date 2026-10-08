package com.example.campusnotice.service;

import com.example.campusnotice.dto.RagSource;
import com.example.campusnotice.entity.Notice;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/** 字符 unigram/bigram TF-IDF 稀疏向量检索，既不调用模型也不使用神经嵌入。 */
class RagServiceTest {
    private final RagService service = new RagService();

    @Test
    void splitsInto450CharactersWith80CharacterOverlap() {
        StringBuilder original = new StringBuilder();
        for (int index = 0; index < 900; index++) {
            original.append((char) (0x4e00 + index));
        }
        String text = original.toString();

        List<String> chunks = RagService.split(text);

        assertEquals(3, chunks.size());
        assertEquals(text.substring(0, 450), chunks.get(0));
        assertEquals(text.substring(370, 820), chunks.get(1));
        assertEquals(text.substring(740), chunks.get(2));
        assertEquals(chunks.get(0).substring(370), chunks.get(1).substring(0, 80));
        assertEquals(chunks.get(1).substring(370), chunks.get(2).substring(0, 80));
        assertTrue(chunks.stream().allMatch(chunk -> !chunk.isEmpty() && chunk.length() <= 450));
    }

    @Test
    void shortAndExactly450CharacterMaterialsAreNotDuplicated() {
        assertEquals(List.of("课程内容"), RagService.split("课程内容"));
        assertEquals(List.of("字".repeat(450)), RagService.split("字".repeat(450)));
        assertEquals(List.of(), RagService.split(""));
    }

    @Test
    void cosineRanksRelevantChunksAndReturnsOnlyTopThree() {
        Notice best = notice(11L, 1L, "图书借阅图书借阅");
        Notice second = notice(12L, 1L, "图书借阅丙丁");
        Notice third = notice(13L, 1L, "图书借阅丙丁丙丁");
        Notice fourth = notice(14L, 1L, "图书借阅丙丁丙丁丙丁");

        // 输入故意逆序；按原顺序或未归一化的点积不能满足此排序。
        List<RagSource> result = service.retrieve(List.of(fourth, third, second, best), 1L, "图书借阅");

        assertEquals(3, result.size());
        assertEquals(List.of(11L, 12L, 13L), result.stream().map(RagSource::noticeId).toList());
        assertTrue(result.get(0).score() > result.get(1).score());
        assertTrue(result.get(1).score() > result.get(2).score());
        assertTrue(result.stream().allMatch(source -> source.score() > 0 && source.score() <= 1.0000001));
    }

    @Test
    void otherCourseFactsCannotBecomeSources() {
        Notice current = notice(21L, 1L, "图书借阅：馆藏归还与借书证办理");
        Notice other = notice(22L, 2L, "登录边界：JWT签名验证过期拒绝，学生只能读教师维护");

        List<RagSource> result = service.retrieve(List.of(other, current), 1L, "图书借阅");

        assertFalse(result.isEmpty());
        assertTrue(result.stream().allMatch(source -> source.courseId() == 1L && source.noticeId() == 21L));
        assertEquals(List.of(), service.retrieve(List.of(other, current), 1L, "登录边界"));
    }

    @Test
    void unrelatedQuestionsDoNotGainReferencesThroughSharedSingleCharacters() {
        Notice material = notice(31L, 1L, "登录边界：JWT签名验证过期拒绝，学生只能读教师维护");
        assertEquals(List.of(), service.retrieve(List.of(material), 1L, "龘"));
        // “签”“证”与正文有单字交集，却没有“火星签证”的事实。
        assertEquals(List.of(), service.retrieve(List.of(material), 1L, "火星签证"));
    }

    @Test
    void bodyRequirementsFormatDeadlineAndSourceAreRetrievable() {
        Notice material = notice(41L, 1L, "图书借阅");
        material.setSubmissionRequirements("压缩源码数据库配置");
        material.setReportFormat("PDF扫描页");
        material.setDeadline(LocalDateTime.of(2026, 11, 13, 22, 45));
        material.setSource("青铜邮局");
        List<String> queries = List.of("图书借阅", "压缩源码数据库配置", "PDF扫描页", "2026-11-13", "青铜邮局");

        for (String query : queries) {
            List<RagSource> result = service.retrieve(List.of(material), 1L, query);
            assertFalse(result.isEmpty(), "该字段应参与资料索引：" + query);
            RagSource source = result.get(0);
            assertEquals(41L, source.noticeId());
            assertEquals(1L, source.courseId());
            assertEquals("青铜邮局", source.source());
            assertTrue(source.text().contains(query), "引用应保留命中的原始事实：" + query);
            assertTrue(source.chunkIndex() >= 0);
        }
    }

    private Notice notice(Long id, Long courseId, String content) {
        Notice notice = new Notice();
        notice.setId(id);
        notice.setCourseId(courseId);
        notice.setTitle("独立资料");
        notice.setContent(content);
        notice.setSource("测试来源");
        notice.setType("MATERIAL");
        return notice;
    }
}
