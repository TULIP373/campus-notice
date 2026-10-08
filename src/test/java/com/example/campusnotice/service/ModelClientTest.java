package com.example.campusnotice.service;

import com.example.campusnotice.exception.ApiException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static org.junit.jupiter.api.Assertions.*;

/** JDK 本地 HTTP 协议桩只验证网络边界；不会冒充真实大模型结果。 */
class ModelClientTest {
    @Test
    void connectionRefusalIsServiceUnavailableWithSafeMessage() throws Exception {
        int port;
        try (ServerSocket reserved = new ServerSocket(0)) {
            port = reserved.getLocalPort();
        }
        ModelClient client = new ModelClient("http://127.0.0.1:" + port + "/ask");
        ApiException error = assertThrows(ApiException.class, () -> client.ask("单测规则", "单测问题"));
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, error.getStatus());
        assertNotNull(error.getMessage());
        assertFalse(error.getMessage().isBlank());
        assertFalse(error.getMessage().contains("单测规则"));
        assertFalse(error.getMessage().contains("单测问题"));
    }

    @Test
    void upstreamFailureDoesNotExposeResponseBody() throws Exception {
        String privateMarker = "unit_private_upstream_value_do_not_echo";
        HttpServer server = stub(500, "{\"error\":\"" + privateMarker + "\"}", null);
        try {
            ApiException error = assertThrows(ApiException.class,
                    () -> new ModelClient(url(server)).ask("单测规则", "单测问题"));
            assertEquals(HttpStatus.SERVICE_UNAVAILABLE, error.getStatus());
            assertFalse(error.getMessage().contains(privateMarker), "不能把上游响应裸值暴露给学生");
        } finally {
            server.stop(0);
        }
    }

    @Test
    void successfulHttpProtocolSendsSeparateSystemAndUser() throws Exception {
        AtomicReference<String> captured = new AtomicReference<>();
        HttpServer server = stub(200, "{\"answer\":\"这是本地协议桩响应[1]\"}", captured);
        try {
            String answer = new ModelClient(url(server)).ask("单测System规则", "单测User问题");
            assertEquals("这是本地协议桩响应[1]", answer);
            var body = new ObjectMapper().readTree(captured.get());
            assertEquals("单测System规则", body.get("system").asText());
            assertEquals("单测User问题", body.get("user").asText());
        } finally {
            server.stop(0);
        }
    }

    @Test
    void malformedSuccessfulResponseIsBadGateway() throws Exception {
        HttpServer server = stub(200, "{\"answer\":\"\"}", null);
        try {
            ApiException error = assertThrows(ApiException.class,
                    () -> new ModelClient(url(server)).ask("单测规则", "单测问题"));
            assertEquals(HttpStatus.BAD_GATEWAY, error.getStatus());
        } finally {
            server.stop(0);
        }
    }

    private HttpServer stub(int status, String json, AtomicReference<String> capture) throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/ask", exchange -> {
            if (!"POST".equals(exchange.getRequestMethod())) {
                exchange.sendResponseHeaders(405, -1);
                exchange.close();
                return;
            }
            String request = new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
            if (capture != null) { capture.set(request); }
            byte[] response = json.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
            exchange.sendResponseHeaders(status, response.length);
            try (var output = exchange.getResponseBody()) { output.write(response); }
        });
        server.start();
        return server;
    }

    private String url(HttpServer server) {
        return "http://127.0.0.1:" + server.getAddress().getPort() + "/ask";
    }
}
