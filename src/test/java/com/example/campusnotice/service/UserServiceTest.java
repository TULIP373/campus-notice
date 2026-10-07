package com.example.campusnotice.service;

import com.example.campusnotice.dto.UserRequest;
import com.example.campusnotice.entity.User;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.UserMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** 独立规则测试：用 Mock 隔离数据库，真实 MySQL CRUD 由 check_api.py 另验。 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserMapper mapper;
    private UserService service;

    @BeforeEach
    void setUp() {
        service = new UserService(mapper);
    }

    @Test
    void createStoresMatchingBcryptInsteadOfPlaintext() {
        UserRequest request = new UserRequest("test_bcrypt", "测试学生", "TestPassword_2026!", "STUDENT");
        AtomicReference<User> stored = new AtomicReference<>();
        when(mapper.insert(any(User.class))).thenAnswer(invocation -> {
            User inserted = invocation.getArgument(0);
            inserted.setId(101L);
            // 仅供回归断言抓错证明：污染 Mock 保存值，不改生产代码。
            if (Boolean.getBoolean("test.guard.plaintext")) {
                inserted.setPasswordHash(request.password());
            }
            stored.set(inserted);
            return 1;
        });
        when(mapper.findById(101L)).thenAnswer(invocation -> stored.get());

        User result = service.create(request);

        ArgumentCaptor<User> captured = ArgumentCaptor.forClass(User.class);
        verify(mapper).insert(captured.capture());
        String hash = captured.getValue().getPasswordHash();
        assertNotEquals(request.password(), hash, "存入 Mapper 的值不得为明文密码");
        assertTrue(hash != null && hash.matches("\\$2[aby]\\$\\d{2}\\$.+"), "必须为 BCrypt 哈希");
        assertTrue(new BCryptPasswordEncoder().matches(request.password(), hash), "哈希必须能验证原密码");
        assertEquals(101L, result.getId());
        assertEquals("测试学生", result.getName());
    }

    @Test
    void duplicateUsernameConstraintIsConflict() {
        when(mapper.insert(any(User.class))).thenThrow(new DuplicateKeyException("duplicate username"));

        ApiException failure = assertThrows(ApiException.class,
                () -> service.create(new UserRequest("test_duplicate", "重复姓名", "TestPassword_2026!", "STUDENT")));

        assertEquals(HttpStatus.CONFLICT, failure.getStatus());
        verify(mapper).insert(any(User.class));
    }

    @Test
    void missingUserIsNotFound() {
        ApiException failure = assertThrows(ApiException.class, () -> service.get(404L));
        assertEquals(HttpStatus.NOT_FOUND, failure.getStatus());
    }

    @Test
    void updateWithoutPasswordKeepsOriginalHash() {
        String original = new BCryptPasswordEncoder().encode("OriginalPassword_2026!");
        User existing = user(8L, "test_keep", original);
        when(mapper.findById(8L)).thenReturn(existing);
        // 实现可以跳过未更名的重复检查；此依赖不影响保留哈希的验收口径。
        lenient().when(mapper.findByUsername("test_keep")).thenReturn(existing);
        when(mapper.update(any(User.class))).thenReturn(1);

        User result = service.update(8L, new UserRequest("test_keep", "修改后姓名", null, "STUDENT"));

        ArgumentCaptor<User> captured = ArgumentCaptor.forClass(User.class);
        verify(mapper).update(captured.capture());
        assertEquals(original, captured.getValue().getPasswordHash(), "省略密码必须保留原哈希");
        assertEquals(original, result.getPasswordHash());
        assertEquals("修改后姓名", captured.getValue().getName());
    }

    @Test
    void deleteAffectingNoRowsIsNotFound() {
        when(mapper.deleteById(404L)).thenReturn(0);
        ApiException failure = assertThrows(ApiException.class, () -> service.delete(404L));
        assertEquals(HttpStatus.NOT_FOUND, failure.getStatus());
        verify(mapper).deleteById(404L);
    }

    @Test
    void listDelegatesToMapper() {
        User existing = user(9L, "test_list", "internalHash");
        when(mapper.findAll()).thenReturn(List.of(existing));
        assertEquals(List.of(existing), service.list());
    }

    @Test
    void publicJsonDoesNotContainInternalHash() throws Exception {
        User internal = user(10L, "test_json", "private_hash_value");
        String json = new ObjectMapper().writeValueAsString(internal);
        assertFalse(json.contains("passwordHash"));
        assertFalse(json.contains("private_hash_value"));
        assertTrue(json.contains("test_json"));
    }

    private User user(Long id, String username, String hash) {
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setName("测试姓名");
        user.setPasswordHash(hash);
        user.setRole("STUDENT");
        return user;
    }
}
