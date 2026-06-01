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

CREATE TABLE `shops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL COMMENT 'Chủ shop (User ID)',
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `banner_url` varchar(255) DEFAULT NULL,
  `description` text,
  `commission_rate` decimal(5,2) DEFAULT '5.00' COMMENT 'Phí sàn thu %',
  `status` enum('ACTIVE','BANNED','PENDING') DEFAULT 'ACTIVE',
  `rating_avg` float DEFAULT '5',
  `total_orders` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `version` int DEFAULT '0' COMMENT 'Optimistic Locking chống Race Condition khi update rating/orders',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_shops_slug_deleted` (`slug`,`is_deleted`),
  KEY `fk_shops_users` (`owner_id`),
  CONSTRAINT `fk_shops_users` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `shop_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `user_id` int NOT NULL,
  `role` enum('MANAGER','SALES','WAREHOUSE') DEFAULT 'SALES',
  `status` enum('ACTIVE','RESIGNED') DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_shop_emp_deleted` (`shop_id`,`user_id`,`is_deleted`),
  KEY `fk_shop_emp_user` (`user_id`),
  CONSTRAINT `fk_shop_emp_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`),
  CONSTRAINT `fk_shop_emp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `level` int DEFAULT '1',
  `slug` varchar(100) DEFAULT NULL,
  `icon_url` varchar(255) DEFAULT NULL,
  `display_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `display_mode` varchar(50) DEFAULT NULL COMMENT 'Chế độ hiển thị (VD: GRID, LIST)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_category_parent_name` (`parent_id`,`name`),
  UNIQUE KEY `ux_category_slug_deleted` (`slug`,`is_deleted`),
  KEY `fk_categories_parent` (`parent_id`),
  KEY `idx_categories_path` (`path`),
  CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `brands` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `icon_url` varchar(255) DEFAULT NULL,
  `slug` varchar(100) DEFAULT NULL,
  `description` text,
  `tier` enum('PREMIUM','REGULAR','LOCAL') DEFAULT 'REGULAR' COMMENT 'Phân hạng thương hiệu',
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_brands_slug_deleted` (`slug`,`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT 'Color, Ram, Size',
  `code` varchar(50) NOT NULL COMMENT 'Mã hệ thống không dấu (VD: COLOR, RAM)',
  `type` enum('TEXT','COLOR_HEX','IMAGE') DEFAULT 'TEXT' COMMENT 'Cách FE render UI',
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_options_code_deleted` (`code`,`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `option_values` (
  `id` int NOT NULL AUTO_INCREMENT,
  `option_id` int NOT NULL,
  `value` varchar(50) NOT NULL COMMENT 'Red, Blue, 64GB',
  `meta_data` varchar(255) DEFAULT NULL COMMENT 'Mã màu #HEX hoặc URL ảnh nếu cần',
  `display_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` bigint DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_opt_val_deleted` (`option_id`,`value`,`is_deleted`),
  KEY `option_id` (`option_id`),
  CONSTRAINT `fk_option_values_option` FOREIGN KEY (`option_id`) REFERENCES `options` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT '1',
  `name` varchar(350) DEFAULT NULL,
  `slug` varchar(350) DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `description` longtext,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `category_id` int DEFAULT NULL,
  `brand_id` int DEFAULT NULL,
  `product_type` enum('OWN','CONSIGNED') DEFAULT 'OWN' COMMENT 'Nguồn gốc sản phẩm',
  `warranty_period` int DEFAULT '12',
  `quantity` int DEFAULT '0' COMMENT 'Tổng tồn kho tất cả biến thể',
  `reserved_quantity` int DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `specs` json DEFAULT NULL COMMENT 'Thông số kỹ thuật chung: {"screen": "6.1 inch", "chip": "A17 Pro"}',
  `is_imei_tracked` tinyint(1) DEFAULT '1' COMMENT '1: Quản lý IMEI, 0: Số lượng thường',
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text,
  `is_featured` tinyint(1) DEFAULT '0',
  `min_price` decimal(15,2) DEFAULT NULL,
  `max_price` decimal(15,2) DEFAULT NULL,
  `rating_avg` float DEFAULT '0',
  `review_count` int DEFAULT '0',
  `is_deleted` bigint DEFAULT '0',
  `v_ram` varchar(50) GENERATED ALWAYS AS (json_unquote(json_extract(`specs`,_utf8mb4'$.ram'))) VIRTUAL,
  `v_storage` varchar(50) GENERATED ALWAYS AS (json_unquote(json_extract(`specs`,_utf8mb4'$.storage'))) VIRTUAL,
  `version` int DEFAULT '0' COMMENT 'Optimistic Locking cho tổng tồn kho',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Hoạt động, 0: Vô hiệu hóa',
  `total_sold` int DEFAULT '0' COMMENT 'Phục vụ sort Best Seller',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_products_slug_deleted` (`slug`,`is_deleted`),
  KEY `products_categories_fk` (`category_id`),
  KEY `products_brands_fk` (`brand_id`),
  KEY `idx_category_price` (`category_id`,`price`),
  KEY `fk_products_shop` (`shop_id`),
  KEY `idx_filter_products` (`category_id`,`brand_id`,`is_active`),
  KEY `idx_prod_cat_brand_price` (`category_id`,`brand_id`,`price`),
  KEY `idx_products_ram` (`v_ram`),
  KEY `idx_products_storage` (`v_storage`),
  FULLTEXT KEY `ft_product_name` (`name`),
  CONSTRAINT `fk_products_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`),
  CONSTRAINT `products_brands_fk` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`),
  CONSTRAINT `products_categories_fk` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `chk_products_qty_positive` CHECK ((`quantity` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `image_url` varchar(300) DEFAULT NULL,
  `display_order` int DEFAULT '0' COMMENT 'Thứ tự hiển thị trong slider',
  `image_type` enum('GALLERY','SIZE_GUIDE','CERTIFICATE') DEFAULT 'GALLERY' COMMENT 'Phân loại ảnh',
  `is_deleted` bigint DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_product_images_product_id` (`product_id`),
  CONSTRAINT `fk_product_images_product_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_variants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `original_price` decimal(15,2) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `quantity` int DEFAULT '0' COMMENT '[FIX] Tồn kho riêng cho từng biến thể',
  `reserved_quantity` int DEFAULT '0',
  `weight` decimal(10,2) DEFAULT '0.00' COMMENT 'Gram',
  `dimensions` varchar(50) DEFAULT NULL COMMENT 'L x W x H',
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `version` int DEFAULT '0' COMMENT 'Dùng cho Optimistic Locking JPA',
  `attributes` json DEFAULT NULL COMMENT 'Phi chuẩn hóa để đọc siêu tốc. VD: {"Màu": "Đỏ", "Dung lượng": "256GB"}',
  `name` varchar(255) GENERATED ALWAYS AS (json_unquote(json_extract(`attributes`,_utf8mb4'$.name'))) VIRTUAL COMMENT 'Tên biến thể sinh tự động',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '1: Đang kinh doanh, 0: Ngừng kinh doanh',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_variants_sku_deleted` (`sku`,`is_deleted`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_variants_stock` CHECK (((`quantity` >= 0) and (`reserved_quantity` >= 0) and (`quantity` >= `reserved_quantity`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `variant_values` (
  `variant_id` int NOT NULL,
  `product_id` int NOT NULL,
  `option_id` int NOT NULL,
  `option_value_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`variant_id`,`option_id`),
  KEY `option_value_id` (`option_value_id`),
  KEY `option_id` (`option_id`),
  CONSTRAINT `variant_values_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `variant_values_ibfk_2` FOREIGN KEY (`option_value_id`) REFERENCES `option_values` (`id`),
  CONSTRAINT `variant_values_ibfk_3` FOREIGN KEY (`option_id`) REFERENCES `options` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `price_histories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL,
  `old_price` decimal(15,2) DEFAULT NULL,
  `new_price` decimal(15,2) DEFAULT NULL,
  `updated_by` int DEFAULT NULL COMMENT 'Admin nào sửa',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `reason` varchar(255) DEFAULT 'MANUAL_UPDATE' COMMENT 'Lý do đổi giá: MANUAL, FLASH_SALE, BATCH_SYNC',
  `price_type` enum('SELLING_PRICE','ORIGINAL_PRICE') DEFAULT 'SELLING_PRICE' COMMENT 'Loại giá bị thay đổi',
  PRIMARY KEY (`id`),
  KEY `idx_ph_product_date` (`product_id`,`created_at`),
  KEY `idx_ph_variant_date` (`variant_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `suppliers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL DEFAULT '1',
  `name` varchar(100) NOT NULL,
  `contact_email` varchar(100) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
  `deleted_at` datetime DEFAULT NULL,
  `tax_code` varchar(50) DEFAULT NULL COMMENT 'Mã số thuế để xuất hóa đơn VAT',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ kinh doanh',
  `total_debt` decimal(15,2) DEFAULT '0.00' COMMENT 'Công nợ hiện tại với NCC',
  `is_deleted` bigint DEFAULT '0' COMMENT 'Epoch time khi xóa mềm',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_supplier_tax_shop` (`shop_id`,`tax_code`,`is_deleted`) COMMENT 'Một shop không được tạo 2 NCC trùng mã số thuế',
  KEY `idx_sup_shop` (`shop_id`),
  CONSTRAINT `fk_supplier_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `inventory_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `transaction_code` varchar(50) NOT NULL COMMENT 'Mã phiếu kho public (VD: PN-001, PX-002, PK-001)',
  `type` enum('INBOUND','OUTBOUND','ADJUSTMENT','RETURN') NOT NULL COMMENT 'INBOUND: Nhập mới, OUTBOUND: Xuất bán, ADJUSTMENT: Điều chỉnh/Kiểm kê, RETURN: Khách trả hàng',
  `reference_type` varchar(50) DEFAULT NULL COMMENT 'Nguồn gốc: ORDER, PURCHASE_ORDER, MANUAL...',
  `reference_id` bigint DEFAULT NULL COMMENT 'ID của Order hoặc ID Phiếu nhập từ Supplier',
  `note` text COMMENT 'Lý do nhập/xuất/điều chỉnh',
  `created_by` int NOT NULL COMMENT 'Nhân viên/Admin tạo phiếu (User ID)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('PENDING','COMPLETED','CANCELLED') DEFAULT 'COMPLETED' COMMENT 'Trạng thái xử lý phiếu',
  `total_value` decimal(15,2) DEFAULT '0.00' COMMENT 'Tổng giá trị của giao dịch (để kế toán nhìn nhanh)',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_inv_trans_code` (`transaction_code`),
  KEY `fk_inv_trans_shop` (`shop_id`),
  KEY `fk_inv_trans_user` (`created_by`),
  KEY `idx_inv_trans_type` (`type`,`created_at`),
  CONSTRAINT `fk_inv_trans_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`),
  CONSTRAINT `fk_inv_trans_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL COMMENT '[LINK] Liên kết với biến thể',
  `supplier_id` int DEFAULT NULL,
  `order_id` bigint DEFAULT NULL,
  `imei_code` varchar(50) NOT NULL,
  `inbound_price` decimal(15,2) DEFAULT NULL,
  `status` enum('AVAILABLE','PENDING','SOLD','DEFECTIVE','WARRANTY','HOLD') DEFAULT 'AVAILABLE',
  `attributes` json DEFAULT NULL COMMENT 'Optional: Thông số phụ',
  `import_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `sold_date` datetime DEFAULT NULL,
  `locked_until` datetime DEFAULT NULL COMMENT 'Thời gian hết hạn giữ hàng (Reservation)',
  `is_deleted` bigint DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `version` int DEFAULT '0' COMMENT 'Optimistic Locking chống bán trùng IMEI',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_items_imei_deleted` (`imei_code`,`is_deleted`),
  KEY `idx_item_status` (`status`),
  KEY `items_products_fk` (`product_id`),
  KEY `items_variants_fk` (`variant_id`),
  KEY `items_suppliers_fk` (`supplier_id`),
  KEY `items_orders_fk` (`order_id`),
  KEY `idx_imei_search` (`imei_code`),
  KEY `idx_items_locked_until` (`locked_until`),
  KEY `idx_pid_status` (`product_id`,`status`),
  CONSTRAINT `items_orders_fk` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `items_products_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `items_suppliers_fk` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `items_variants_fk` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `inventory_transaction_details` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL COMMENT 'Sản phẩm có biến thể thì fill vào đây',
  `product_item_id` int DEFAULT NULL COMMENT 'Nếu là SP quản lý theo IMEI (bán 1 chiếc cụ thể) thì map vào đây',
  `quantity_changed` int NOT NULL COMMENT 'Số lượng thay đổi (+ là nhập, - là xuất)',
  `stock_before` int NOT NULL COMMENT 'Tồn kho TRƯỚC khi giao dịch (Snapshot để đối soát)',
  `stock_after` int NOT NULL COMMENT 'Tồn kho SAU khi giao dịch (Snapshot để đối soát)',
  `unit_cost` decimal(15,2) DEFAULT '0.00' COMMENT 'Giá vốn của 1 đơn vị tại thời điểm tạo phiếu',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_inv_detail_trans` (`transaction_id`),
  KEY `fk_inv_detail_product` (`product_id`),
  KEY `fk_inv_detail_variant` (`variant_id`),
  KEY `fk_inv_detail_item` (`product_item_id`),
  CONSTRAINT `fk_inv_detail_item` FOREIGN KEY (`product_item_id`) REFERENCES `product_items` (`id`),
  CONSTRAINT `fk_inv_detail_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_inv_detail_trans` FOREIGN KEY (`transaction_id`) REFERENCES `inventory_transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inv_detail_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `carts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `session_id` varchar(100) DEFAULT NULL COMMENT 'Lưu Session ID cho khách chưa login',
  `expires_at` datetime DEFAULT NULL,
  `status` enum('ACTIVE','LOCKED') DEFAULT 'ACTIVE' COMMENT 'ACTIVE: Đang mua sắm, LOCKED: Đang chờ thanh toán',
  `is_deleted` bigint DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_carts_user_id_deleted` (`user_id`,`is_deleted`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_carts_expires` (`expires_at`),
  CONSTRAINT `fk_carts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cart_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL COMMENT '[NEW] Chọn biến thể trong giỏ',
  `quantity` int DEFAULT '1',
  `price_at_add` decimal(15,2) NOT NULL COMMENT 'Giá tại thời điểm bỏ vào giỏ, dùng để so sánh với giá hiện tại và cảnh báo user',
  `is_selected` tinyint(1) DEFAULT '1' COMMENT 'Khách hàng có tick chọn để thanh toán không',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `affiliate_link_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_cart_product_variant` (`cart_id`,`product_id`,`variant_id`),
  KEY `fk_cart_items_cart` (`cart_id`),
  KEY `fk_cart_items_product` (`product_id`),
  KEY `fk_cart_items_variant` (`variant_id`),
  CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_cart_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_cart_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE RESTRICT
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
