package com.example.campusnotice.config;

import com.example.campusnotice.dto.UserRequest;
import com.example.campusnotice.mapper.UserMapper;
import com.example.campusnotice.service.UserService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.file.Path;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;

/** 只在显式初始化命令启用，密码从被Git忽略的文件读取，不记录到日志。 */
@Component
@ConditionalOnProperty(name = "app.demo.initialize", havingValue = "true")
public class DemoAccountsInitializer implements ApplicationRunner {
    private final UserMapper mapper;
    private final UserService users;
    private final ObjectMapper json;
    private final ConfigurableApplicationContext context;
    private final String accountsFile;

    public DemoAccountsInitializer(UserMapper mapper, UserService users, ObjectMapper json,
            ConfigurableApplicationContext context,
            @Value("${app.demo.accounts-file:.runtime/demo-accounts.json}") String accountsFile) {
        this.mapper = mapper; this.users = users; this.json = json;
        this.context = context; this.accountsFile = accountsFile;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        JsonNode accounts = json.readTree(Path.of(accountsFile).toFile());
        for (String key : new String[]{"teacher", "student"}) {
            JsonNode account = accounts.path(key);
            String username = account.path("username").asText();
            String password = account.path("password").asText();
            String role = key.equals("teacher") ? "TEACHER" : "STUDENT";
            if (mapper.findByUsername(username) == null) {
                users.create(new UserRequest(username, key.equals("teacher") ? "演示教师" : "演示学生", password, role));
            }
        }
        // 不覆盖已有密码。初始化服务使用随机端口，完成后立即退出。
        System.exit(SpringApplication.exit(context));
    }
}
