package com.example.campusnotice.service;

import com.example.campusnotice.dto.LoginRequest;
import com.example.campusnotice.dto.LoginResponse;
import com.example.campusnotice.entity.User;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.PermissionMapper;
import com.example.campusnotice.mapper.UserMapper;
import com.example.campusnotice.security.JwtService;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.ArgumentCaptor;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** BCrypt 真验证、数据库关联权限 Mock；完整 HTTP 授权由黑盒用例另验。 */
@ExtendWith(MockitoExtension.class)
class AuthServiceTest {
    @Mock private UserMapper users;
    @Mock private PermissionMapper permissions;
    @Mock private JwtService jwt;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
    private AuthService service;

    @BeforeEach
    void setUp() {
        service = new AuthService(users, permissions, encoder, jwt);
    }

    @Test
    void correctBcryptPasswordUsesDatabaseRolePermissions() {
        User user = teacher();
        List<String> granted = List.of("user:write", "notice:write");
        when(users.findByUsername("test_teacher")).thenReturn(user);
        when(permissions.findByRole("TEACHER")).thenReturn(granted);
        when(jwt.issue(any(User.class), eq(granted))).thenReturn("unit-test-only-token");

        LoginResponse result = service.login(new LoginRequest("test_teacher", "CorrectPassword_2026!"));

        assertEquals("unit-test-only-token", result.token());
        assertEquals("test_teacher", result.user().getUsername());
        verify(permissions).findByRole("TEACHER");
        ArgumentCaptor<User> authenticated = ArgumentCaptor.forClass(User.class);
        verify(jwt).issue(authenticated.capture(), eq(granted));
        assertEquals("test_teacher", authenticated.getValue().getUsername());
        assertEquals("TEACHER", authenticated.getValue().getRole());
    }

    @Test
    void wrongPasswordIsUnauthorizedAndNeverIssuesToken() {
        when(users.findByUsername("test_teacher")).thenReturn(teacher());
        ApiException error = assertThrows(ApiException.class,
                () -> service.login(new LoginRequest("test_teacher", "WrongPassword_2026!")));
        assertEquals(HttpStatus.UNAUTHORIZED, error.getStatus());
        verify(jwt, never()).issue(any(), any());
    }

    @Test
    void missingAccountIsUnauthorizedAndNeverIssuesToken() {
        ApiException error = assertThrows(ApiException.class,
                () -> service.login(new LoginRequest("test_missing", "CorrectPassword_2026!")));
        assertEquals(HttpStatus.UNAUTHORIZED, error.getStatus());
        verify(jwt, never()).issue(any(), any());
    }

    private User teacher() {
        User user = new User();
        user.setId(1L);
        user.setUsername("test_teacher");
        user.setName("测试教师");
        user.setRole("TEACHER");
        user.setPasswordHash(encoder.encode("CorrectPassword_2026!"));
        return user;
    }
}
