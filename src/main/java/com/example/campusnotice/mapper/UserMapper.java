package com.example.campusnotice.mapper;

import com.example.campusnotice.entity.User;
import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/** Mapper 只处理 SQL；业务规则放到后续的 Service。 */
@Mapper
public interface UserMapper {
    @Select("SELECT id, username, name, password_hash, role, created_at FROM users ORDER BY id")
    List<User> findAll();

    @Select("SELECT id, username, name, password_hash, role, created_at FROM users WHERE id = #{id}")
    User findById(Long id);

    @Select("SELECT id, username, name, password_hash, role, created_at FROM users WHERE username = #{username}")
    User findByUsername(String username);

    // #{} 把输入当作参数传入，避免把用户内容拼成 SQL。
    @Insert("INSERT INTO users (username, name, password_hash, role) VALUES (#{username}, #{name}, #{passwordHash}, #{role})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(User user);

    @Update("UPDATE users SET username = #{username}, name = #{name}, password_hash = #{passwordHash}, role = #{role} WHERE id = #{id}")
    int update(User user);

    @Delete("DELETE FROM users WHERE id = #{id}")
    int deleteById(Long id);
}
