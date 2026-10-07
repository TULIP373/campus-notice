package com.example.campusnotice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** 请求与实体分开，浏览器提交明文密码，数据库实体保存哈希。 */
public record UserRequest(
        @NotBlank(message = "用户名不能为空")
        @Size(max = 50, message = "用户名最多50个字符")
        @Pattern(regexp = "[A-Za-z0-9_]+", message = "用户名只能包含字母、数字或下划线") String username,
        @NotBlank(message = "姓名不能为空")
        @Size(max = 100, message = "姓名最多100个字符") String name,
        @Size(max = 72, message = "密码最多72个字符") String password,
        @Pattern(regexp = "STUDENT|TEACHER", message = "角色必须为STUDENT或TEACHER") String role) {
}
