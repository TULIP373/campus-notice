package com.example.campusnotice.config;

import java.time.Instant;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwsHeader;

import static org.junit.jupiter.api.Assertions.*;

/** 调用生产 SecurityConfig 的 Bean 工厂，避免另建验证器导致假覆盖。 */
class SecurityConfigTest {
    // 仅本单测使用的公开模拟密钥；不是本机或交付运行密钥。
    private static final String TEST_SECRET = "unit-test-only-signature-key-32-bytes-A!";
    private static final String WRONG_SECRET = "unit-test-only-signature-key-32-bytes-B!";
    private final SecurityConfig config = new SecurityConfig();

    @Test
    void validHs256SignatureIsAccepted() {
        JwtEncoder encoder = config.jwtEncoder(TEST_SECRET);
        JwtDecoder decoder = config.jwtDecoder(TEST_SECRET);
        String encoded = token(encoder, Instant.now().minusSeconds(10), Instant.now().plusSeconds(300));
        Jwt verified = decoder.decode(encoded);
        assertEquals("test_subject", verified.getSubject());
        assertEquals("HS256", verified.getHeaders().get("alg"));
        assertNotNull(verified.getExpiresAt());
    }

    @Test
    void tokenSignedWithAnotherKeyIsRejected() {
        JwtEncoder attacker = config.jwtEncoder(WRONG_SECRET);
        String encoded = token(attacker, Instant.now().minusSeconds(10), Instant.now().plusSeconds(300));
        assertThrows(JwtException.class, () -> config.jwtDecoder(TEST_SECRET).decode(encoded));
    }

    @Test
    void validSignatureWithExpiredTimestampIsRejected() {
        JwtEncoder encoder = config.jwtEncoder(TEST_SECRET);
        String expired = token(encoder, Instant.now().minusSeconds(3600), Instant.now().minusSeconds(300));
        assertThrows(JwtException.class, () -> config.jwtDecoder(TEST_SECRET).decode(expired));
    }

    private String token(JwtEncoder encoder, Instant issuedAt, Instant expiresAt) {
        JwtClaimsSet claims = JwtClaimsSet.builder().subject("test_subject")
                .issuedAt(issuedAt).expiresAt(expiresAt).build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        return encoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }
}
