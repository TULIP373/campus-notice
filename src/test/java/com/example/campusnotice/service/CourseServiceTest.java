package com.example.campusnotice.service;

import com.example.campusnotice.entity.Course;
import com.example.campusnotice.mapper.CourseMapper;
import com.example.campusnotice.exception.ApiException;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CourseServiceTest {
    private final CourseMapper mapper = mock(CourseMapper.class);
    private final CourseService service = new CourseService(mapper);
    @AfterEach void clearIdentity() { SecurityContextHolder.clearContext(); }

    @Test void teachersOnlySeeTheirAssignedCourses() {
        identity("teacher_database", "ROLE_TEACHER");
        Course own = course(2L);
        when(mapper.findByTeacher("teacher_database")).thenReturn(List.of(own));
        assertEquals(List.of(own), service.list());
        verify(mapper, never()).findAll();
    }
    @Test void teacherCannotReadOrModifyAnUnassignedCourse() {
        identity("teacher_database", "ROLE_TEACHER");
        when(mapper.findById(1L)).thenReturn(course(1L));
        ApiException failure = assertThrows(ApiException.class, () -> service.get(1L));
        assertEquals(HttpStatus.FORBIDDEN, failure.getStatus());
    }
    @Test void assignedTeacherAndStudentCanReadTheCourse() {
        Course course = course(2L);
        when(mapper.findById(2L)).thenReturn(course);
        when(mapper.isTeacher(2L, "teacher_database")).thenReturn(1);
        identity("teacher_database", "ROLE_TEACHER");
        assertSame(course, service.get(2L));
        identity("demo_student", "ROLE_STUDENT");
        assertSame(course, service.get(2L));
    }
    private void identity(String name, String role) {
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(name, null, List.of(new SimpleGrantedAuthority(role))));
    }
    private Course course(Long id) { Course course = new Course(); course.setId(id); course.setName("课程"); return course; }
}
