package com.example.campusnotice.config;

import com.example.campusnotice.dto.UserRequest;
import com.example.campusnotice.mapper.UserMapper;
import com.example.campusnotice.mapper.CourseMapper;
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
    private final CourseMapper courses;

    public DemoAccountsInitializer(UserMapper mapper, UserService users, ObjectMapper json,
            ConfigurableApplicationContext context,
            @Value("${app.demo.accounts-file:.runtime/demo-accounts.json}") String accountsFile, CourseMapper courses) {
        this.mapper = mapper; this.users = users; this.json = json;
        this.context = context; this.accountsFile = accountsFile;
        this.courses = courses;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        JsonNode accounts = json.readTree(Path.of(accountsFile).toFile());
        var entries = accounts.fields();
        while (entries.hasNext()) {
            var entry = entries.next();
            String key = entry.getKey();
            JsonNode account = entry.getValue();
            String username = account.path("username").asText();
            String password = account.path("password").asText();
            String role = key.startsWith("teacher") ? "TEACHER" : "STUDENT";
            String name = account.path("name").asText(role.equals("TEACHER") ? "演示教师" : "演示学生");
            if (mapper.findByUsername(username) == null) {
                users.create(new UserRequest(username, name, password, role));
            }
            var user = mapper.findByUsername(username);
            if (!role.equals(user.getRole())) { throw new IllegalStateException("演示账号角色不匹配"); }
            user.setName(name);
            mapper.update(user);
            if (role.equals("TEACHER")) {
                for (JsonNode courseName : account.path("courses")) {
                    var course = courses.findByName(courseName.asText());
                    if (course == null) { throw new IllegalStateException("请先导入演示课程"); }
                    courses.assignTeacher(course.getId(), user.getId());
                }
            }
        }
        // 不覆盖已有密码。初始化服务使用随机端口，完成后立即退出。
        System.exit(SpringApplication.exit(context));
    }
}
