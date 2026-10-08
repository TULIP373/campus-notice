package com.example.campusnotice.controller;

import com.example.campusnotice.dto.AskRequest;
import com.example.campusnotice.dto.AskResponse;
import com.example.campusnotice.service.AskService;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ask")
public class AskController {
    private final AskService service;
    public AskController(AskService service) { this.service = service; }
    @PostMapping
    @PreAuthorize("hasAuthority('ask:use')")
    public AskResponse ask(@Valid @RequestBody AskRequest request) { return service.ask(request); }
}
