package com.example.campusnotice.service;

import com.example.campusnotice.entity.Course;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.CourseMapper;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Service
public class CourseService {
    private final CourseMapper mapper;
    public CourseService(CourseMapper mapper) { this.mapper = mapper; }
    public List<Course> list() {
        Authentication identity = SecurityContextHolder.getContext().getAuthentication();
        return isTeacher(identity) ? mapper.findByTeacher(identity.getName()) : mapper.findAll();
    }
    public Course get(Long id) {
        if (id == null || id <= 0) { throw new ApiException(HttpStatus.BAD_REQUEST, "课程编号必须为正整数"); }
        Course course = mapper.findById(id);
        if (course == null) { throw new ApiException(HttpStatus.NOT_FOUND, "课程不存在"); }
        Authentication identity = SecurityContextHolder.getContext().getAuthentication();
        if (isTeacher(identity) && mapper.isTeacher(id, identity.getName()) == 0) {
            throw new ApiException(HttpStatus.FORBIDDEN, "只能查看和维护自己任教的课程");
        }
        return course;
    }
    private boolean isTeacher(Authentication identity) {
        return identity != null && identity.getAuthorities().stream().anyMatch(item -> item.getAuthority().equals("ROLE_TEACHER"));
    }
}
