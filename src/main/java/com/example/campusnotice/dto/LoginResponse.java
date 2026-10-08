package com.example.campusnotice.dto;

import com.example.campusnotice.entity.User;

public record LoginResponse(String token, User user) {
}
