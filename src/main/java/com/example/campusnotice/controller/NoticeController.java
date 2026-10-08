package com.example.campusnotice.controller;

import com.example.campusnotice.dto.NoticeRequest;
import com.example.campusnotice.entity.Notice;
import com.example.campusnotice.service.NoticeService;
import jakarta.validation.Valid;
import java.util.List;
import java.nio.charset.StandardCharsets;
import com.example.campusnotice.exception.ApiException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
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
    @PreAuthorize("hasAuthority('notice:read')")
    public List<Notice> list(@RequestParam(required = false) Long courseId, @RequestParam(required = false) String q) {
        return service.list(courseId, q);
    }
    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('notice:read')")
    public Notice get(@PathVariable Long id) { return service.get(id); }
    @GetMapping("/{id}/attachments/{attachmentId}")
    @PreAuthorize("hasAuthority('notice:read')")
    public ResponseEntity<Resource> attachment(@PathVariable Long id, @PathVariable Long attachmentId) {
        var attachment = service.get(id).getAttachments().stream()
                .filter(item -> item.id().equals(attachmentId)).findFirst()
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "当前通知中没有此附件"));
        if (attachment.resourceName() == null || !attachment.resourceName().matches("[a-z0-9-]+\\.pdf")) {
            throw new ApiException(HttpStatus.NOT_FOUND, "附件不存在");
        }
        Resource resource = new ClassPathResource("attachments/" + attachment.resourceName());
        if (!resource.exists()) { throw new ApiException(HttpStatus.NOT_FOUND, "附件文件不存在"); }
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment()
                        .filename(attachment.filename(), StandardCharsets.UTF_8).build().toString())
                .body(resource);
    }
    @PostMapping
    @PreAuthorize("hasRole('TEACHER') and hasAuthority('notice:write')")
    @ResponseStatus(HttpStatus.CREATED)
    public Notice create(@Valid @RequestBody NoticeRequest request) { return service.create(request); }
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('TEACHER') and hasAuthority('notice:write')")
    public Notice update(@PathVariable Long id, @Valid @RequestBody NoticeRequest request) { return service.update(id, request); }
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('TEACHER') and hasAuthority('notice:write')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) { service.delete(id); }
}
