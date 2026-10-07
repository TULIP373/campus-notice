package com.example.campusnotice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;

public record NoticeRequest(
        @NotNull(message = "请选择课程") @Positive(message = "课程编号必须为正整数") Long courseId,
        @NotBlank(message = "标题不能为空") @Size(max = 200, message = "标题最多200字") String title,
        @NotBlank(message = "正文不能为空") @Size(max = 10000, message = "正文最多10000字") String content,
        @Size(max = 2000, message = "提交要求最多2000字") String submissionRequirements,
        @Size(max = 1000, message = "报告格式最多1000字") String reportFormat,
        LocalDateTime deadline,
        @NotBlank(message = "请填写信息来源") @Size(max = 255, message = "来源最多255字") String source,
        @NotBlank(message = "请选择通知或资料") @Pattern(regexp = "NOTICE|MATERIAL", message = "类型必须为NOTICE或MATERIAL") String type) {
}
