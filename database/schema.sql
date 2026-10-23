
-- DATABASE: job_search_db
-- De tai: Phan mem quan ly viec lam va tuyen dung



CREATE DATABASE IF NOT EXISTS job_search_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE job_search_db;


-- 1. Vai tro nguoi dung: ung vien, nha tuyen dung, quan tri vien
CREATE TABLE IF NOT EXISTS roles (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tai khoan dang nhap
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id TINYINT UNSIGNED NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    status ENUM('active', 'locked', 'pending') NOT NULL DEFAULT 'active',
    email_verified_at DATETIME NULL,
    last_login_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role
      FOREIGN KEY (role_id) REFERENCES roles(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_users_role_status (role_id, status),
    INDEX idx_users_full_name (full_name)
) ENGINE=InnoDB;

-- 3. Ho so ung vien / sinh vien tim viec
CREATE TABLE IF NOT EXISTS job_seeker_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    date_of_birth DATE NULL,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say') NULL,
    address VARCHAR(255),
    education VARCHAR(255),
    experience_years DECIMAL(4,1) NOT NULL DEFAULT 0,
    summary TEXT,
    desired_salary_min DECIMAL(12,2) NULL,
    desired_salary_max DECIMAL(12,2) NULL,
    desired_location VARCHAR(255),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_seeker_profile_user
      FOREIGN KEY (user_id) REFERENCES users(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_experience_years CHECK (experience_years >= 0),
    CONSTRAINT chk_desired_salary CHECK (
      desired_salary_min IS NULL OR desired_salary_max IS NULL
      OR desired_salary_max >= desired_salary_min
    )
) ENGINE=InnoDB;

-- 4. Ho so nha tuyen dung / cong ty
CREATE TABLE IF NOT EXISTS employer_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    company_name VARCHAR(180) NOT NULL,
    tax_code VARCHAR(40) UNIQUE,
    company_email VARCHAR(190),
    company_phone VARCHAR(20),
    website VARCHAR(255),
    address VARCHAR(255),
    company_size ENUM('1-10', '11-50', '51-200', '201-500', '500+') NULL,
    industry VARCHAR(120),
    description TEXT,
    logo_url VARCHAR(500),
    verified_at DATETIME NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_employer_profile_user
          NOT NULL DEFAULT 'fresher',
    salary_min DECIMAL(12,2) NULL,
    salary_max DECIMAL(12,2) NULL,
    salary_negotiable BOOLEAN NOT NULL DEFAULT FALSE,
    location VARCHAR(255),
    quantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    deadline DATE NULL,
    status ENUM('draft', 'pending', 'published', 'closed', 'rejected')
      NOT NULL DEFAULT 'pending',
    published_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_jobs_employer
      FOREIGN KEY (employer_id) REFERENCES employer_profiles(user_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_jobs_category
      FOREIGN KEY (category_id) REFERENCES categories(id)
      ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_job_salary CHECK (
      salary_min IS NULL OR salary_max IS NULL OR salary_max >= salary_min
    ),
    CONSTRAINT chk_job_quantity CHECK (quantity >= 1),
    INDEX idx_jobs_status_deadline (status, deadline),
    INDEX idx_jobs_category_status (category_id, status),
    INDEX idx_jobs_location (location),
    INDEX idx_jobs_title (title),
    INDEX idx_jobs_employer (employer_id),
    FULLTEXT INDEX ft_jobs_search (title, description, requirements)
) ENGINE=InnoDB;

-- 10. Ky nang yeu cau cho tung cong viec (nhieu-nhieu)
CREATE TABLE IF NOT EXISTS job_skills (
    job_id BIGINT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (job_id, skill_id),
    CONSTRAINT fk_job_skill_job
      FOREIGN KEY (job_id) REFERENCES jobs(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_job_skill_skill
      FOREIGN KEY (skill_id) REFERENCES skills(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11. Ho so ung tuyen
CREATE TABLE IF NOT EXISTS applications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    job_id BIGINT UNSIGNED NOT NULL,
    applicant_id BIGINT UNSIGNED NOT NULL,
    resume_id BIGINT UNSIGNED NULL,
    cover_letter TEXT,
    status ENUM('submitted', 'viewed', 'shortlisted', 'interview', 'accepted', 'rejected', 'withdrawn')
      NOT NULL DEFAULT 'submitted',
    employer_note TEXT,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_application_job_applicant UNIQUE (job_id, applicant_id),
    CONSTRAINT fk_applications_job
      FOREIGN KEY (job_id) REFERENCES jobs(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_applications_applicant
      FOREIGN KEY (applicant_id) REFERENCES job_seeker_profiles(user_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_applications_resume
      FOREIGN KEY (resume_id) REFERENCES resumes(id)
      ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_applications_applicant (applicant_id, applied_at),
    INDEX idx_applications_job_status (job_id, status)
) ENGINE=InnoDB;

-- 12. Cong viec da luu
CREATE TABLE IF NOT EXISTS saved_jobs (
    user_id BIGINT UNSIGNED NOT NULL,
    job_id BIGINT UNSIGNED NOT NULL,
    saved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, job_id),
    CONSTRAINT fk_saved_jobs_user
      FOREIGN KEY (user_id) REFERENCES job_seeker_profiles(user_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_saved_jobs_job
      FOREIGN KEY (job_id) REFERENCES jobs(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 13. Thong bao
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL DEFAULT 'general',
    related_url VARCHAR(500),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user
      FOREIGN KEY (user_id) REFERENCES users(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_notifications_user_read (user_id, is_read, created_at)
) ENGINE=InnoDB;


-- Kiem tra sau khi import
SHOW TABLES;
