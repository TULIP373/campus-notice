package com.example.campusnotice.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDateTime;

/** 用户实体：Java 属性对应 users 表中的列。 */
public class User {
    private Long id;
    private String username;
    private String name;
    @JsonIgnore
    private String passwordHash;
    private String role;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
