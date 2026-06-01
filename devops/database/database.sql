/**
 * =========================================================================
 * QUASAR PLATFORM - DATABASE BOOTSTRAP & SEEDING SCRIPT
 * =========================================================================
 * [DANGER] DESTRUCTIVE OPERATION: DO NOT RUN THIS ON STAGING OR PRODUCTION!
 * Context:
 * File này chỉ sử dụng cho môi trường Local Development.
 * Nó sẽ xóa toàn bộ dữ liệu hiện tại để tạo môi trường sạch.
 * Flow:
 * 1. Nuke & Recreate Database.
 * 2. Cấu hình Session (Timezone UTC, tắt Foreign Key checks).
 * 3. Chạy DDL (Khởi tạo Schema).
 * 4. Chạy DML (Seeding dữ liệu mẫu).
 * =========================================================================
 */

DROP DATABASE IF EXISTS quasar_platform;
CREATE DATABASE IF NOT EXISTS quasar_platform;
USE quasar_platform;

-- =========================================================================
-- CONFIGURATION PHASE
-- =========================================================================
-- Chuẩn hóa session timezone về UTC (ISO 8601 standard)
SET time_zone = "+00:00";

-- Tạm vô hiệu hóa constraints
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

-- =========================================================================
-- PHASE 1: SCHEMA DEFINITION (DDL)
-- =========================================================================
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Hoạt động, 0: Khóa',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_roles_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fullname` varchar(100) DEFAULT '',
  `phone_number` varchar(15) DEFAULT NULL,
  `address` varchar(200) DEFAULT '',
  `password` char(60) DEFAULT NULL,
  `failed_login_attempts` int DEFAULT '0',
  `locked_until` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `date_of_birth` date DEFAULT NULL,
  `role_id` int DEFAULT '1',
  `email` varchar(255) DEFAULT '',
  `profile_image` varchar(255) DEFAULT '',
  `email_verified_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL COMMENT 'Phục vụ tracking Marketing và dọn dẹp User rác',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_users_email_deleted` (`email`,`is_deleted`),
  UNIQUE KEY `ux_users_phone_deleted` (`phone_number`,`is_deleted`),
  KEY `users_role_fk` (`role_id`),
  CONSTRAINT `users_role_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_credentials` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `credential_id` text NOT NULL,
  `public_key` text NOT NULL,
  `sign_count` int DEFAULT '0',
  `device_label` varchar(255) DEFAULT NULL COMMENT 'VD: Macbook Pro của Tùng',
  `authenticator_type` enum('PLATFORM','CROSS_PLATFORM') DEFAULT 'PLATFORM',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Hoạt động, 0: Khóa',
  `last_used_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_cred_user` (`user_id`),
  CONSTRAINT `fk_cred_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_devices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `fcm_token` varchar(500) NOT NULL COMMENT 'Firebase Token',
  `device_type` enum('ANDROID','IOS','WEB') NOT NULL,
  `device_name` varchar(255) DEFAULT NULL,
  `last_active_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `device_uid` varchar(100) NOT NULL COMMENT 'Mã định danh duy nhất của thiết bị vật lý sinh từ Frontend/Mobile',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '0: Token đã chết, ngưng gửi push',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_user_device_uid` (`user_id`,`device_uid`),
  KEY `idx_device_user` (`user_id`),
  CONSTRAINT `fk_device_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_sessions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `refresh_token_hash` varchar(255) NOT NULL,
  `device_id` varchar(255) DEFAULT NULL COMMENT 'Nhận diện thiết bị',
  `ip_address` varchar(50) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `is_revoked` tinyint(1) DEFAULT '0' COMMENT 'Dùng để force logout',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_agent` varchar(500) DEFAULT NULL COMMENT 'Chrome, Safari, App...',
  `replaced_by_token_hash` varchar(255) DEFAULT NULL COMMENT 'Tracking Refresh Token Rotation',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_refresh_token` (`refresh_token_hash`),
  KEY `idx_session_user` (`user_id`),
  KEY `idx_sessions_expires` (`expires_at`),
  CONSTRAINT `fk_session_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `social_accounts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider` varchar(20) NOT NULL,
  `provider_id` varchar(50) NOT NULL,
  `email` varchar(150) NOT NULL,
  `name` varchar(100) NOT NULL,
  `user_id` int DEFAULT NULL,
  `avatar_url` varchar(300) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_social_provider_id` (`provider`,`provider_id`),
  UNIQUE KEY `ux_social_user_provider` (`user_id`,`provider`),
  KEY `social_accounts_fk` (`user_id`),
  CONSTRAINT `social_accounts_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `provinces` (
  `code` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `full_name_en` varchar(255) DEFAULT NULL,
  `region` enum('NORTH','CENTRAL','SOUTH','UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Vùng miền để tính phí và thời gian ship',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Hoạt động, 0: Vô hiệu hóa (do sáp nhập)',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `districts` (
  `code` varchar(20) NOT NULL,
  `province_code` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `full_name_en` varchar(255) DEFAULT NULL,
  `type` enum('URBAN','RURAL','ISLAND','UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Loại hình (Nội thành, Ngoại thành, Đảo)',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Hoạt động, 0: Vô hiệu hóa (do sáp nhập)',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`code`),
  KEY `province_code` (`province_code`),
  KEY `idx_districts_province_type` (`province_code`,`type`),
  CONSTRAINT `districts_ibfk_1` FOREIGN KEY (`province_code`) REFERENCES `provinces` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `wards` (
  `code` varchar(20) NOT NULL,
  `district_code` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `full_name_en` varchar(255) DEFAULT NULL,
  `delivery_status` enum('AVAILABLE','SUSPENDED','OUT_OF_ZONE') DEFAULT 'AVAILABLE' COMMENT 'Trạng thái giao hàng (bão lũ, dịch bệnh)',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Hoạt động, 0: Vô hiệu hóa (do sáp nhập)',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`code`),
  KEY `district_code` (`district_code`),
  KEY `idx_wards_district_status` (`district_code`,`delivery_status`),
  CONSTRAINT `wards_ibfk_1` FOREIGN KEY (`district_code`) REFERENCES `districts` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `recipient_name` varchar(100) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `address_detail` varchar(200) NOT NULL,
  `province_code` varchar(20) DEFAULT NULL,
  `district_code` varchar(20) DEFAULT NULL,
  `ward_code` varchar(20) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `address_type` enum('HOME','OFFICE') DEFAULT 'HOME',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '1: Khách đã xóa khỏi sổ địa chỉ',
  PRIMARY KEY (`id`),
  KEY `fk_addr_user` (`user_id`),
  KEY `fk_addr_province` (`province_code`),
  KEY `fk_addr_district` (`district_code`),
  KEY `fk_addr_ward` (`ward_code`),
  CONSTRAINT `fk_addr_district` FOREIGN KEY (`district_code`) REFERENCES `districts` (`code`),
  CONSTRAINT `fk_addr_province` FOREIGN KEY (`province_code`) REFERENCES `provinces` (`code`),
  CONSTRAINT `fk_addr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_addr_ward` FOREIGN KEY (`ward_code`) REFERENCES `wards` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- =========================================================================
-- PHASE 2: DATA SEEDING (DML)
-- =========================================================================
START TRANSACTION;
-- [TODO] Chèn các câu lệnh DML để seed dữ liệu mẫu ở đây.
COMMIT;

-- =========================================================================
-- CLEANUP PHASE
-- =========================================================================
-- Khôi phục lại các constraints
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
