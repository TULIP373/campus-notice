package com.example.campusnotice.service;

import com.example.campusnotice.dto.NoticeRequest;
import com.example.campusnotice.entity.Course;
import com.example.campusnotice.entity.Notice;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.CourseMapper;
import com.example.campusnotice.mapper.NoticeMapper;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** 课程通知的业务边界；SQL 数据库行为由接口联调独立验证。 */
@ExtendWith(MockitoExtension.class)
class NoticeServiceTest {
    @Mock
    private NoticeMapper mapper;
    @Mock
    private CourseMapper courses;
    private NoticeService service;

    @BeforeEach
    void setUp() {
        service = new NoticeService(mapper, new CourseService(courses));
    }

    @Test
    void missingOrUnselectedCourseIsRejected() {
        ApiException missing = assertThrows(ApiException.class,
                () -> service.create(request(404L, "测试通知", "NOTICE")));
        assertEquals(HttpStatus.NOT_FOUND, missing.getStatus());
        ApiException unselected = assertThrows(ApiException.class,
                () -> service.create(request(null, "测试通知", "NOTICE")));
        assertEquals(HttpStatus.BAD_REQUEST, unselected.getStatus());
        verify(mapper, never()).insert(any(Notice.class));
    }

    @Test
    void invalidTypeIsBadRequest() {
        existingCourse();
        ApiException failure = assertThrows(ApiException.class,
                () -> service.create(request(1L, "测试通知", "INVALID")));
        assertEquals(HttpStatus.BAD_REQUEST, failure.getStatus());
        verify(mapper, never()).insert(any(Notice.class));
    }

    @Test
    void blankTitleIsBadRequest() {
        existingCourse();
        ApiException failure = assertThrows(ApiException.class,
                () -> service.create(request(1L, "  ", "NOTICE")));
        assertEquals(HttpStatus.BAD_REQUEST, failure.getStatus());
        verify(mapper, never()).insert(any(Notice.class));
    }

    @Test
    void oversizedSearchIsBadRequest() {
        ApiException failure = assertThrows(ApiException.class,
                () -> service.list(null, "字".repeat(201)));
        assertEquals(HttpStatus.BAD_REQUEST, failure.getStatus());
        verify(mapper, never()).findAll(any(), any());
    }

    @Test
    void materialMayHaveNoDeadline() {
        existingCourse();
        AtomicReference<Notice> saved = new AtomicReference<>();
        when(mapper.insert(any(Notice.class))).thenAnswer(invocation -> {
            Notice notice = invocation.getArgument(0);
            notice.setId(201L);
            saved.set(notice);
            return 1;
        });
        when(mapper.findById(201L)).thenAnswer(invocation -> saved.get());

        Notice result = service.create(request(1L, "测试学习资料", "MATERIAL"));

        ArgumentCaptor<Notice> captured = ArgumentCaptor.forClass(Notice.class);
        verify(mapper).insert(captured.capture());
        assertEquals(Long.valueOf(1L), captured.getValue().getCourseId());
        assertEquals("MATERIAL", captured.getValue().getType());
        assertNull(captured.getValue().getDeadline());
        assertNull(result.getDeadline());
        assertEquals(Long.valueOf(201L), result.getId());
    }

    @Test
    void deleteAffectingNoRowsIsNotFound() {
        when(mapper.deleteById(404L)).thenReturn(0);
        ApiException failure = assertThrows(ApiException.class, () -> service.delete(404L));
        assertEquals(HttpStatus.NOT_FOUND, failure.getStatus());
        verify(mapper).deleteById(404L);
    }

    private void existingCourse() {
        Course course = new Course();
        course.setId(1L);
        course.setName("测试课程");
        when(courses.findById(1L)).thenReturn(course);
    }

    private NoticeRequest request(Long courseId, String title, String type) {
        return new NoticeRequest(courseId, title, "中文资料正文", "提交要求", "DOCX", null, "独立测试", type);
    }
}
