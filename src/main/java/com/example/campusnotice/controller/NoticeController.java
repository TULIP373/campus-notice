package com.example.campusnotice.controller;

import com.example.campusnotice.dto.NoticeRequest;
import com.example.campusnotice.entity.Notice;
import com.example.campusnotice.service.NoticeService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/notices")
public class NoticeController {
    private final NoticeService service;
    public NoticeController(NoticeService service) { this.service = service; }
    @GetMapping
    public List<Notice> list(@RequestParam(required = false) Long courseId, @RequestParam(required = false) String q) {
        return service.list(courseId, q);
    }
    @GetMapping("/{id}")
    public Notice get(@PathVariable Long id) { return service.get(id); }
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Notice create(@Valid @RequestBody NoticeRequest request) { return service.create(request); }
    @PutMapping("/{id}")
    public Notice update(@PathVariable Long id, @Valid @RequestBody NoticeRequest request) { return service.update(id, request); }
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) { service.delete(id); }
}
