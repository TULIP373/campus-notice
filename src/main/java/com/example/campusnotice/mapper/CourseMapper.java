package com.example.campusnotice.mapper;

import com.example.campusnotice.entity.Course;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface CourseMapper {
    @Select("SELECT id, name, description FROM courses ORDER BY id")
    List<Course> findAll();
    @Select("SELECT id, name, description FROM courses WHERE id = #{id}")
    Course findById(Long id);

    @Select("SELECT c.id, c.name, c.description FROM courses c JOIN course_teachers ct ON ct.course_id=c.id JOIN users u ON u.id=ct.user_id WHERE u.username=#{username} ORDER BY c.id")
    List<Course> findByTeacher(String username);

    @Select("SELECT COUNT(*) FROM course_teachers ct JOIN users u ON u.id=ct.user_id WHERE ct.course_id=#{courseId} AND u.username=#{username}")
    int isTeacher(@Param("courseId") Long courseId, @Param("username") String username);

    @Select("SELECT id, name, description FROM courses WHERE name=#{name}")
    Course findByName(String name);

    @Insert("INSERT IGNORE INTO course_teachers(course_id,user_id) VALUES(#{courseId},#{userId})")
    int assignTeacher(@Param("courseId") Long courseId, @Param("userId") Long userId);
}
