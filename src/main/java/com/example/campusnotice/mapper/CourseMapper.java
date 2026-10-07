package com.example.campusnotice.mapper;

import com.example.campusnotice.entity.Course;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CourseMapper {
    @Select("SELECT id, name, description FROM courses ORDER BY id")
    List<Course> findAll();
    @Select("SELECT id, name, description FROM courses WHERE id = #{id}")
    Course findById(Long id);
}
