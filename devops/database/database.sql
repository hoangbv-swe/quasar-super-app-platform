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

CREATE TABLE `pos_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `user_id` int NOT NULL,
  `start_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `end_at` datetime DEFAULT NULL,
  `opening_cash` decimal(15,2) DEFAULT '0.00',
  `closing_cash` decimal(15,2) DEFAULT '0.00',
  `status` enum('OPEN','CLOSED') DEFAULT 'OPEN',
  `note` text,
  `expected_cash` decimal(15,2) DEFAULT '0.00' COMMENT 'Tiền mặt dự kiến (Opening + Thu - Chi trong ca)',
  `difference_cash` decimal(15,2) DEFAULT '0.00' COMMENT 'Độ lệch = closing_cash - expected_cash',
  `version` int DEFAULT '0' COMMENT 'Optimistic Locking chống sửa ca đồng thời',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_pos_shop` (`shop_id`),
  KEY `fk_pos_user` (`user_id`),
  CONSTRAINT `fk_pos_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`),
  CONSTRAINT `fk_pos_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_code` varchar(50) DEFAULT NULL COMMENT 'Mã đơn public chống IDOR (VD: ORD-XYZ)',
  `user_id` int DEFAULT NULL,
  `pos_session_id` int DEFAULT NULL,
  `fullname` varchar(100) DEFAULT '',
  `email` varchar(100) DEFAULT '',
  `phone_number` varchar(20) NOT NULL,
  `address` varchar(200) NOT NULL,
  `province_code` varchar(20) DEFAULT NULL,
  `district_code` varchar(20) DEFAULT NULL,
  `ward_code` varchar(20) DEFAULT NULL,
  `note` varchar(100) DEFAULT '',
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` varchar(50) DEFAULT 'PENDING',
  `sub_total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `shipping_fee` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total_money` decimal(15,2) NOT NULL DEFAULT '0.00',
  `shipping_address` varchar(200) DEFAULT NULL,
  `payment_method` varchar(100) DEFAULT NULL,
  `payment_status` varchar(50) DEFAULT 'UNPAID',
  `order_channel` enum('ONLINE','POS','APP') DEFAULT 'ONLINE',
  `active` tinyint(1) DEFAULT '1',
  `coupon_id` int DEFAULT NULL,
  `total_cost_price` decimal(15,2) DEFAULT '0.00' COMMENT 'Tổng giá vốn của đơn hàng',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `version` int DEFAULT '0' COMMENT 'Optimistic Locking chống lỗi Webhook thanh toán',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL COMMENT 'Thời điểm giao hàng thành công',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_orders_code_deleted` (`order_code`,`is_deleted`),
  KEY `idx_order_date` (`order_date`),
  KEY `fk_orders_user` (`user_id`),
  KEY `fk_orders_coupon` (`coupon_id`),
  KEY `idx_order_status` (`status`),
  KEY `fk_order_pos` (`pos_session_id`),
  KEY `idx_orders_created_status` (`order_date`,`status`),
  KEY `idx_admin_orders` (`status`,`order_date`),
  KEY `idx_orders_user_id` (`user_id`),
  CONSTRAINT `fk_order_pos` FOREIGN KEY (`pos_session_id`) REFERENCES `pos_sessions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `orders_shop` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_order_id` bigint NOT NULL,
  `shop_id` int NOT NULL,
  `shipping_method` varchar(100) DEFAULT NULL,
  `shipping_fee` decimal(15,2) DEFAULT '0.00',
  `sub_total` decimal(15,2) DEFAULT '0.00' COMMENT 'Tổng tiền hàng',
  `admin_commission` decimal(15,2) DEFAULT '0.00' COMMENT 'Phí sàn thu',
  `shop_income` decimal(15,2) DEFAULT '0.00' COMMENT 'Thực nhận = Sub - Comm',
  `status` enum('PENDING','PROCESSING','SHIPPED','DELIVERED','DELIVERY_FAILED','CANCELLED','RETURNED') DEFAULT 'PENDING',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `tracking_number` varchar(100) DEFAULT NULL COMMENT 'Mã vận đơn riêng của kiện hàng này',
  `shipping_date` datetime DEFAULT NULL,
  `carrier_name` varchar(100) DEFAULT NULL COMMENT 'Đơn vị vận chuyển (GHTK, GHN...)',
  `total_tax_amount` decimal(15,2) DEFAULT '0.00' COMMENT 'Tổng thuế của kiện hàng',
  `order_shop_code` varchar(50) NOT NULL COMMENT 'Mã kiện hàng hiển thị cho Shop (VD: PKG-12345)',
  `shop_note` text COMMENT 'Shop tự ghi chú nội bộ (VD: Khách khó tính, gói kỹ)',
  `is_deleted` bigint DEFAULT '0',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_order_shop_code_del` (`order_shop_code`,`is_deleted`),
  KEY `fk_sub_order_parent` (`parent_order_id`),
  KEY `fk_sub_order_shop` (`shop_id`),
  CONSTRAINT `fk_sub_order_parent` FOREIGN KEY (`parent_order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_sub_order_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` bigint DEFAULT NULL,
  `order_shop_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_item_id` int DEFAULT NULL COMMENT 'Nếu bán theo IMEI thì fill vào đây',
  `supplier_id` int DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `number_of_products` int DEFAULT '1',
  `total_money` decimal(15,2) DEFAULT '0.00',
  `discount_amount` decimal(15,2) DEFAULT '0.00' COMMENT 'Phân bổ khuyến mãi để tính tiền hoàn',
  `configuration` json DEFAULT NULL,
  `coupon_id` int DEFAULT NULL,
  `cost_price` decimal(15,2) DEFAULT NULL COMMENT 'Giá vốn tại thời điểm bán',
  `is_settled` tinyint(1) DEFAULT '0' COMMENT 'Đã thanh toán tiền gốc cho Supplier chưa',
  `settlement_date` datetime DEFAULT NULL,
  `warranty_expire_date` date DEFAULT NULL COMMENT 'Ngày hết hạn bảo hành cho item này',
  `settlement_ref` varchar(100) DEFAULT NULL COMMENT 'Mã giao dịch/UNC khi chuyển khoản trả tiền cho Supplier',
  `settlement_note` varchar(255) DEFAULT NULL COMMENT 'Ghi chú đối soát',
  `product_name` varchar(350) DEFAULT NULL COMMENT 'Lưu cứng tên SP tại thời điểm bán',
  `variant_name` varchar(255) DEFAULT NULL COMMENT 'Lưu cứng tên biến thể (Ví dụ: Đen, 64GB)',
  `tax_rate` decimal(5,2) DEFAULT '0.00' COMMENT 'Thuế suất tại thời điểm mua (%)',
  `tax_amount` decimal(15,2) DEFAULT '0.00' COMMENT 'Số tiền thuế phải nộp',
  `product_thumbnail_snapshot` varchar(300) DEFAULT NULL COMMENT 'Lưu cứng link ảnh tại thời điểm mua',
  `item_status` enum('NORMAL','RETURN_REQUESTED','RETURNED') DEFAULT 'NORMAL' COMMENT 'Trạng thái riêng của từng món trong đơn',
  `variant_id` int DEFAULT NULL COMMENT 'ID biến thể để tiện thống kê',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `affiliate_link_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_details_order_fk` (`order_id`),
  KEY `order_details_product_fk` (`product_id`),
  KEY `order_details_item_fk` (`product_item_id`),
  KEY `fk_order_details_supplier` (`supplier_id`),
  KEY `idx_supplier_settlement` (`supplier_id`,`is_settled`),
  KEY `fk_details_order_shop` (`order_shop_id`),
  KEY `fk_details_variant` (`variant_id`),
  CONSTRAINT `fk_details_order_shop` FOREIGN KEY (`order_shop_id`) REFERENCES `orders_shop` (`id`),
  CONSTRAINT `fk_details_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_order_details_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `order_details_item_fk` FOREIGN KEY (`product_item_id`) REFERENCES `product_items` (`id`),
  CONSTRAINT `order_details_order_fk` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `order_details_product_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `chk_imei_qty` CHECK (((`product_item_id` is null) or (`number_of_products` = 1)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `order_histories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `status` varchar(50) NOT NULL,
  `note` text,
  `updated_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `order_shop_id` int DEFAULT NULL COMMENT 'NULL nếu là log của Đơn tổng, có ID nếu là log của Kiện hàng con (Shop)',
  PRIMARY KEY (`id`),
  KEY `fk_histories_order` (`order_id`),
  KEY `fk_histories_order_shop` (`order_shop_id`),
  CONSTRAINT `fk_histories_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_histories_order_shop` FOREIGN KEY (`order_shop_id`) REFERENCES `orders_shop` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `order_shop_id` int DEFAULT NULL,
  `payment_method` varchar(50) NOT NULL,
  `transaction_code` varchar(100) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `type` enum('PAYMENT','REFUND') DEFAULT 'PAYMENT',
  `status` enum('PENDING','SUCCESS','FAILED','REFUNDED') DEFAULT 'PENDING',
  `response_json` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `parent_transaction_id` int DEFAULT NULL COMMENT 'Dành cho trường hợp refund 1 phần của giao dịch gốc',
  `gateway_code` varchar(50) DEFAULT NULL COMMENT 'Mã phản hồi từ cổng thanh toán (VD: 00 của VNPAY)',
  `error_message` varchar(255) DEFAULT NULL COMMENT 'Thông báo lỗi hiển thị nhanh',
  `version` int DEFAULT '0' COMMENT 'Optimistic Locking chống double-webhook',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_trans_code_method` (`transaction_code`,`payment_method`),
  KEY `fk_transactions_order` (`order_id`),
  KEY `fk_trans_order_shop` (`order_shop_id`),
  CONSTRAINT `fk_trans_order_shop` FOREIGN KEY (`order_shop_id`) REFERENCES `orders_shop` (`id`),
  CONSTRAINT `fk_transactions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `wallets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `balance` decimal(15,2) DEFAULT '0.00',
  `frozen_balance` decimal(15,2) DEFAULT '0.00' COMMENT 'Tiền chờ đối soát',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `version` int DEFAULT '0' COMMENT 'Dùng cho Optimistic Locking JPA',
  `status` enum('ACTIVE','LOCKED') DEFAULT 'ACTIVE' COMMENT 'LOCKED khi phát hiện gian lận (Fraud)',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_wallets_user` (`user_id`),
  CONSTRAINT `fk_wallets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_wallet_balance_positive` CHECK ((`balance` >= 0)),
  CONSTRAINT `chk_wallet_frozen_positive` CHECK ((`frozen_balance` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `wallet_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `wallet_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `type` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `ref_order_id` int DEFAULT NULL,
  `reference_code` varchar(100) DEFAULT NULL COMMENT 'Khóa lũy đẳng chống nạp/trừ lặp',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `balance_before` decimal(15,2) NOT NULL DEFAULT '0.00' COMMENT 'Số dư trước giao dịch',
  `balance_after` decimal(15,2) NOT NULL DEFAULT '0.00' COMMENT 'Số dư sau giao dịch',
  `created_by` int DEFAULT NULL COMMENT 'User/Admin ID, NULL nếu là Hệ thống tự động',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_wallet_trans_ref` (`reference_code`),
  KEY `fk_trans_wallet` (`wallet_id`),
  CONSTRAINT `fk_trans_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `withdrawal_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `account_holder` varchar(100) DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `approved_by` int DEFAULT NULL COMMENT 'Admin/Kế toán duyệt lệnh',
  `bank_transfer_ref` varchar(100) DEFAULT NULL COMMENT 'Mã giao dịch ngân hàng thực tế (UNC)',
  `resolved_at` datetime DEFAULT NULL COMMENT 'Thời gian xử lý xong',
  `admin_note` text COMMENT 'Lý do từ chối hoặc ghi chú của Kế toán',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_withdraw_user` (`user_id`),
  CONSTRAINT `fk_withdraw_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `banners` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `image_url` varchar(300) NOT NULL,
  `target_url` varchar(300) DEFAULT NULL COMMENT 'Link click vào banner',
  `position` varchar(50) DEFAULT 'HOME_MAIN' COMMENT 'Vị trí đặt banner',
  `display_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `start_time` datetime DEFAULT NULL COMMENT 'Cài đặt giờ tự động hiện',
  `end_time` datetime DEFAULT NULL COMMENT 'Cài đặt giờ tự động ẩn',
  `click_count` int DEFAULT '0' COMMENT 'Đo lường CTR (Click-through rate)',
  `platform` enum('WEB','MOBILE','ALL') DEFAULT 'ALL' COMMENT 'Nền tảng hiển thị',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `flash_sales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('PENDING','ACTIVE','ENDED','CANCELLED') DEFAULT 'PENDING',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `shop_id` int DEFAULT NULL COMMENT 'NULL nếu là Flash Sale của sàn, có ID nếu của riêng Shop',
  `cover_image` varchar(300) DEFAULT NULL COMMENT 'Ảnh banner của đợt Flash Sale',
  `is_deleted` bigint DEFAULT '0',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_flash_sales_shop` (`shop_id`),
  CONSTRAINT `fk_flash_sales_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `flash_sale_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `flash_sale_id` int NOT NULL,
  `product_id` int NOT NULL,
  `promotional_price` decimal(15,2) NOT NULL,
  `quantity_limit` int NOT NULL COMMENT 'Số lượng SP bán trong đợt sale',
  `sold_count` int DEFAULT '0',
  `version` int DEFAULT '0' COMMENT 'Chống bán âm kho khi traffic cao',
  `variant_id` int DEFAULT NULL COMMENT 'Áp dụng cho biến thể cụ thể, nếu NULL là áp dụng cho toàn bộ SP',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_fs_item_prod_var` (`flash_sale_id`,`product_id`,`variant_id`,`is_deleted`),
  KEY `fk_fs_items_fs` (`flash_sale_id`),
  KEY `fk_fs_items_product` (`product_id`),
  KEY `fk_fs_items_variant` (`variant_id`),
  CONSTRAINT `fk_fs_items_fs` FOREIGN KEY (`flash_sale_id`) REFERENCES `flash_sales` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_fs_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_fs_items_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `coupons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shop_id` int DEFAULT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `discount_type` varchar(50) NOT NULL DEFAULT 'FIXED_AMOUNT',
  `discount_value` decimal(15,2) NOT NULL,
  `max_discount_amount` decimal(15,2) DEFAULT NULL,
  `min_order_amount` decimal(15,2) DEFAULT '0.00',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `usage_limit` int DEFAULT NULL,
  `used_count` int DEFAULT '0' COMMENT 'Số lượt đã sử dụng thực tế',
  `usage_per_user` int DEFAULT '1',
  `is_active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `version` int DEFAULT '0' COMMENT 'Chống Race Condition',
  `total_budget` decimal(15,2) DEFAULT NULL COMMENT 'Ngân sách tối đa cho mã này',
  `used_budget` decimal(15,2) DEFAULT '0.00' COMMENT 'Tổng tiền đã giảm thực tế',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_coupon_code_deleted` (`code`,`is_deleted`),
  KEY `fk_coupons_shop` (`shop_id`),
  CONSTRAINT `fk_coupons_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_budget_limit` CHECK (((`total_budget` is null) or (`used_budget` <= `total_budget`))),
  CONSTRAINT `chk_coupon_limit` CHECK (((`usage_limit` is null) or (`used_count` <= `usage_limit`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `coupon_applicables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `coupon_id` int NOT NULL,
  `object_type` enum('CATEGORY','PRODUCT','BRAND') NOT NULL,
  `object_id` int NOT NULL,
  `applicable_type` enum('INCLUDE','EXCLUDE') DEFAULT 'INCLUDE' COMMENT 'Cho phép áp dụng hay Ngoại trừ',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_coupon_object_rule` (`coupon_id`,`object_type`,`object_id`,`applicable_type`),
  KEY `coupon_id` (`coupon_id`),
  CONSTRAINT `fk_coupon_applicables_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `coupon_usages` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `coupon_id` int NOT NULL,
  `order_id` bigint NOT NULL,
  `discount_amount` decimal(15,2) NOT NULL,
  `used_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('APPLIED','REVERTED') DEFAULT 'APPLIED' COMMENT 'APPLIED: Áp dụng thành công, REVERTED: Hoàn lại do hủy đơn',
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_coupon` (`user_id`,`coupon_id`),
  KEY `fk_usage_coupon` (`coupon_id`),
  KEY `fk_usage_order` (`order_id`),
  CONSTRAINT `fk_usage_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`),
  CONSTRAINT `fk_usage_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_usage_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `affiliate_links` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `code` varchar(50) NOT NULL,
  `clicks` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Khóa link nếu phát hiện gian lận',
  `commission_rate` decimal(5,2) DEFAULT NULL COMMENT 'Hoa hồng riêng cho link này (%). Null thì lấy mặc định của Shop/SP',
  `orders_count` int DEFAULT '0' COMMENT 'Số đơn hàng thành công qua link',
  `total_earnings` decimal(15,2) DEFAULT '0.00' COMMENT 'Tổng tiền hoa hồng kiếm được',
  `is_deleted` bigint DEFAULT '0',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_affiliate_code_del` (`code`,`is_deleted`),
  KEY `fk_aff_user` (`user_id`),
  KEY `fk_aff_pro` (`product_id`),
  CONSTRAINT `fk_aff_pro` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_aff_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_showcase_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `is_hidden` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `display_order` int DEFAULT '0' COMMENT 'Thứ tự ưu tiên hiển thị trên Tủ đồ (Số nhỏ xếp trên)',
  `affiliate_link_id` int DEFAULT NULL COMMENT 'Link tiếp thị tương ứng với món hàng này',
  `is_deleted` bigint DEFAULT '0',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_showcase_del` (`user_id`,`product_id`,`is_deleted`),
  KEY `fk_showcase_pro` (`product_id`),
  KEY `fk_showcase_affiliate` (`affiliate_link_id`),
  CONSTRAINT `fk_showcase_affiliate` FOREIGN KEY (`affiliate_link_id`) REFERENCES `affiliate_links` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_showcase_pro` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_showcase_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `affiliate_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `affiliate_link_id` int NOT NULL,
  `order_shop_id` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `status` enum('PENDING','APPROVED','PAID','CANCELLED','REVERSED') DEFAULT 'PENDING',
  `payout_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_aff_trans_link_order` (`affiliate_link_id`,`order_shop_id`) COMMENT '1 kiện hàng chỉ sinh ra 1 khoản hoa hồng cho 1 link, chống duplicate',
  KEY `fk_aff_trans_link` (`affiliate_link_id`),
  KEY `fk_aff_trans_order` (`order_shop_id`),
  CONSTRAINT `fk_aff_trans_link` FOREIGN KEY (`affiliate_link_id`) REFERENCES `affiliate_links` (`id`),
  CONSTRAINT `fk_aff_trans_order` FOREIGN KEY (`order_shop_id`) REFERENCES `orders_shop` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `order_detail_id` int NOT NULL COMMENT 'Chứng minh đã mua hàng',
  `user_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL COMMENT 'ID của review gốc nếu đây là câu trả lời',
  `content` text COMMENT 'Nội dung review cần dài hơn 255 ký tự',
  `rating` tinyint DEFAULT '5',
  `images` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','HIDDEN') DEFAULT 'APPROVED' COMMENT 'Mặc định hiện, bị report thì chuyển HIDDEN',
  `helpful_count` int DEFAULT '0' COMMENT 'Số lượt người khác đánh giá review này hữu ích',
  `is_deleted` bigint DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_review_order_detail_del` (`order_detail_id`,`is_deleted`),
  KEY `reviews_product_fk` (`product_id`),
  KEY `reviews_user_fk` (`user_id`),
  KEY `fk_product_reviews_parent` (`parent_id`),
  CONSTRAINT `fk_product_reviews_parent` FOREIGN KEY (`parent_id`) REFERENCES `product_reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_order_detail` FOREIGN KEY (`order_detail_id`) REFERENCES `order_details` (`id`),
  CONSTRAINT `reviews_product_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product_review_replies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `review_id` int NOT NULL COMMENT 'Trả lời cho đánh giá nào',
  `shop_id` int NOT NULL,
  `vendor_user_id` int NOT NULL COMMENT 'Nhân viên nào của shop gõ câu trả lời',
  `content` text NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_reply_review` (`review_id`) COMMENT 'Mỗi review khách viết, shop chỉ được trả lời 1 lần',
  KEY `fk_reply_shop` (`shop_id`),
  KEY `fk_reply_vendor_user` (`vendor_user_id`),
  CONSTRAINT `fk_reply_review` FOREIGN KEY (`review_id`) REFERENCES `product_reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reply_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reply_vendor_user` FOREIGN KEY (`vendor_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `shop_reviews` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` int NOT NULL,
  `user_id` int NOT NULL,
  `order_shop_id` int NOT NULL,
  `rating` tinyint DEFAULT '5',
  `content` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('PENDING','APPROVED','REJECTED','HIDDEN') DEFAULT 'APPROVED',
  `images` json DEFAULT NULL COMMENT 'Mảng URL ảnh/video review',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_shop_review_order` (`user_id`,`order_shop_id`,`is_deleted`),
  KEY `fk_shop_reviews_shop` (`shop_id`),
  KEY `fk_shop_reviews_user` (`user_id`),
  CONSTRAINT `fk_shop_reviews_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `shop_review_replies` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `review_id` bigint NOT NULL COMMENT 'Trả lời cho đánh giá Shop nào',
  `vendor_user_id` int NOT NULL COMMENT 'Tài khoản nhân viên/chủ shop gõ câu trả lời',
  `content` text NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_shop_reply_review` (`review_id`) COMMENT 'Mỗi review khách viết, shop chỉ trả lời 1 lần',
  KEY `fk_shop_reply_vendor_user` (`vendor_user_id`),
  CONSTRAINT `fk_shop_reply_review` FOREIGN KEY (`review_id`) REFERENCES `shop_reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_shop_reply_vendor_user` FOREIGN KEY (`vendor_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `warranty_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `order_detail_id` int NOT NULL COMMENT 'Link chính xác tới cái máy đã mua',
  `product_item_id` int DEFAULT NULL COMMENT 'IMEI của máy lỗi',
  `request_type` enum('WARRANTY','RETURN','EXCHANGE') NOT NULL COMMENT 'Bảo hành, Trả hàng hay Đổi mới',
  `status` enum('PENDING','RECEIVED','PROCESSING','COMPLETED','REJECTED') DEFAULT 'PENDING',
  `reason` text COMMENT 'Lý do lỗi (Màn hình xanh, sạc không vào...)',
  `images` json DEFAULT NULL COMMENT 'Ảnh chụp tình trạng máy',
  `admin_note` text COMMENT 'Ghi chú của kỹ thuật viên',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `quantity` int DEFAULT '1' COMMENT 'Số lượng sản phẩm cần bảo hành/trả',
  `request_code` varchar(50) NOT NULL COMMENT 'Mã phiếu công khai (VD: RMA-XYZ)',
  `shop_id` int NOT NULL COMMENT 'Phiếu này thuộc về Shop nào xử lý',
  `return_tracking_code` varchar(100) DEFAULT NULL COMMENT 'Mã vận đơn khách gửi hàng về Shop',
  `refund_amount` decimal(15,2) DEFAULT '0.00' COMMENT 'Số tiền thực tế hoàn lại cho khách (nếu là RETURN)',
  `is_deleted` bigint DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_warranty_request_code` (`request_code`,`is_deleted`),
  KEY `fk_warranty_user` (`user_id`),
  KEY `fk_warranty_detail` (`order_detail_id`),
  KEY `fk_warranty_item` (`product_item_id`),
  KEY `fk_warranty_shop` (`shop_id`),
  CONSTRAINT `fk_warranty_detail` FOREIGN KEY (`order_detail_id`) REFERENCES `order_details` (`id`),
  CONSTRAINT `fk_warranty_item` FOREIGN KEY (`product_item_id`) REFERENCES `product_items` (`id`),
  CONSTRAINT `fk_warranty_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`),
  CONSTRAINT `fk_warranty_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `favorites` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `is_deleted` bigint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_favorite_user_product` (`user_id`,`product_id`,`is_deleted`),
  KEY `fav_user_fk` (`user_id`),
  KEY `fav_product_fk` (`product_id`),
  CONSTRAINT `fav_product_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fav_user_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `social_posts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `content` text,
  `media_type` enum('IMAGE','VIDEO') DEFAULT 'IMAGE',
  `media_urls` json DEFAULT NULL,
  `linked_product_id` int DEFAULT NULL,
  `total_likes` int DEFAULT '0',
  `total_comments` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('PENDING','APPROVED','REJECTED','HIDDEN') DEFAULT 'APPROVED' COMMENT 'Trạng thái kiểm duyệt (Mặc định cho duyệt trước, AI lọc sau)',
  `total_shares` int DEFAULT '0' COMMENT 'Lượt chia sẻ để tính điểm Trending',
  `is_deleted` bigint DEFAULT '0',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_posts_user` (`user_id`),
  KEY `fk_posts_pro` (`linked_product_id`),
  CONSTRAINT `fk_posts_pro` FOREIGN KEY (`linked_product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_posts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_follows` (
  `id` int NOT NULL AUTO_INCREMENT,
  `follower_id` int NOT NULL,
  `following_user_id` int DEFAULT NULL,
  `following_shop_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` bigint DEFAULT '0',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_follow_user_del` (`follower_id`,`following_user_id`,`is_deleted`),
  UNIQUE KEY `ux_follow_shop_del` (`follower_id`,`following_shop_id`,`is_deleted`),
  KEY `fk_follow_dest_user` (`following_user_id`),
  KEY `fk_follow_dest_shop` (`following_shop_id`),
  CONSTRAINT `fk_follow_dest_shop` FOREIGN KEY (`following_shop_id`) REFERENCES `shops` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_follow_dest_user` FOREIGN KEY (`following_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_follow_src` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `chk_follow_target` CHECK ((((`following_user_id` is not null) and (`following_shop_id` is null)) or ((`following_user_id` is null) and (`following_shop_id` is not null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_interactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `post_id` bigint DEFAULT NULL,
  `action_type` enum('VIEW','LIKE','UNLIKE','SHARE','CLICK','ADD_CART') NOT NULL COMMENT 'Bổ sung UNLIKE',
  `duration_ms` int DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(50) DEFAULT NULL COMMENT 'Dùng để chặn Bot spam view',
  `device_id` varchar(255) DEFAULT NULL COMMENT 'Định danh thiết bị cho Guest chưa login',
  PRIMARY KEY (`id`,`created_at`),
  KEY `idx_algo_score` (`user_id`,`product_id`,`action_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
/*!50100 PARTITION BY RANGE (((year(`created_at`) * 100) + month(`created_at`)))
(PARTITION p202603 VALUES LESS THAN (202604) ENGINE = InnoDB,
 PARTITION p202604 VALUES LESS THAN (202605) ENGINE = InnoDB,
 PARTITION p202605 VALUES LESS THAN (202606) ENGINE = InnoDB,
 PARTITION p_max VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;


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
