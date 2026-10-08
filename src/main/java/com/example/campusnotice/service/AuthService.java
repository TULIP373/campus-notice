package com.example.campusnotice.service;

import com.example.campusnotice.dto.LoginRequest;
import com.example.campusnotice.dto.LoginResponse;
import com.example.campusnotice.entity.User;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.PermissionMapper;
import com.example.campusnotice.mapper.UserMapper;
import com.example.campusnotice.security.JwtService;
import java.nio.charset.StandardCharsets;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final UserMapper users;
    private final PermissionMapper permissions;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final String dummyHash;
    public AuthService(UserMapper users, PermissionMapper permissions, PasswordEncoder encoder, JwtService jwt) {
        this.users = users;
        this.permissions = permissions;
        this.encoder = encoder;
        this.jwt = jwt;
        // 账号不存在时也计算一次哈希比对，减少通过耗时猜测用户名的差异。
        this.dummyHash = encoder.encode("Dummy_login_comparison_7!");
    }
    public LoginResponse login(LoginRequest request) {
        if (request == null || request.username() == null || !request.username().matches("[A-Za-z0-9_]{1,50}")
                || request.password() == null || request.password().length() < 8 || request.password().length() > 72
                || request.password().getBytes(StandardCharsets.UTF_8).length > 72) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "登录输入格式不正确");
        }
        User user = users.findByUsername(request.username());
        boolean matched = encoder.matches(request.password(), user == null ? dummyHash : user.getPasswordHash());
        if (user == null || !matched) { throw new ApiException(HttpStatus.UNAUTHORIZED, "用户名或密码错误"); }
        List<String> authorityList = permissions.findByRole(user.getRole());
        return new LoginResponse(jwt.issue(user, authorityList), user);
    }
}
