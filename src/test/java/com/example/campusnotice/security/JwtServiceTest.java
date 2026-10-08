package com.example.campusnotice.security;

import com.example.campusnotice.config.SecurityConfig;
import com.example.campusnotice.entity.User;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTest {
    private static final String TEST_SECRET = "unit-test-only-signature-key-32-bytes-A!";

    @Test
    void realIssuerSignsFiniteTokenWithRoleAndPermissions() {
        SecurityConfig config = new SecurityConfig();
        User user = new User();
        user.setId(1L);
        user.setUsername("test_teacher");
        user.setName("测试教师");
        user.setRole("TEACHER");
        user.setPasswordHash("internal-user-hash-must-not-appear");
        List<String> permissions = List.of("user:write", "notice:write");

        String signed = new JwtService(config.jwtEncoder(TEST_SECRET)).issue(user, permissions);
        Jwt token = config.jwtDecoder(TEST_SECRET).decode(signed);

        assertEquals("test_teacher", token.getSubject());
        assertEquals("campus-notice", token.getClaimAsString("iss"));
        assertEquals("TEACHER", token.getClaimAsString("role"));
        assertEquals(permissions, token.getClaimAsStringList("permissions"));
        assertNotNull(token.getIssuedAt());
        assertNotNull(token.getExpiresAt());
        assertTrue(token.getExpiresAt().isAfter(Instant.now()));
        assertEquals(Duration.ofMinutes(30), Duration.between(token.getIssuedAt(), token.getExpiresAt()));
        assertFalse(token.getClaims().containsKey("password"));
        assertFalse(token.getClaims().containsKey("passwordHash"));
        assertFalse(token.getClaims().containsValue("internal-user-hash-must-not-appear"));
    }
}
