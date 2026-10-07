package com.example.campusnotice;

import com.example.campusnotice.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest
class CampusNoticeApplicationTests {

    // 测试配置排除真实数据源，本上下文用 Mockito Bean 提供 Mapper 依赖。
    @MockitoBean
    UserMapper userMapper;

    @Test
    void contextLoads() {
    }

}
