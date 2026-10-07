package com.example.campusnotice.exception;

import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

/** 浏览器始终收到 message 字段，数据库细节不放进 HTTP 响应。 */
@RestControllerAdvice
public class ApiExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String, String>> api(ApiException exception) {
        return error(exception.getStatus(), exception.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> validation(MethodArgumentNotValidException exception) {
        String message = exception.getBindingResult().getFieldErrors().stream()
                .map(item -> item.getDefaultMessage()).findFirst().orElse("请求字段不正确");
        return error(HttpStatus.BAD_REQUEST, message);
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class,
            MissingServletRequestParameterException.class})
    public ResponseEntity<Map<String, String>> malformed(Exception exception) {
        return error(HttpStatus.BAD_REQUEST, "请求格式或参数类型不正确");
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<Map<String, String>> method(HttpRequestMethodNotSupportedException exception) {
        return error(HttpStatus.METHOD_NOT_ALLOWED, "不支持该请求方法");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> unexpected(Exception exception) {
        // 仅记录类型，避免请求、数据库配置或用户密码进入日志。
        log.error("API processing failed: {}", exception.getClass().getSimpleName());
        return error(HttpStatus.INTERNAL_SERVER_ERROR, "服务暂时异常，请稍后重试");
    }

    private ResponseEntity<Map<String, String>> error(HttpStatus status, String message) {
        return ResponseEntity.status(status).body(Map.of("message", message));
    }
}
