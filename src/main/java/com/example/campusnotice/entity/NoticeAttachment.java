package com.example.campusnotice.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;

public record NoticeAttachment(Long id, String filename, @JsonIgnore String resourceName, String content) {
}
