
CREATE DATABASE IF NOT EXISTS job_search_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE job_search_db;

-- 1. Bang nguoi dung
CREATE TABLE IF NOT EXISTS Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('job_seeker', 'employer')
        NOT NULL DEFAULT 'job_seeker',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bang cong viec
CREATE TABLE IF NOT EXISTS Jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employer_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    salary DECIMAL(12,2),
    location VARCHAR(255),
    deadline DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employer_id)
        REFERENCES Users(id)
);

-- 3. Bang ung tuyen
CREATE TABLE IF NOT EXISTS Applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    job_id INT NOT NULL,
    cv_url VARCHAR(255),
    status ENUM('pending', 'approved', 'rejected')
        NOT NULL DEFAULT 'pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (user_id, job_id),

    FOREIGN KEY (user_id)
        REFERENCES Users(id),

    FOREIGN KEY (job_id)
        REFERENCES Jobs(id)
);
