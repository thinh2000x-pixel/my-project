-- DATABASE: job_search_db
-- He thong quan ly viec lam va tuyen dung (MySQL/MariaDB XAMPP)

CREATE DATABASE IF NOT EXISTS job_search_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE job_search_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS saved_jobs;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS resumes;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS employer_profiles;
DROP TABLE IF EXISTS seeker_profiles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (role_name, description) VALUES
('job_seeker', 'Nguoi tim viec'),
('employer', 'Nha tuyen dung'),
('admin', 'Quan tri vien');

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id TINYINT UNSIGNED NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    avatar_url VARCHAR(500) NULL,
    status ENUM('active', 'locked', 'pending') NOT NULL DEFAULT 'active',
    email_verified_at DATETIME NULL,
    last_login_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id)
        REFERENCES roles(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_users_role_status (role_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE seeker_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    date_of_birth DATE NULL,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say') NULL,
    address VARCHAR(255) NULL,
    education VARCHAR(180) NULL,
    experience_years DECIMAL(4,1) NOT NULL DEFAULT 0,
    desired_position VARCHAR(180) NULL,
    desired_salary_min DECIMAL(12,2) NULL,
    desired_salary_max DECIMAL(12,2) NULL,
    introduction TEXT NULL,
    skills TEXT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_seeker_profile_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
        CONSTRAINT chk_seeker_experience CHECK (experience_years >= 0),
    CONSTRAINT chk_seeker_salary CHECK (
        desired_salary_min IS NULL OR desired_salary_max IS NULL
        OR desired_salary_max >= desired_salary_min
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE employer_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    company_name VARCHAR(180) NOT NULL,
    tax_code VARCHAR(40) NULL UNIQUE,
    company_email VARCHAR(190) NULL,
    company_phone VARCHAR(20) NULL,
    website VARCHAR(255) NULL,
    address VARCHAR(255) NULL,
    company_size ENUM('1-10', '11-50', '51-200', '201-500', '500+') NULL,
    industry VARCHAR(120) NULL,
    description TEXT NULL,
    logo_url VARCHAR(500) NULL,
    verified_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_employer_profile_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(120) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO categories (category_name, description) VALUES
('Cong nghe thong tin', 'Lap trinh, phan mem, mang va he thong'),
('Kiem thu phan mem', 'QA, QC va Software Tester'),
('Thiet ke', 'UI/UX va thiet ke do hoa'),
('Marketing', 'Marketing, truyen thong va noi dung'),
('Ke toan', 'Ke toan va tai chinh'),
('Ban hang', 'Kinh doanh va cham soc khach hang'),
('Nhan su', 'Tuyen dung va quan tri nhan su'),
('Khac', 'Cac linh vuc khac');

CREATE TABLE jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employer_id BIGINT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NULL,
    title VARCHAR(180) NOT NULL,
    description LONGTEXT NOT NULL,
    requirements LONGTEXT NULL,
    benefits LONGTEXT NULL,
    job_type ENUM('full_time', 'part_time', 'internship', 'contract', 'freelance') NOT NULL DEFAULT 'full_time',
    workplace ENUM('onsite', 'remote', 'hybrid') NOT NULL DEFAULT 'onsite',
    location VARCHAR(255) NULL,
    salary_min DECIMAL(12,2) NULL,
    salary_max DECIMAL(12,2) NULL,
    salary_negotiable TINYINT(1) NOT NULL DEFAULT 0,
    quantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    deadline DATE NULL,
    status ENUM('draft', 'pending', 'published', 'closed', 'rejected') NOT NULL DEFAULT 'pending',
    published_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_jobs_employer FOREIGN KEY (employer_id)
        REFERENCES employer_profiles(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_jobs_category FOREIGN KEY (category_id)
        REFERENCES categories(id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_job_salary CHECK (
        salary_min IS NULL OR salary_max IS NULL OR salary_max >= salary_min
    ),
    CONSTRAINT chk_job_quantity CHECK (quantity >= 1),
    INDEX idx_jobs_status_deadline (status, deadline),
    INDEX idx_jobs_category_status (category_id, status),
    INDEX idx_jobs_location (location),
    INDEX idx_jobs_title (title),
    FULLTEXT INDEX idx_jobs_search (title, description, requirements)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE resumes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    resume_title VARCHAR(180) NOT NULL,
    file_url VARCHAR(500) NULL,
    summary TEXT NULL,
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_resumes_user FOREIGN KEY (user_id)
        REFERENCES seeker_profiles(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_resumes_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE applications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    job_id BIGINT UNSIGNED NOT NULL,
    applicant_id BIGINT UNSIGNED NOT NULL,
    resume_id BIGINT UNSIGNED NULL,
    cover_letter TEXT NULL,
    status ENUM('submitted', 'reviewing', 'interview', 'accepted', 'rejected', 'withdrawn')
        NOT NULL DEFAULT 'submitted',
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_applications_job FOREIGN KEY (job_id)
        REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_applications_applicant FOREIGN KEY (applicant_id)
        REFERENCES seeker_profiles(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_applications_resume FOREIGN KEY (resume_id)
        REFERENCES resumes(id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT uq_application_job_applicant UNIQUE (job_id, applicant_id),
    INDEX idx_applications_status (status),
    INDEX idx_applications_applicant (applicant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE saved_jobs (
    user_id BIGINT UNSIGNED NOT NULL,
    job_id BIGINT UNSIGNED NOT NULL,
    saved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, job_id),
    CONSTRAINT fk_saved_jobs_user FOREIGN KEY (user_id)
        REFERENCES seeker_profiles(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_saved_jobs_job FOREIGN KEY (job_id)
        REFERENCES jobs(id) ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_saved_jobs_job (job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


