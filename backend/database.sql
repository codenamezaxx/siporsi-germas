-- =============================================================
-- Germas Backend Schema & Seed Data
-- Target Platform : MySQL / MariaDB (InnoDB, utf8mb4)
-- Generated       : 2025-12-16
-- =============================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE DATABASE IF NOT EXISTS germas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE germas;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS laporan_submission_sections;
DROP TABLE IF EXISTS laporan_submissions;
DROP TABLE IF EXISTS laporan_sections;
DROP TABLE IF EXISTS laporan_templates;
DROP TABLE IF EXISTS evaluation_answers;
DROP TABLE IF EXISTS evaluation_submissions;
DROP TABLE IF EXISTS evaluasi_questions;
DROP TABLE IF EXISTS evaluasi_clusters;
DROP TABLE IF EXISTS evaluation_categories;
DROP TABLE IF EXISTS admin_invite_codes;
DROP TABLE IF EXISTS submission_status_logs;
DROP TABLE IF EXISTS personal_access_tokens;
DROP TABLE IF EXISTS failed_jobs;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS instansi;
DROP TABLE IF EXISTS instansi_levels;
DROP TABLE IF EXISTS migrations;
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------
-- Master Reference Tables
-- -------------------------------------------------------------
CREATE TABLE instansi_levels (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description VARCHAR(255) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE instansi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(200) NOT NULL,
  category ENUM('dinas','badan','biro','lembaga','perusahaan','institusi','lain') NOT NULL DEFAULT 'dinas',
  level_id BIGINT UNSIGNED NULL,
  address VARCHAR(255) NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(150) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_instansi_name (name),
  FOREIGN KEY (level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Authentication & Support Tables (Laravel compatible)
-- -------------------------------------------------------------
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  email_verified_at TIMESTAMP NULL,
  password VARCHAR(255) NOT NULL,
  remember_token VARCHAR(100) NULL,
  role ENUM('super_admin','admin','verifikator','viewer') NOT NULL DEFAULT 'admin',
  instansi_id BIGINT UNSIGNED NULL,
  instansi_level_id BIGINT UNSIGNED NULL,
  admin_code VARCHAR(10) NULL,
  phone VARCHAR(50) NULL,
  photo_url VARCHAR(255) NULL,
  last_login_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instansi_id) REFERENCES instansi(id) ON DELETE SET NULL,
  FOREIGN KEY (instansi_level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE password_reset_tokens (
  email VARCHAR(255) NOT NULL PRIMARY KEY,
  token VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE failed_jobs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uuid VARCHAR(255) NOT NULL UNIQUE,
  connection TEXT NOT NULL,
  queue TEXT NOT NULL,
  payload LONGTEXT NOT NULL,
  exception LONGTEXT NOT NULL,
  failed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE personal_access_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tokenable_type VARCHAR(255) NOT NULL,
  tokenable_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(255) NOT NULL,
  token VARCHAR(64) NOT NULL UNIQUE,
  abilities TEXT NULL,
  last_used_at TIMESTAMP NULL,
  expires_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX tokenable_type_tokenable_id (tokenable_type, tokenable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_invite_codes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code CHAR(6) NOT NULL UNIQUE,
  instansi_id BIGINT UNSIGNED NULL,
  instansi_level_id BIGINT UNSIGNED NULL,
  description VARCHAR(255) NULL,
  expires_at TIMESTAMP NULL,
  is_used TINYINT(1) NOT NULL DEFAULT 0,
  used_by BIGINT UNSIGNED NULL,
  used_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instansi_id) REFERENCES instansi(id) ON DELETE SET NULL,
  FOREIGN KEY (instansi_level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL,
  FOREIGN KEY (used_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE migrations (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  migration VARCHAR(255) NOT NULL,
  batch INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Evaluasi Mandiri Configuration & Data
-- -------------------------------------------------------------
CREATE TABLE evaluation_categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(50) NOT NULL UNIQUE,
  label VARCHAR(60) NOT NULL,
  description VARCHAR(255) NULL,
  min_score INT NOT NULL,
  max_score INT NOT NULL,
  color_class VARCHAR(60) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evaluasi_clusters (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  instansi_level_id BIGINT UNSIGNED NULL,
  title VARCHAR(255) NOT NULL,
  sequence INT NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  applies_to_all TINYINT(1) NOT NULL DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  updated_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instansi_level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY uq_cluster_level_sequence (instansi_level_id, sequence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evaluasi_questions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cluster_id BIGINT UNSIGNED NOT NULL,
  question_text TEXT NOT NULL,
  sequence INT NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  updated_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (cluster_id) REFERENCES evaluasi_clusters(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY uq_question_order (cluster_id, sequence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evaluation_submissions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  submission_code VARCHAR(30) NOT NULL UNIQUE,
  instansi_id BIGINT UNSIGNED NULL,
  instansi_name VARCHAR(255) NOT NULL,
  instansi_level_id BIGINT UNSIGNED NULL,
  instansi_level_text VARCHAR(150) NULL,
  instansi_address VARCHAR(255) NULL,
  pejabat_nama VARCHAR(255) NULL,
  pejabat_jabatan VARCHAR(150) NULL,
  employee_male_count INT NULL,
  employee_female_count INT NULL,
  evaluation_date DATE NULL,
  submission_date DATETIME NOT NULL,
  score INT NOT NULL DEFAULT 0,
  category_id BIGINT UNSIGNED NULL,
  category_label VARCHAR(60) NULL,
  status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  remarks TEXT NULL,
  submitted_by BIGINT UNSIGNED NULL,
  verified_by BIGINT UNSIGNED NULL,
  verified_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instansi_id) REFERENCES instansi(id) ON DELETE SET NULL,
  FOREIGN KEY (instansi_level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES evaluation_categories(id) ON DELETE SET NULL,
  FOREIGN KEY (submitted_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_eval_status (status),
  INDEX idx_eval_level (instansi_level_id),
  INDEX idx_eval_submitted_at (submission_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evaluation_answers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  submission_id BIGINT UNSIGNED NOT NULL,
  question_id BIGINT UNSIGNED NULL,
  question_text TEXT NOT NULL,
  answer_value TINYINT NULL,
  remark TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (submission_id) REFERENCES evaluation_submissions(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES evaluasi_questions(id) ON DELETE SET NULL,
  INDEX idx_submission_question (submission_id, question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Laporan Semesteran / Tahunan Configuration & Data
-- -------------------------------------------------------------
CREATE TABLE laporan_templates (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  instansi_id BIGINT UNSIGNED NULL,
  instansi_level_id BIGINT UNSIGNED NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  year SMALLINT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  updated_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (instansi_id) REFERENCES instansi(id) ON DELETE SET NULL,
  FOREIGN KEY (instansi_level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE laporan_sections (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  template_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(50) NULL,
  title VARCHAR(255) NOT NULL,
  indicator TEXT NULL,
  has_target TINYINT(1) NOT NULL DEFAULT 1,
  has_budget TINYINT(1) NOT NULL DEFAULT 1,
  sequence INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (template_id) REFERENCES laporan_templates(id) ON DELETE CASCADE,
  UNIQUE KEY uq_section_sequence (template_id, sequence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE laporan_submissions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  submission_code VARCHAR(30) NOT NULL UNIQUE,
  template_id BIGINT UNSIGNED NULL,
  instansi_id BIGINT UNSIGNED NULL,
  instansi_name VARCHAR(255) NOT NULL,
  instansi_level_id BIGINT UNSIGNED NULL,
  instansi_level_text VARCHAR(150) NULL,
  report_year SMALLINT NOT NULL,
  report_level VARCHAR(100) NULL,
  status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  notes TEXT NULL,
  submitted_by BIGINT UNSIGNED NULL,
  verified_by BIGINT UNSIGNED NULL,
  submitted_at DATETIME NOT NULL,
  verified_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (template_id) REFERENCES laporan_templates(id) ON DELETE SET NULL,
  FOREIGN KEY (instansi_id) REFERENCES instansi(id) ON DELETE SET NULL,
  FOREIGN KEY (instansi_level_id) REFERENCES instansi_levels(id) ON DELETE SET NULL,
  FOREIGN KEY (submitted_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_report_status (status),
  INDEX idx_report_year (report_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE laporan_submission_sections (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  laporan_submission_id BIGINT UNSIGNED NOT NULL,
  section_id BIGINT UNSIGNED NULL,
  section_code VARCHAR(50) NULL,
  section_title VARCHAR(255) NOT NULL,
  target_year VARCHAR(100) NULL,
  target_semester_1 VARCHAR(100) NULL,
  target_semester_2 VARCHAR(100) NULL,
  budget_year VARCHAR(100) NULL,
  budget_semester_1 VARCHAR(100) NULL,
  budget_semester_2 VARCHAR(100) NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laporan_submission_id) REFERENCES laporan_submissions(id) ON DELETE CASCADE,
  FOREIGN KEY (section_id) REFERENCES laporan_sections(id) ON DELETE SET NULL,
  INDEX idx_submission_section (laporan_submission_id, section_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Status & Audit Trails
-- -------------------------------------------------------------
CREATE TABLE submission_status_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  submission_type ENUM('evaluasi','laporan') NOT NULL,
  submission_id BIGINT UNSIGNED NOT NULL,
  previous_status ENUM('pending','verified','rejected') NULL,
  new_status ENUM('pending','verified','rejected') NOT NULL,
  remarks TEXT NULL,
  instansi_id BIGINT UNSIGNED NULL,
  changed_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (instansi_id) REFERENCES instansi(id) ON DELETE SET NULL,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_submission_type (submission_type, submission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed section intentionally left empty for fresh database state.
-- Tambahkan INSERT sesuai kebutuhan operasional ketika siap mengisi data awal.

-- =============================================================
-- End of Schema Definition
-- =============================================================
