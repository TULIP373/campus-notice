package com.example.campusnotice.service;

import com.example.campusnotice.dto.UserRequest;
import com.example.campusnotice.entity.User;
import com.example.campusnotice.exception.ApiException;
import com.example.campusnotice.mapper.UserMapper;
import java.nio.charset.StandardCharsets;
import java.util.List;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

/** Service 负责业务规则，Controller 和 Mapper 不负责密码处理。 */
@Service
public class UserService {
    private final UserMapper userMapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(UserMapper userMapper) { this.userMapper = userMapper; }

    public List<User> list() { return userMapper.findAll(); }

    public User get(Long id) {
        requireId(id);
        User user = userMapper.findById(id);
        if (user == null) { throw new ApiException(HttpStatus.NOT_FOUND, "用户不存在"); }
        return user;
    }

    public User create(UserRequest request) {
        validateUser(request);
        requirePassword(request.password());
        User user = new User();
        applyFields(user, request);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        try {
            userMapper.insert(user);
        } catch (DuplicateKeyException exception) {
            throw new ApiException(HttpStatus.CONFLICT, "用户名已存在");
        }
        return get(user.getId());
    }

    public User update(Long id, UserRequest request) {
        validateUser(request);
        User user = get(id);
        applyFields(user, request);
        // 修改姓名等资料时，未填写新密码就保留原密码哈希。
        if (request.password() != null && !request.password().isBlank()) {
            requirePassword(request.password());
            user.setPasswordHash(passwordEncoder.encode(request.password()));
        }
        try {
            if (userMapper.update(user) == 0) {
                throw new ApiException(HttpStatus.NOT_FOUND, "用户不存在");
            }
        } catch (DuplicateKeyException exception) {
            throw new ApiException(HttpStatus.CONFLICT, "用户名已存在");
        }
        return get(id);
    }

    public void delete(Long id) {
        requireId(id);
        if (userMapper.deleteById(id) == 0) {
            throw new ApiException(HttpStatus.NOT_FOUND, "用户不存在");
        }
    }

    private void applyFields(User user, UserRequest request) {
        user.setUsername(request.username());
        user.setName(request.name().trim());
        user.setRole(request.role() == null ? "STUDENT" : request.role());
    }

    private void validateUser(UserRequest request) {
        if (request == null || request.username() == null || !request.username().matches("[A-Za-z0-9_]{1,50}")
                || request.name() == null || request.name().isBlank() || request.name().length() > 100) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "用户名或姓名格式不正确");
        }
        if (request.role() != null && !List.of("STUDENT", "TEACHER").contains(request.role())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "角色必须为STUDENT或TEACHER");
        }
    }

    private void requirePassword(String password) {
        if (password == null || password.isBlank() || password.length() < 8 || password.length() > 72
                || password.getBytes(StandardCharsets.UTF_8).length > 72) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "密码需为8至72个字符，UTF-8长度最多72字节");
        }
    }

    private void requireId(Long id) {
        if (id == null || id <= 0) { throw new ApiException(HttpStatus.BAD_REQUEST, "用户编号必须为正整数"); }
    }
}
