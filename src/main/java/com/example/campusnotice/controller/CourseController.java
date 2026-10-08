package com.example.campusnotice.controller;

import com.example.campusnotice.entity.Course;
import com.example.campusnotice.service.CourseService;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/courses")
@PreAuthorize("hasAuthority('course:read')")
public class CourseController {
    private final CourseService service;
    public CourseController(CourseService service) { this.service = service; }
    @GetMapping
    public List<Course> list() { return service.list(); }
    @GetMapping("/{id}")
    public Course get(@PathVariable Long id) { return service.get(id); }
}
