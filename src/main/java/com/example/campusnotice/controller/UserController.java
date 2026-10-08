package com.example.campusnotice.controller;

import com.example.campusnotice.dto.UserRequest;
import com.example.campusnotice.entity.User;
import com.example.campusnotice.service.UserService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Controller 接收 HTTP 请求并把处理工作交给 Service。 */
@RestController
@RequestMapping("/api/users")
@PreAuthorize("hasRole('TEACHER') and hasAuthority('user:write')")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) { this.userService = userService; }

    @GetMapping
    public List<User> list() { return userService.list(); }

    @GetMapping("/{id}")
    public User get(@PathVariable Long id) { return userService.get(id); }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public User create(@Valid @RequestBody UserRequest request) { return userService.create(request); }

    @PutMapping("/{id}")
    public User update(@PathVariable Long id, @Valid @RequestBody UserRequest request) {
        return userService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) { userService.delete(id); }
}
