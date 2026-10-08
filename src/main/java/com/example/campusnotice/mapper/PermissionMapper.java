package com.example.campusnotice.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/** 登录后按角色查权限，让权限来自数据库而非前端按钮。 */
@Mapper
public interface PermissionMapper {
    @Select("SELECT permission_code FROM role_permissions WHERE role_code = #{role} ORDER BY permission_code")
    List<String> findByRole(String role);
}
