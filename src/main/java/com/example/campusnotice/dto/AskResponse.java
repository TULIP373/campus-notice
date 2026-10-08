package com.example.campusnotice.dto;

import java.util.List;

public record AskResponse(long courseId, String answer, List<RagSource> sources) {
}
