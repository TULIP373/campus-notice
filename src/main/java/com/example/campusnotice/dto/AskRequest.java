package com.example.campusnotice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record AskRequest(
        @NotNull(message = "请选择课程") @Positive(message = "课程编号必须为正整数") Long courseId,
        @NotBlank(message = "请输入问题") @Size(max = 1000, message = "问题最多1000字") String question) {
}
