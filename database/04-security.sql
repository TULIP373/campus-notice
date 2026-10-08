-- 实验四：一名用户只有一种角色，角色可拥有多个权限。
CREATE TABLE IF NOT EXISTS roles (
    code VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS permissions (
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS role_permissions (
    role_code VARCHAR(20) NOT NULL,
    permission_code VARCHAR(50) NOT NULL,
    PRIMARY KEY (role_code, permission_code),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_code) REFERENCES roles(code),
    CONSTRAINT fk_rp_permission FOREIGN KEY (permission_code) REFERENCES permissions(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (code, name) VALUES ('STUDENT', '学生'), ('TEACHER', '教师')
ON DUPLICATE KEY UPDATE name = VALUES(name);
INSERT INTO permissions (code, name) VALUES
('course:read', '查看课程'), ('notice:read', '查看通知与资料'),
('notice:write', '维护通知与资料'), ('user:write', '维护用户'), ('ask:use', '使用课程问答')
ON DUPLICATE KEY UPDATE name = VALUES(name);
INSERT IGNORE INTO role_permissions (role_code, permission_code) VALUES
('STUDENT', 'course:read'), ('STUDENT', 'notice:read'), ('STUDENT', 'ask:use'),
('TEACHER', 'course:read'), ('TEACHER', 'notice:read'), ('TEACHER', 'notice:write'),
('TEACHER', 'user:write'), ('TEACHER', 'ask:use');

-- MySQL 没有 ADD CONSTRAINT IF NOT EXISTS，先检查元数据再添加，重复执行无副作用。
SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'users'
      AND CONSTRAINT_NAME = 'fk_users_role' AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @fk_sql = IF(@fk_exists = 0,
    'ALTER TABLE users ADD CONSTRAINT fk_users_role FOREIGN KEY (role) REFERENCES roles(code)',
    'SELECT 1');
PREPARE fk_statement FROM @fk_sql;
EXECUTE fk_statement;
DEALLOCATE PREPARE fk_statement;
