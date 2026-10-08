package com.example.campusnotice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @NotBlank(message = "请输入用户名") @Size(max = 50, message = "用户名最多50字")
        @Pattern(regexp = "[A-Za-z0-9_]+", message = "用户名格式不正确") String username,
        @NotBlank(message = "请输入密码") @Size(min = 8, max = 72, message = "密码长度为8至72个字符") String password) {
}
