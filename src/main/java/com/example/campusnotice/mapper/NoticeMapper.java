package com.example.campusnotice.mapper;

import com.example.campusnotice.entity.Notice;
import com.example.campusnotice.entity.NoticeAttachment;
import java.util.List;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface NoticeMapper {
    @Select("""
            <script>
            SELECT id, course_id, title, content, submission_requirements, report_format, deadline, source, type, created_at
            FROM notices
            <where>
              <if test="courseId != null">course_id = #{courseId}</if>
              <if test="q != null and q != ''">AND (title LIKE CONCAT('%', #{q}, '%') OR content LIKE CONCAT('%', #{q}, '%'))</if>
            </where>
            ORDER BY id DESC
            </script>
            """)
    List<Notice> findAll(@Param("courseId") Long courseId, @Param("q") String q);

    @Select("SELECT id, course_id, title, content, submission_requirements, report_format, deadline, source, type, created_at FROM notices WHERE id = #{id}")
    Notice findById(Long id);

    @Select("SELECT id, filename, resource_name, content FROM notice_attachments WHERE notice_id = #{noticeId} ORDER BY id")
    List<NoticeAttachment> findAttachments(Long noticeId);

    @Insert("INSERT INTO notices (course_id,title,content,submission_requirements,report_format,deadline,source,type) VALUES (#{courseId},#{title},#{content},#{submissionRequirements},#{reportFormat},#{deadline},#{source},#{type})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Notice notice);

    @Update("UPDATE notices SET course_id=#{courseId},title=#{title},content=#{content},submission_requirements=#{submissionRequirements},report_format=#{reportFormat},deadline=#{deadline},source=#{source},type=#{type} WHERE id=#{id}")
    int update(Notice notice);

    @Delete("DELETE FROM notices WHERE id = #{id}")
    int deleteById(Long id);
}
