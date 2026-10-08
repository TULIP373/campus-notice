package com.example.campusnotice.service;

import com.example.campusnotice.exception.ApiException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/** Java通过一个小型本地HTTP接口连接真正的大模型，不提供伪造成功回退。 */
@Service
public class ModelClient {
    private final URI endpoint;
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final ObjectMapper json = new ObjectMapper();

    public ModelClient(@Value("${app.model.url:http://127.0.0.1:8787/ask}") String url) {
        endpoint = URI.create(url);
        if (!("http".equals(endpoint.getScheme()) || "https".equals(endpoint.getScheme())) || endpoint.getUserInfo() != null) {
            throw new IllegalArgumentException("模型接口地址必须为HTTP或HTTPS且不能包含账户凭据");
        }
    }

    public String ask(String system, String user) {
        try {
            String body = json.writeValueAsString(Map.of("system", system, "user", user));
            HttpRequest request = HttpRequest.newBuilder(endpoint).timeout(Duration.ofSeconds(120))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body)).build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "模型服务暂不可用，请检查本地模型桥接服务");
            }
            JsonNode payload;
            try {
                payload = json.readTree(response.body());
            } catch (IOException invalidJson) {
                throw new ApiException(HttpStatus.BAD_GATEWAY, "模型接口返回格式不正确");
            }
            JsonNode answer = payload == null ? null : payload.get("answer");
            if (answer == null || !answer.isTextual() || answer.asText().isBlank()) {
                throw new ApiException(HttpStatus.BAD_GATEWAY, "模型没有返回有效回答");
            }
            return answer.asText().trim();
        } catch (HttpTimeoutException exception) {
            throw new ApiException(HttpStatus.GATEWAY_TIMEOUT, "模型回答超时，请稍后重试");
        } catch (IOException exception) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "无法连接模型服务，请先启动本地模型桥接服务");
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "模型请求已中断，请重试");
        }
    }
}
