CREATE TABLE IF NOT EXISTS courses (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL DEFAULT '',
    PRIMARY KEY (id),
    UNIQUE KEY uk_courses_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS notices (
    id BIGINT NOT NULL AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    submission_requirements VARCHAR(2000),
    report_format VARCHAR(1000),
    deadline DATETIME NULL,
    source VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notices_course (course_id),
    CONSTRAINT fk_notices_course FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT ck_notices_type CHECK (type IN ('NOTICE', 'MATERIAL'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notice_attachments (
    id BIGINT NOT NULL AUTO_INCREMENT,
    notice_id BIGINT NOT NULL,
    filename VARCHAR(200) NOT NULL,
    resource_name VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_notice_attachment (notice_id, resource_name),
    CONSTRAINT fk_attachment_notice FOREIGN KEY (notice_id) REFERENCES notices(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS course_teachers (
    course_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    PRIMARY KEY (course_id,user_id),
    CONSTRAINT fk_teacher_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_teacher_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
