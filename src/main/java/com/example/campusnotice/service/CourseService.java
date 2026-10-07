package com.example.campusnotice.service;

import com.example.campusnotice.entity.Course;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.CourseMapper;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class CourseService {
    private final CourseMapper mapper;
    public CourseService(CourseMapper mapper) { this.mapper = mapper; }
    public List<Course> list() { return mapper.findAll(); }
    public Course get(Long id) {
        if (id == null || id <= 0) { throw new ApiException(HttpStatus.BAD_REQUEST, "课程编号必须为正整数"); }
        Course course = mapper.findById(id);
        if (course == null) { throw new ApiException(HttpStatus.NOT_FOUND, "课程不存在"); }
        return course;
    }
}
