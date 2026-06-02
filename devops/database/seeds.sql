/**
 * =========================================================================
 * QUASAR PLATFORM - DUMMY DATA SEEDING SCRIPT
 * =========================================================================
 * [WARNING] MOCK DATA ONLY: DO NOT RUN THIS ON PRODUCTION!
 * Context:
 * - File này cung cấp lượng lớn dữ liệu giả để phục vụ quá trình test UI/UX.
 * - Yêu cầu: Chạy file `database.sql` trước khi chạy script này.
 * Flow:
 * 1. Trỏ vào database `quasar_platform`.
 * 2. Tắt Foreign Key checks để đảm bảo lệnh TRUNCATE không bị lỗi khóa ngoại.
 * 3. Thực thi TRUNCATE & INSERT dữ liệu mẫu cho 58 bảng.
 * 4. Bật lại Foreign Key checks để khôi phục ràng buộc.
 * =========================================================================
 */

USE quasar_platform;

-- =========================================================================
-- CONFIGURATION PHASE
-- =========================================================================
-- Tạm vô hiệu hóa constraints
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================================
-- PHASE 3: DUMMY DATA SEEDING (DML)
-- =========================================================================


-- *************************************************************************
-- [CỤM 1: IDENTITY & AUTH] - MOCK DATA
-- Mật khẩu mặc định cho tất cả user là: password
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 1. Seed Roles
-- -------------------------------------------------------------------------
TRUNCATE TABLE `roles`;
INSERT INTO `roles` (`id`, `name`, `description`, `is_active`) VALUES
(1, 'user', 'Khách hàng tiêu chuẩn', 1),
(2, 'admin', 'Quản trị viên hệ thống', 1),
(3, 'vendor', 'Đối tác, người bán hàng', 1),
(4, 'staff', 'Nhân viên vận hành nội bộ', 1);

-- -------------------------------------------------------------------------
-- 2. Seed Users
-- -------------------------------------------------------------------------
TRUNCATE TABLE `users`;
INSERT INTO `users` (`id`, `fullname`, `phone_number`, `address`, `password`, `email`, `role_id`, `is_active`, `email_verified_at`, `date_of_birth`) VALUES
(1, 'Super Admin', '0901111111', 'Tòa nhà Lotte, Hà Nội', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@yourdomain.com', 2, 1, NOW(), '1990-05-15'),
(2, 'Đại Lý Phân Phối A', '0902222222', 'Quận 1, TP. HCM', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'vendor_a@domain.com', 3, 1, NOW(), '1985-10-20'),
(3, 'Nhân viên CSKH', '0903333333', 'Cầu Giấy, Hà Nội', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'staff01@yourdomain.com', 4, 1, NOW(), '1998-02-28'),
(4, 'Khách Hàng VIP', '0904444444', 'Đà Nẵng', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer.vip@gmail.com', 1, 1, NOW(), '2000-01-01'),
(5, 'User Chưa Xác Thực', '0905555555', 'Hải Phòng', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'newbie@gmail.com', 1, 1, NULL, '2002-12-12'),
(6, 'User Bị Khóa', '0906666666', 'Cần Thơ', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'banned@gmail.com', 1, 0, NOW(), '1995-07-07');

-- -------------------------------------------------------------------------
-- 3. Seed User Credentials (WebAuthn / Passkeys)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_credentials`;
INSERT INTO `user_credentials` (`user_id`, `credential_id`, `public_key`, `sign_count`, `device_label`, `authenticator_type`, `is_active`) VALUES
(1, 'cred_admin_123', 'pub_key_base64_example_admin', 5, 'Macbook Pro M2 của Admin', 'PLATFORM', 1),
(4, 'cred_vip_456', 'pub_key_base64_example_vip', 12, 'iPhone 14 Pro Max', 'CROSS_PLATFORM', 1);

-- -------------------------------------------------------------------------
-- 4. Seed User Devices (Dành cho Push Notification FCM)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_devices`;
INSERT INTO `user_devices` (`user_id`, `fcm_token`, `device_type`, `device_name`, `device_uid`, `is_active`) VALUES
(1, 'fcm_token_admin_web_abc123', 'WEB', 'Chrome on MacOS', 'uid_mac_admin_001', 1),
(2, 'fcm_token_vendor_android_def456', 'ANDROID', 'Samsung Galaxy S23 Ultra', 'uid_ss_vendor_002', 1),
(3, 'fcm_token_staff_web_ghi789', 'WEB', 'Edge on Windows', 'uid_win_staff_003', 1),
(4, 'fcm_token_vip_ios_jkl012', 'IOS', 'iPhone 14 Pro Max', 'uid_ip_vip_004', 1);

-- -------------------------------------------------------------------------
-- 5. Seed User Sessions (Dành cho JWT Refresh Token)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_sessions`;
INSERT INTO `user_sessions` (`user_id`, `refresh_token_hash`, `device_id`, `ip_address`, `expires_at`, `is_revoked`, `user_agent`) VALUES
(1, 'hash_refresh_admin_999', 'uid_mac_admin_001', '192.168.1.1', DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/114.0.0.0 Safari/537.36'),
(2, 'hash_refresh_vendor_888', 'uid_ss_vendor_002', '14.232.11.22', DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'okhttp/4.9.2 (Android 13)'),
(4, 'hash_refresh_vip_777', 'uid_ip_vip_004', '113.190.22.33', DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'App/1.0 (iOS 16.5)'),
(6, 'hash_refresh_banned_666', 'uid_unknow', '8.8.8.8', DATE_SUB(NOW(), INTERVAL 1 DAY), 1, 'PostmanRuntime/7.29.2'); -- Session đã bị revoke và hết hạn

-- -------------------------------------------------------------------------
-- 6. Seed Social Accounts (OAuth2 Google, Facebook, Apple...)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `social_accounts`;
INSERT INTO `social_accounts` (`provider`, `provider_id`, `email`, `name`, `user_id`, `avatar_url`) VALUES
('google', 'google_100123456789', 'customer.vip@gmail.com', 'Khách Hàng VIP', 4, 'https://lh3.googleusercontent.com/a/fake_avatar_vip'),
('facebook', 'fb_9876543210', 'newbie@gmail.com', 'User Chưa Xác Thực', 5, 'https://graph.facebook.com/fake_id/picture?type=large');


-- *************************************************************************
-- [CỤM 2: GEOGRAPHIC & ADDRESSES] - MOCK DATA
-- Mã Code sử dụng theo chuẩn mã hành chính tổng cục thống kê (tương đối)
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 7. Seed Provinces (Tỉnh / Thành phố trực thuộc T.W)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `provinces`;
INSERT INTO `provinces` (`code`, `name`, `name_en`, `full_name`, `full_name_en`, `region`, `is_active`) VALUES
('01', 'Hà Nội', 'Ha Noi', 'Thành phố Hà Nội', 'Ha Noi City', 'NORTH', 1),
('48', 'Đà Nẵng', 'Da Nang', 'Thành phố Đà Nẵng', 'Da Nang City', 'CENTRAL', 1),
('79', 'Hồ Chí Minh', 'Ho Chi Minh', 'Thành phố Hồ Chí Minh', 'Ho Chi Minh City', 'SOUTH', 1);

-- -------------------------------------------------------------------------
-- 8. Seed Districts (Quận / Huyện)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `districts`;
INSERT INTO `districts` (`code`, `province_code`, `name`, `name_en`, `full_name`, `full_name_en`, `type`, `is_active`) VALUES
('005', '01', 'Cầu Giấy', 'Cau Giay', 'Quận Cầu Giấy', 'Cau Giay District', 'URBAN', 1),
('018', '01', 'Gia Lâm', 'Gia Lam', 'Huyện Gia Lâm', 'Gia Lam District', 'RURAL', 1),
('490', '48', 'Liên Chiểu', 'Lien Chieu', 'Quận Liên Chiểu', 'Lien Chieu District', 'URBAN', 1),
('760', '79', 'Quận 1', 'District 1', 'Quận 1', 'District 1', 'URBAN', 1),
('786', '79', 'Cần Giờ', 'Can Gio', 'Huyện Cần Giờ', 'Can Gio District', 'ISLAND', 1);

-- -------------------------------------------------------------------------
-- 9. Seed Wards (Phường / Xã)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `wards`;
INSERT INTO `wards` (`code`, `district_code`, `name`, `name_en`, `full_name`, `full_name_en`, `delivery_status`, `is_active`) VALUES
('00160', '005', 'Dịch Vọng', 'Dich Vong', 'Phường Dịch Vọng', 'Dich Vong Ward', 'AVAILABLE', 1),
('00538', '018', 'Bát Tràng', 'Bat Trang', 'Xã Bát Tràng', 'Bat Trang Commune', 'AVAILABLE', 1),
('20194', '490', 'Hòa Hiệp Bắc', 'Hoa Hiep Bac', 'Phường Hòa Hiệp Bắc', 'Hoa Hiep Bac Ward', 'AVAILABLE', 1),
('26734', '760', 'Bến Nghé', 'Ben Nghe', 'Phường Bến Nghé', 'Ben Nghe Ward', 'AVAILABLE', 1),
('27676', '786', 'Thạnh An', 'Thanh An', 'Xã Thạnh An', 'Thanh An Commune', 'SUSPENDED', 1); -- Xã đảo đang bị đình chỉ giao hàng do thời tiết xấu

-- -------------------------------------------------------------------------
-- 10. Seed User Addresses (Sổ địa chỉ của người dùng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_addresses`;
INSERT INTO `user_addresses` (`user_id`, `recipient_name`, `phone_number`, `address_detail`, `province_code`, `district_code`, `ward_code`, `is_default`, `latitude`, `longitude`, `address_type`, `is_deleted`) VALUES
-- Địa chỉ của Admin (ID: 1) ở Cầu Giấy, HN
(1, 'Super Admin', '0901111111', 'Tầng 12, Tòa nhà Discovery Complex, 302 Cầu Giấy', '01', '005', '00160', 1, 21.03666700, 105.79388900, 'OFFICE', 0),

-- Địa chỉ của Vendor (ID: 2) ở Quận 1, HCM
(2, 'Đại Lý Phân Phối A', '0902222222', 'Bitexco Financial Tower, Số 2 Hải Triều', '79', '760', '26734', 1, 10.77150000, 106.70420000, 'OFFICE', 0),

-- Khách Hàng VIP (ID: 4) có 2 địa chỉ: 1 mặc định ở Đà Nẵng, 1 địa chỉ phụ ở HN nhưng đã xóa
(4, 'Khách Hàng VIP (Nhà riêng)', '0904444444', '123 Nguyễn Lương Bằng', '48', '490', '20194', 1, 16.06780000, 108.22080000, 'HOME', 0),
(4, 'Người nhận hộ (Gốm sứ)', '0904444555', 'Làng gốm Bát Tràng', '01', '018', '00538', 0, 20.97638900, 105.91416700, 'HOME', 1), -- is_deleted = 1

-- Khách hàng VIP cũng muốn lưu 1 địa chỉ ở Cần Giờ nhưng không giao được
(4, 'Bạn ở Cần Giờ', '0904444666', 'Ấp Thiềng Liềng', '79', '786', '27676', 0, 10.43220000, 106.94210000, 'HOME', 0);


-- *************************************************************************
-- [CỤM 3: MULTI-VENDOR] - MOCK DATA
-- Liên kết trực tiếp với dữ liệu Users từ Cụm 1
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 11. Seed Shops (Cửa hàng / Gian hàng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `shops`;
INSERT INTO `shops` (`id`, `owner_id`, `name`, `slug`, `logo_url`, `banner_url`, `description`, `commission_rate`, `status`, `rating_avg`, `total_orders`, `version`) VALUES
-- Shop 1: Hoạt động mạnh, rating cao, chủ shop là Vendor A (User ID 2)
(1, 2, 'Cửa Hàng Công Nghệ A', 'cua-hang-cong-nghe-a', 'https://example.com/logo/shop_1.png', 'https://example.com/banner/shop_1.jpg', 'Chuyên cung cấp các thiết bị điện tử, laptop và điện thoại chính hãng.', 5.00, 'ACTIVE', 4.8, 1500, 5),

-- Shop 2: Cửa hàng phụ, đang hoạt động, chủ shop vẫn là Vendor A (User ID 2)
(2, 2, 'Tổng Kho Phụ Kiện Rẻ', 'tong-kho-phu-kien-re', 'https://example.com/logo/shop_2.png', 'https://example.com/banner/shop_2.jpg', 'Sỉ lẻ ốp lưng, cáp sạc, đồ chơi công nghệ giá xưởng.', 3.50, 'ACTIVE', 4.2, 320, 2),

-- Shop 3: Shop mới tạo, đang chờ sàn duyệt, chủ shop là User Chưa Xác Thực (User ID 5)
(3, 5, 'Shop Thời Trang Nam Nữ', 'shop-thoi-trang-nam-nu', NULL, NULL, 'Cửa hàng thời trang phong cách Hàn Quốc.', 6.00, 'PENDING', 0, 0, 0),

-- Shop 4: Shop đã bị khóa do vi phạm, chủ shop bị khóa (User ID 6)
(4, 6, 'Hàng Xách Tay US', 'hang-xach-tay-us', 'https://example.com/logo/shop_4.png', NULL, 'Chuyên hàng xách tay không giấy tờ (Đã bị sàn ban).', 5.00, 'BANNED', 1.5, 45, 1);

-- -------------------------------------------------------------------------
-- 12. Seed Shop Employees (Nhân viên của các gian hàng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `shop_employees`;
INSERT INTO `shop_employees` (`shop_id`, `user_id`, `role`, `status`) VALUES
-- Shop 1 thuê Khách Hàng VIP (User ID 4) làm Quản lý (MANAGER)
(1, 4, 'MANAGER', 'ACTIVE'),

-- Shop 1 thuê User Chưa Xác Thực (User ID 5) làm Nhân viên Bán hàng (SALES)
(1, 5, 'SALES', 'ACTIVE'),

-- Shop 2 thuê Khách Hàng VIP (User ID 4) làm Nhân viên Kho (WAREHOUSE)
(2, 4, 'WAREHOUSE', 'ACTIVE'),

-- Ghi nhận lịch sử: User Bị Khóa (User ID 6) từng làm Sales cho Shop 1 nhưng đã nghỉ việc
(1, 6, 'SALES', 'RESIGNED');


-- *************************************************************************
-- [CỤM 4: PRODUCT INFORMATION (PIM)] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 13. Seed Categories (Danh mục sản phẩm)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `categories`;
INSERT INTO `categories` (`id`, `name`, `parent_id`, `path`, `level`, `slug`, `display_mode`) VALUES
(1, 'Điện tử', NULL, '/1', 1, 'dien-tu', 'GRID'),
(2, 'Điện thoại di động', 1, '/1/2', 2, 'dien-thoai-di-dong', 'GRID'),
(3, 'Laptop', 1, '/1/3', 2, 'laptop', 'LIST'),
(4, 'Phụ kiện', NULL, '/4', 1, 'phu-kien', 'GRID'),
(5, 'Ốp lưng', 4, '/4/5', 2, 'op-lung', 'GRID');

-- -------------------------------------------------------------------------
-- 14. Seed Brands (Thương hiệu)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `brands`;
INSERT INTO `brands` (`id`, `name`, `slug`, `tier`, `description`) VALUES
(1, 'Apple', 'apple', 'PREMIUM', 'Thương hiệu công nghệ hàng đầu từ Mỹ.'),
(2, 'Samsung', 'samsung', 'PREMIUM', 'Tập đoàn đa quốc gia của Hàn Quốc.'),
(3, 'Hoco', 'hoco', 'LOCAL', 'Thương hiệu phụ kiện giá rẻ bình dân.');

-- -------------------------------------------------------------------------
-- 15. Seed Options (Các thuộc tính tạo biến thể)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `options`;
INSERT INTO `options` (`id`, `name`, `code`, `type`) VALUES
(1, 'Màu sắc', 'COLOR', 'COLOR_HEX'),
(2, 'Bộ nhớ trong', 'STORAGE', 'TEXT'),
(3, 'RAM', 'RAM', 'TEXT');

-- -------------------------------------------------------------------------
-- 16. Seed Option Values (Giá trị của thuộc tính)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `option_values`;
INSERT INTO `option_values` (`id`, `option_id`, `value`, `meta_data`, `display_order`) VALUES
-- Option: Màu sắc
(1, 1, 'Titan Tự Nhiên', '#878681', 1),
(2, 1, 'Đen Nhám', '#000000', 2),
(3, 1, 'Xanh Phantom', '#008000', 3),
-- Option: Bộ nhớ trong
(4, 2, '256GB', NULL, 1),
(5, 2, '512GB', NULL, 2),
(6, 2, '1TB', NULL, 3),
-- Option: RAM
(7, 3, '8GB', NULL, 1),
(8, 3, '12GB', NULL, 2);

-- -------------------------------------------------------------------------
-- 17. Seed Products (Sản phẩm gốc)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `products`;
INSERT INTO `products` (`id`, `shop_id`, `name`, `slug`, `price`, `thumbnail`, `category_id`, `brand_id`, `quantity`, `reserved_quantity`, `specs`, `is_imei_tracked`) VALUES
-- SP 1: iPhone 15 Pro Max (Shop 1 - Cửa Hàng Công Nghệ A)
(1, 1, 'iPhone 15 Pro Max Chính Hãng VN/A', 'iphone-15-pro-max-chinh-hang-vna', 29990000.00, 'https://example.com/ip15pm.jpg', 2, 1, 150, 10, '{"ram": "8GB", "storage": "256GB/512GB", "screen": "6.7 inch Super Retina XDR", "chip": "Apple A17 Pro"}', 1),

-- SP 2: Galaxy S23 Ultra (Shop 1 - Cửa Hàng Công Nghệ A)
(2, 1, 'Samsung Galaxy S23 Ultra', 'samsung-galaxy-s23-ultra', 25990000.00, 'https://example.com/s23ultra.jpg', 2, 2, 80, 5, '{"ram": "12GB", "storage": "512GB", "screen": "6.8 inch Dynamic AMOLED 2X", "chip": "Snapdragon 8 Gen 2 for Galaxy"}', 1),

-- SP 3: Ốp lưng (Shop 2 - Tổng Kho Phụ Kiện Rẻ)
(3, 2, 'Ốp lưng trong suốt chống sốc', 'op-lung-trong-suot-chong-soc', 50000.00, 'https://example.com/oplung.jpg', 5, 3, 1000, 50, '{"material": "TPU", "thickness": "1.5mm"}', 0);

-- -------------------------------------------------------------------------
-- 18. Seed Product Images (Thư viện ảnh sản phẩm)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `product_images`;
INSERT INTO `product_images` (`product_id`, `image_url`, `display_order`, `image_type`) VALUES
(1, 'https://example.com/ip15pm_1.jpg', 1, 'GALLERY'),
(1, 'https://example.com/ip15pm_2.jpg', 2, 'GALLERY'),
(2, 'https://example.com/s23ultra_1.jpg', 1, 'GALLERY'),
(3, 'https://example.com/oplung_size.jpg', 1, 'SIZE_GUIDE');

-- -------------------------------------------------------------------------
-- 19. Seed Product Variants (Biến thể - SKUs)
-- Chú ý JSON attributes cần chứa field "name" để cột ảo sinh đúng tên biến thể
-- -------------------------------------------------------------------------
TRUNCATE TABLE `product_variants`;
INSERT INTO `product_variants` (`id`, `product_id`, `sku`, `price`, `original_price`, `quantity`, `reserved_quantity`, `attributes`) VALUES
-- Biến thể iPhone 15 Pro Max
(1, 1, 'IP15PM-TITAN-256', 29990000.00, 32000000.00, 100, 5, '{"Color": "Titan Tự Nhiên", "Storage": "256GB", "name": "iPhone 15 Pro Max - Titan Tự Nhiên - 256GB"}'),
(2, 1, 'IP15PM-DEN-256', 29500000.00, 32000000.00, 30, 2, '{"Color": "Đen Nhám", "Storage": "256GB", "name": "iPhone 15 Pro Max - Đen Nhám - 256GB"}'),
(3, 1, 'IP15PM-TITAN-512', 35990000.00, 38000000.00, 20, 3, '{"Color": "Titan Tự Nhiên", "Storage": "512GB", "name": "iPhone 15 Pro Max - Titan Tự Nhiên - 512GB"}'),

-- Biến thể Galaxy S23 Ultra
(4, 2, 'SS23U-XANH-512', 25990000.00, 31990000.00, 80, 5, '{"Color": "Xanh Phantom", "Storage": "512GB", "name": "Samsung Galaxy S23 Ultra - Xanh Phantom - 512GB"}'),

-- Sản phẩm không có biến thể rõ ràng thì thường tạo 1 biến thể mặc định
(5, 3, 'OP-TRONG-001', 50000.00, 100000.00, 1000, 50, '{"name": "Ốp lưng trong suốt chống sốc - Mặc định"}');

-- -------------------------------------------------------------------------
-- 20. Seed Variant Values (Bảng map nối Product, Variant và Option Values)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `variant_values`;
INSERT INTO `variant_values` (`variant_id`, `product_id`, `option_id`, `option_value_id`) VALUES
-- IP15PM-TITAN-256 (Màu: Titan Tự Nhiên, Dung lượng: 256GB)
(1, 1, 1, 1),
(1, 1, 2, 4),

-- IP15PM-DEN-256 (Màu: Đen Nhám, Dung lượng: 256GB)
(2, 1, 1, 2),
(2, 1, 2, 4),

-- IP15PM-TITAN-512 (Màu: Titan Tự Nhiên, Dung lượng: 512GB)
(3, 1, 1, 1),
(3, 1, 2, 5),

-- SS23U-XANH-512 (Màu: Xanh Phantom, Dung lượng: 512GB)
(4, 2, 1, 3),
(4, 2, 2, 5);

-- -------------------------------------------------------------------------
-- 21. Seed Price Histories (Lịch sử thay đổi giá)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `price_histories`;
INSERT INTO `price_histories` (`product_id`, `variant_id`, `old_price`, `new_price`, `updated_by`, `reason`, `price_type`) VALUES
(1, 1, 32000000.00, 29990000.00, 1, 'FLASH_SALE', 'SELLING_PRICE'),
(1, 2, 32000000.00, 29500000.00, 1, 'FLASH_SALE', 'SELLING_PRICE'),
(2, 4, 31990000.00, 25990000.00, 1, 'MANUAL_UPDATE', 'SELLING_PRICE');


-- *************************************************************************
-- [CỤM 5: INVENTORY & SUPPLIERS] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 22. Seed Suppliers (Nhà cung cấp)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `suppliers`;
INSERT INTO `suppliers` (`id`, `shop_id`, `name`, `contact_email`, `contact_phone`, `tax_code`, `address`, `total_debt`, `status`) VALUES
-- NCC của Shop 1 (Cửa Hàng Công Nghệ A)
(1, 1, 'Nhà Phân Phối Apple VN', 'contact@appledist.vn', '0909999999', '0101234567', 'Tòa nhà Viettel, Quận 10, TP.HCM', 0.00, 'ACTIVE'),
(2, 1, 'Samsung Electronics VN', 'sales@samsung.vn', '0908888888', '0107654321', 'KCN Yên Phong, Bắc Ninh', 50000000.00, 'ACTIVE'),

-- NCC của Shop 2 (Tổng Kho Phụ Kiện Rẻ)
(3, 2, 'Xưởng Phụ Kiện Thâm Quyến', 'wholesale@sz-cases.cn', '00861380000', NULL, 'Thâm Quyến, Trung Quốc', 15000000.00, 'ACTIVE');

-- -------------------------------------------------------------------------
-- 23. Seed Inventory Transactions (Phiếu nhập/xuất kho)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `inventory_transactions`;
INSERT INTO `inventory_transactions` (`id`, `shop_id`, `transaction_code`, `type`, `reference_type`, `reference_id`, `note`, `created_by`, `status`, `total_value`) VALUES
-- Phiếu nhập kho cho Shop 1
(1, 1, 'PN-001', 'INBOUND', 'PURCHASE_ORDER', 101, 'Nhập lô iPhone 15 Pro Max đầu tháng', 1, 'COMPLETED', 56000000.00),
(2, 1, 'PN-002', 'INBOUND', 'PURCHASE_ORDER', 102, 'Nhập lô Galaxy S23 Ultra', 1, 'COMPLETED', 46000000.00),

-- Phiếu nhập kho cho Shop 2
(3, 2, 'PN-003', 'INBOUND', 'MANUAL', NULL, 'Nhập ốp lưng sỉ đợt 1', 4, 'COMPLETED', 20000000.00);

-- -------------------------------------------------------------------------
-- 24. Seed Product Items (Sản phẩm độc bản - Quản lý theo IMEI)
-- Lưu ý: order_id tạm để NULL chờ Cụm Orders
-- -------------------------------------------------------------------------
TRUNCATE TABLE `product_items`;
INSERT INTO `product_items` (`id`, `product_id`, `variant_id`, `supplier_id`, `order_id`, `imei_code`, `inbound_price`, `status`, `attributes`) VALUES
-- 2 chiếc iPhone 15 Pro Max (Variant ID: 1 - Titan 256GB) nhập từ NCC Apple
(1, 1, 1, 1, NULL, 'IMEI358123456789001', 28000000.00, 'AVAILABLE', '{"battery_health": "100%"}'),
(2, 1, 1, 1, NULL, 'IMEI358123456789002', 28000000.00, 'AVAILABLE', '{"battery_health": "100%"}'),

-- 2 chiếc Samsung S23 Ultra (Variant ID: 4 - Xanh 512GB) nhập từ NCC Samsung
(3, 2, 4, 2, NULL, 'IMEI359987654321001', 23000000.00, 'AVAILABLE', NULL),
(4, 2, 4, 2, NULL, 'IMEI359987654321002', 23000000.00, 'PENDING', NULL); -- 1 chiếc đang PENDING (có thể đang có khách thao tác đặt hàng nhưng chưa thanh toán)

-- -------------------------------------------------------------------------
-- 25. Seed Inventory Transaction Details (Chi tiết thay đổi tồn kho)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `inventory_transaction_details`;
INSERT INTO `inventory_transaction_details` (`id`, `transaction_id`, `product_id`, `variant_id`, `product_item_id`, `quantity_changed`, `stock_before`, `stock_after`, `unit_cost`) VALUES
-- Chi tiết phiếu PN-001 (Map từng IMEI của iPhone)
(1, 1, 1, 1, 1, 1, 0, 1, 28000000.00),
(2, 1, 1, 1, 2, 1, 1, 2, 28000000.00),

-- Chi tiết phiếu PN-002 (Map từng IMEI của Samsung)
(3, 2, 2, 4, 3, 1, 0, 1, 23000000.00),
(4, 2, 2, 4, 4, 1, 1, 2, 23000000.00),

-- Chi tiết phiếu PN-003 (Sản phẩm Ốp lưng ID 3, Variant 5 - Không quản lý IMEI nên product_item_id = NULL, cộng dồn số lượng)
(5, 3, 3, 5, NULL, 1000, 0, 1000, 20000.00);


-- *************************************************************************
-- [CỤM 6: SHOPPING CART] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 26. Seed Carts (Giỏ hàng của người dùng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `carts`;
INSERT INTO `carts` (`id`, `user_id`, `session_id`, `status`, `expires_at`) VALUES
-- Giỏ hàng 1: Của Khách hàng VIP (User ID 4), đang mua sắm bình thường
(1, 4, 'session_vip_user_4', 'ACTIVE', DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- Giỏ hàng 2: Của User mới (User ID 5), đang ở bước Checkout chờ thanh toán nên bị LOCK
(2, 5, 'session_newbie_user_5', 'LOCKED', DATE_ADD(NOW(), INTERVAL 1 DAY)),

-- Giỏ hàng 3: Khách vãng lai chưa đăng nhập (user_id = NULL, quản lý qua session_id)
(3, NULL, 'session_guest_xyz_789', 'ACTIVE', DATE_ADD(NOW(), INTERVAL 7 DAY));

-- -------------------------------------------------------------------------
-- 27. Seed Cart Items (Sản phẩm trong giỏ hàng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `cart_items`;
INSERT INTO `cart_items` (`cart_id`, `product_id`, `variant_id`, `quantity`, `price_at_add`, `is_selected`) VALUES
-- Giỏ 1 (Khách VIP): Mua 1 iPhone 15 Pro Max (Titan 256GB - Variant 1)
-- Giá lúc bỏ vào giỏ là 30.000.000đ (cao hơn giá hiện tại 29.990.000đ ở Cụm 4, FE có thể hiện thông báo "Sản phẩm đã giảm giá!")
(1, 1, 1, 1, 30000000.00, 1),

-- Giỏ 1 (Khách VIP): Mua thêm 2 Ốp lưng trong suốt (Variant 5). Khách không tick chọn thanh toán món này (is_selected = 0)
(1, 3, 5, 2, 50000.00, 0),

-- Giỏ 2 (User 5 - Bị LOCK): Đang chuẩn bị thanh toán 1 máy Galaxy S23 Ultra (Variant 4)
(2, 2, 4, 1, 25990000.00, 1),

-- Giỏ 3 (Guest): Bỏ vào giỏ 5 cái ốp lưng (Variant 5) để xem phí ship
(3, 3, 5, 5, 50000.00, 1);


-- *************************************************************************
-- [CỤM 7: CHECKOUT & ORDERS] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 28. Seed POS Sessions (Ca bán hàng tại quầy)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `pos_sessions`;
INSERT INTO `pos_sessions` (`id`, `shop_id`, `user_id`, `start_at`, `opening_cash`, `status`) VALUES
-- Ca mở bởi User 4 (Đang đóng vai trò Manager của Shop 1)
(1, 1, 4, NOW(), 5000000.00, 'OPEN');

-- -------------------------------------------------------------------------
-- 29. Seed Orders (Đơn hàng tổng của khách)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `orders`;
INSERT INTO `orders` (`id`, `order_code`, `user_id`, `pos_session_id`, `fullname`, `phone_number`, `address`, `province_code`, `district_code`, `ward_code`, `status`, `sub_total`, `shipping_fee`, `total_money`, `order_channel`, `payment_method`, `payment_status`, `total_cost_price`) VALUES
-- Đơn 1: Khách hàng VIP (User 4) đặt mua online từ 2 Shop (1 iPhone của Shop 1 + 2 ốp lưng của Shop 2)
(1, 'ORD-202310-001', 4, NULL, 'Khách Hàng VIP', '0904444444', '123 Nguyễn Lương Bằng', '48', '490', '20194', 'PROCESSING', 30090000.00, 35000.00, 30125000.00, 'ONLINE', 'VNPAY', 'PAID', 28040000.00),

-- Đơn 2: Khách vãng lai đến cửa hàng mua máy trực tiếp qua hệ thống POS
(2, 'ORD-202310-002', 5, 1, 'Khách Vãng Lai', '0905555555', 'Mua tại cửa hàng', NULL, NULL, NULL, 'COMPLETED', 25990000.00, 0.00, 25990000.00, 'POS', 'CASH', 'PAID', 23000000.00);

-- -------------------------------------------------------------------------
-- 30. Seed Orders Shop (Kiện hàng chia về cho từng Shop)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `orders_shop`;
INSERT INTO `orders_shop` (`id`, `parent_order_id`, `shop_id`, `sub_total`, `shipping_fee`, `admin_commission`, `shop_income`, `status`, `order_shop_code`, `carrier_name`) VALUES
-- Từ Đơn 1, tách ra kiện hàng số 1 cho Shop 1 (iPhone 15 PM)
(1, 1, 1, 29990000.00, 20000.00, 1499500.00, 28490500.00, 'PROCESSING', 'PKG-001-S1', 'GHTK'),

-- Từ Đơn 1, tách ra kiện hàng số 2 cho Shop 2 (2 cái Ốp lưng)
(2, 1, 2, 100000.00, 15000.00, 5000.00, 95000.00, 'SHIPPED', 'PKG-001-S2', 'GHN'),

-- Từ Đơn 2 (POS), kiện hàng hoàn thành luôn tại chỗ
(3, 2, 1, 25990000.00, 0.00, 1299500.00, 24690500.00, 'DELIVERED', 'PKG-002-S1', NULL);

-- -------------------------------------------------------------------------
-- 31. Seed Order Details (Chi tiết từng món hàng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `order_details`;
INSERT INTO `order_details` (`id`, `order_id`, `order_shop_id`, `product_id`, `variant_id`, `product_item_id`, `supplier_id`, `price`, `number_of_products`, `total_money`, `cost_price`, `product_name`, `variant_name`) VALUES
-- Món 1 (Thuộc kiện 1): 1 chiếc iPhone (Lấy Item ID 1 - IMEI358123456789001 từ kho)
(1, 1, 1, 1, 1, 1, 1, 29990000.00, 1, 29990000.00, 28000000.00, 'iPhone 15 Pro Max Chính Hãng VN/A', 'Titan Tự Nhiên - 256GB'),

-- Món 2 (Thuộc kiện 2): 2 chiếc Ốp lưng (Sản phẩm không quản lý IMEI nên product_item_id = NULL)
(2, 1, 2, 3, 5, NULL, 3, 50000.00, 2, 100000.00, 20000.00, 'Ốp lưng trong suốt chống sốc', 'Mặc định'),

-- Món 3 (Thuộc kiện 3): 1 chiếc Samsung (Lấy Item ID 3 - IMEI359987654321001 từ kho)
(3, 2, 3, 2, 4, 3, 2, 25990000.00, 1, 25990000.00, 23000000.00, 'Samsung Galaxy S23 Ultra', 'Xanh Phantom - 512GB');

-- -------------------------------------------------------------------------
-- 32. Seed Order Histories (Nhật ký trạng thái đơn)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `order_histories`;
INSERT INTO `order_histories` (`order_id`, `order_shop_id`, `status`, `note`, `updated_by`) VALUES
-- Log cho Đơn 1 (Đơn tổng)
(1, NULL, 'PENDING', 'Khách hàng vừa tạo đơn đặt hàng', 4),
(1, NULL, 'PROCESSING', 'Thanh toán VNPAY thành công, hệ thống tách đơn cho các shop', NULL),

-- Log cho Kiện hàng của Shop 1
(1, 1, 'PROCESSING', 'Shop 1 đang chuẩn bị gói hàng', 2),

-- Log cho Kiện hàng của Shop 2
(1, 2, 'SHIPPED', 'Shop 2 đã giao hàng cho bưu tá GHN', 2),

-- Log cho Đơn 2 (Mua tại POS)
(2, NULL, 'COMPLETED', 'Khách thanh toán tiền mặt tại quầy', 4),
(2, 3, 'DELIVERED', 'Giao dịch POS thành công, khách đã nhận máy', 4);


-- *************************************************************************
-- [CỤM 8: PAYMENT & WALLET] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 33. Seed Transactions (Giao dịch thanh toán cổng ngoài/tiền mặt)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `transactions`;
INSERT INTO `transactions` (`id`, `order_id`, `order_shop_id`, `payment_method`, `transaction_code`, `amount`, `type`, `status`, `response_json`, `gateway_code`, `error_message`) VALUES
-- Giao dịch 1: Thanh toán thành công cho Đơn 1 bằng VNPAY (Đơn hàng online)
(1, 1, NULL, 'VNPAY', 'VNP123456789', 30125000.00, 'PAYMENT', 'SUCCESS', '{"vnp_TransactionNo": "135790", "vnp_BankCode": "NCB"}', '00', NULL),

-- Giao dịch 2: Khách mua tại POS thanh toán tiền mặt cho Đơn 2
(2, 2, NULL, 'CASH', 'POS-CASH-ORD2', 25990000.00, 'PAYMENT', 'SUCCESS', '{}', '00', NULL),

-- Giao dịch 3: Một giao dịch lỗi mẫu (Ví dụ khách quét Momo nhưng thoát app ngang)
(3, 1, NULL, 'MOMO', 'MOMO-FAIL-001', 30125000.00, 'PAYMENT', 'FAILED', '{"errorCode": 1006}', '1006', 'Người dùng hủy giao dịch');

-- -------------------------------------------------------------------------
-- 34. Seed Wallets (Ví nội bộ của User / Vendor)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `wallets`;
INSERT INTO `wallets` (`id`, `user_id`, `balance`, `frozen_balance`, `status`) VALUES
-- Ví 1: Của Vendor A (Chủ Shop 1 & Shop 2 - User ID 2)
-- Đang có 5tr tiền mặt tự do, và đang bị "hold" hơn 28tr từ Đơn 1 (Đơn này đang giao, chưa đối soát)
(1, 2, 5000000.00, 28490500.00, 'ACTIVE'),

-- Ví 2: Của Khách hàng VIP (User ID 4)
-- Đang có 500k tiền hoàn (Cashback) hoặc tự nạp vào để trừ dần phí ship
(2, 4, 500000.00, 0.00, 'ACTIVE');

-- -------------------------------------------------------------------------
-- 35. Seed Wallet Transactions (Lịch sử biến động số dư)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `wallet_transactions`;
INSERT INTO `wallet_transactions` (`wallet_id`, `amount`, `type`, `description`, `ref_order_id`, `reference_code`, `balance_before`, `balance_after`, `created_by`) VALUES
-- Biến động 1: Cộng tiền hold (FROZEN) vào ví Vendor A từ Kiện hàng số 1 (Shop 1)
(1, 28490500.00, 'FROZEN_ADD', 'Tiền bán hàng chờ đối soát (Kiện PKG-001-S1)', 1, 'WT-FROZEN-ORD1-S1', 0.00, 28490500.00, NULL),

-- Biến động 2: Khách VIP tự nạp 500k vào ví từ thẻ ATM
(2, 500000.00, 'TOP_UP', 'Nạp tiền vào ví', NULL, 'WT-TOPUP-VIP-001', 0.00, 500000.00, 4);

-- -------------------------------------------------------------------------
-- 36. Seed Withdrawal Requests (Yêu cầu rút tiền về ngân hàng thực)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `withdrawal_requests`;
INSERT INTO `withdrawal_requests` (`id`, `user_id`, `amount`, `bank_name`, `bank_account`, `account_holder`, `status`, `admin_note`) VALUES
-- Yêu cầu 1: Vendor A làm lệnh rút 2 triệu từ số dư khả dụng (balance) về tài khoản VCB
(1, 2, 2000000.00, 'Vietcombank', '0123456789', 'DAI LY PHAN PHOI A', 'PENDING', 'Đang chờ Kế toán duyệt'),

-- Yêu cầu 2: Vendor A từng rút 1 triệu thành công trước đó
(2, 2, 1000000.00, 'Techcombank', '190333444555', 'DAI LY PHAN PHOI A', 'APPROVED', 'Đã chuyển khoản UNC 998877');


-- *************************************************************************
-- [CỤM 9: MARKETING & PROMOTIONS] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 37. Seed Banners (Quảng cáo, Slide trang chủ)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `banners`;
INSERT INTO `banners` (`id`, `title`, `image_url`, `target_url`, `position`, `display_order`, `is_active`, `start_time`, `end_time`, `click_count`, `platform`) VALUES
(1, 'Siêu Sale Sinh Nhật Sàn', 'https://example.com/banners/birthday.jpg', '/campaign/birthday', 'HOME_MAIN', 1, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY), 1250, 'ALL'),
(2, 'Apple Week - Giảm đến 2 triệu', 'https://example.com/banners/apple_week.jpg', '/brands/apple', 'CATEGORY_TOP', 2, 1, NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), 340, 'WEB'),
(3, 'Freeship mọi miền', 'https://example.com/banners/freeship.jpg', '/freeship', 'APP_POPUP', 1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 5600, 'MOBILE');

-- -------------------------------------------------------------------------
-- 38. Seed Flash Sales (Chiến dịch Sale chớp nhoáng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `flash_sales`;
INSERT INTO `flash_sales` (`id`, `name`, `start_time`, `end_time`, `status`, `shop_id`, `cover_image`) VALUES
-- Flash sale của toàn Sàn (shop_id = NULL)
(1, 'Flash Sale Nửa Đêm 0h - 2h', DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 1 HOUR), 'ACTIVE', NULL, 'https://example.com/fs_midnight.jpg'),

-- Flash sale riêng của Shop 1
(2, 'Giờ Vàng Giá Sốc Kèm Quà', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 'ENDED', 1, 'https://example.com/fs_shop1.jpg');

-- -------------------------------------------------------------------------
-- 39. Seed Flash Sale Items (Sản phẩm trong Flash Sale)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `flash_sale_items`;
INSERT INTO `flash_sale_items` (`id`, `flash_sale_id`, `product_id`, `variant_id`, `promotional_price`, `quantity_limit`, `sold_count`, `version`) VALUES
-- SP 1 (iPhone 15 PM - Variant 1) sale trong Flash Sale 1. Giá KM 28.5tr (Giá gốc 29.99tr)
(1, 1, 1, 1, 28500000.00, 10, 2, 2),

-- SP 3 (Ốp lưng - Variant 5) sale trong Flash Sale 2 của Shop. Giá KM 19k (Giá gốc 50k) - Đã bán hết
(2, 2, 3, 5, 19000.00, 50, 50, 50);

-- -------------------------------------------------------------------------
-- 40. Seed Coupons (Mã giảm giá/Voucher)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `coupons`;
INSERT INTO `coupons` (`id`, `shop_id`, `code`, `name`, `description`, `discount_type`, `discount_value`, `max_discount_amount`, `min_order_amount`, `start_date`, `end_date`, `usage_limit`, `used_count`, `total_budget`, `used_budget`, `is_active`) VALUES
-- Mã toàn sàn: Giảm thẳng 100k cho đơn từ 1 Triệu. Đã có 1 người dùng (Khách VIP ở Cụm 7).
(1, NULL, 'SAN100K', 'Giảm 100K Đơn từ 1 Triệu', 'Áp dụng cho mọi hình thức thanh toán', 'FIXED_AMOUNT', 100000.00, 100000.00, 1000000.00, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY), 1000, 1, 100000000.00, 100000.00, 1),

-- Mã của Shop 1: Giảm 5% tối đa 500k cho đơn từ 5 Triệu. (Chưa ai dùng)
(2, 1, 'TECH5PT', 'Giảm 5% cho đồ công nghệ', 'Áp dụng riêng tại Cửa Hàng Công Nghệ A', 'PERCENTAGE', 5.00, 500000.00, 5000000.00, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 100, 0, 50000000.00, 0.00, 1);

-- -------------------------------------------------------------------------
-- 41. Seed Coupon Applicables (Luật áp dụng mã)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `coupon_applicables`;
INSERT INTO `coupon_applicables` (`id`, `coupon_id`, `object_type`, `object_id`, `applicable_type`) VALUES
-- Mã TECH5PT (ID: 2) CHỈ áp dụng cho Danh mục "Điện thoại di động" (Category ID: 2)
(1, 2, 'CATEGORY', 2, 'INCLUDE'),

-- Nhưng NGOẠI TRỪ thương hiệu Samsung (Brand ID: 2) -> Khách chỉ mua iPhone mới được xài mã này
(2, 2, 'BRAND', 2, 'EXCLUDE');

-- -------------------------------------------------------------------------
-- 42. Seed Coupon Usages (Lịch sử sử dụng mã)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `coupon_usages`;
INSERT INTO `coupon_usages` (`id`, `user_id`, `coupon_id`, `order_id`, `discount_amount`, `status`) VALUES
-- Khách VIP (ID 4) đã dùng mã SAN100K (ID 1) cho đơn hàng Online đầu tiên (Order ID 1)
(1, 4, 1, 1, 100000.00, 'APPLIED');


-- *************************************************************************
-- [CỤM 10: AFFILIATE & SHOWCASE] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 43. Seed Affiliate Links (Link tiếp thị liên kết)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `affiliate_links`;
INSERT INTO `affiliate_links` (`id`, `user_id`, `product_id`, `code`, `clicks`, `is_active`, `commission_rate`, `orders_count`, `total_earnings`) VALUES
-- Link 1: KOC (User 3) chia sẻ iPhone (Product 1). Hoa hồng 1.5%
(1, 3, 1, 'AFF-IP15-KOC03', 1520, 1, 1.50, 1, 449850.00),

-- Link 2: KOC (User 3) chia sẻ Ốp lưng (Product 3). Hoa hồng 10%
(2, 3, 3, 'AFF-OPLUNG-KOC03', 850, 1, 10.00, 1, 10000.00);

-- -------------------------------------------------------------------------
-- 44. Seed User Showcase Items (Tủ đồ của KOC hiển thị trên Profile)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_showcase_items`;
INSERT INTO `user_showcase_items` (`id`, `user_id`, `product_id`, `is_hidden`, `display_order`, `affiliate_link_id`) VALUES
-- Đưa iPhone lên đầu trang (Ưu tiên 1)
(1, 3, 1, 0, 1, 1),

-- Đưa Ốp lưng xuống dưới (Ưu tiên 2)
(2, 3, 3, 0, 2, 2);

-- -------------------------------------------------------------------------
-- 45. Seed Affiliate Transactions (Hoa hồng phát sinh từ đơn hàng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `affiliate_transactions`;
INSERT INTO `affiliate_transactions` (`id`, `affiliate_link_id`, `order_shop_id`, `amount`, `status`) VALUES
-- Giao dịch 1: Khách VIP mua iPhone (Kiện hàng số 1).
-- Hoa hồng = 1.5% * 29.990.000 = 449.850đ. Trạng thái PENDING vì đơn này mới đang PROCESSING
(1, 1, 1, 449850.00, 'PENDING'),

-- Giao dịch 2: Khách VIP mua Ốp lưng (Kiện hàng số 2).
-- Hoa hồng = 10% * 100.000 (Tổng tiền 2 cái ốp) = 10.000đ. Trạng thái APPROVED vì đơn này đã SHIPPED. Chờ qua 7 ngày đổi trả sẽ đổi thành PAID.
(2, 2, 2, 10000.00, 'APPROVED');


-- *************************************************************************
-- [CỤM 11: REVIEWS & POST-SALE] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 46. Seed Product Reviews (Đánh giá sản phẩm)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `product_reviews`;
INSERT INTO `product_reviews` (`id`, `product_id`, `order_detail_id`, `user_id`, `content`, `rating`, `images`, `status`, `helpful_count`) VALUES
-- Review 1: Khách VIP (ID 4) đánh giá chiếc iPhone (Order Detail 1)
(1, 1, 1, 4, 'Máy dùng rất mượt, camera chụp đêm siêu nét. Shop đóng gói cực kỳ cẩn thận, bọc chống sốc 3 lớp. Sẽ còn ủng hộ shop vào lần mua sau!', 5, '["https://example.com/rev1.jpg", "https://example.com/rev2.jpg"]', 'APPROVED', 12),

-- Review 2: Khách vãng lai (ID 5) đánh giá chiếc Samsung mua tại POS (Order Detail 3)
(2, 2, 3, 5, 'Nhân viên tư vấn nhiệt tình, mua tại quầy nhanh gọn. Tuy nhiên hôm đó cửa hàng hơi đông nên phải chờ thanh toán mất 15 phút. Trải nghiệm máy rất tốt.', 4, '[]', 'APPROVED', 2);

-- -------------------------------------------------------------------------
-- 47. Seed Product Review Replies (Shop trả lời đánh giá SP)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `product_review_replies`;
INSERT INTO `product_review_replies` (`id`, `review_id`, `shop_id`, `vendor_user_id`, `content`) VALUES
-- Shop 1 (Tài khoản Vendor A - ID 2) vào cảm ơn Khách VIP
(1, 1, 1, 2, 'Dạ Cửa Hàng Công Nghệ A rất cảm ơn đánh giá chi tiết của anh/chị. Chúc anh/chị có những trải nghiệm tuyệt vời với sản phẩm ạ!');

-- -------------------------------------------------------------------------
-- 48. Seed Shop Reviews (Đánh giá dịch vụ của Shop)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `shop_reviews`;
INSERT INTO `shop_reviews` (`id`, `shop_id`, `user_id`, `order_shop_id`, `rating`, `content`, `images`, `status`) VALUES
-- Khách VIP (ID 4) đánh giá dịch vụ của Shop 2 (Tổng Kho Phụ Kiện Rẻ) dựa trên Kiện hàng số 2
(1, 2, 4, 2, 5, 'Shop giao hàng cho bên vận chuyển rất nhanh. Vừa đặt hôm trước hôm sau đã nhận được. Mua ốp lưng mấy chục ngàn mà đóng hộp xịn xò như đồ tiền triệu.', '["https://example.com/shoprev.jpg"]', 'APPROVED');

-- -------------------------------------------------------------------------
-- 49. Seed Shop Review Replies (Shop trả lời đánh giá dịch vụ)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `shop_review_replies`;
INSERT INTO `shop_review_replies` (`id`, `review_id`, `vendor_user_id`, `content`) VALUES
-- Shop 2 (Vendor A - ID 2) trả lời đánh giá
(1, 1, 2, 'Tổng Kho Phụ Kiện Rẻ cảm ơn quý khách. Rất mong được tiếp tục phục vụ quý khách ở những đơn hàng tiếp theo!');

-- -------------------------------------------------------------------------
-- 50. Seed Warranty Requests (Yêu cầu bảo hành / Trả hàng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `warranty_requests`;
INSERT INTO `warranty_requests` (`id`, `user_id`, `order_detail_id`, `product_item_id`, `request_type`, `status`, `reason`, `images`, `admin_note`, `request_code`, `shop_id`) VALUES
-- Khách VIP (ID 4) tạo yêu cầu bảo hành chiếc iPhone (Item ID 1) do lỗi pin
(1, 4, 1, 1, 'WARRANTY', 'RECEIVED', 'Máy dạo này thi thoảng bị sập nguồn khi pin còn 20%, cắm sạc thì báo nhiệt độ cao không nhận điện.', '["https://example.com/error_pin_1.jpg"]', 'Đã tiếp nhận máy, đang chuyển sang Trung tâm bảo hành Apple kiểm tra mã lỗi', 'RMA-202310-001', 1);


-- *************************************************************************
-- [CỤM 12: SOCIAL & TELEMETRY] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 49. Seed Favorites (Sản phẩm yêu thích / Wishlist)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `favorites`;
INSERT INTO `favorites` (`user_id`, `product_id`) VALUES
-- Khách VIP (ID 4) thả tim chiếc iPhone
(4, 1),

-- User mới (ID 5) thả tim chiếc Samsung
(5, 2);

-- -------------------------------------------------------------------------
-- 50. Seed Social Posts (Bài đăng trên Feed cộng đồng)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `social_posts`;
INSERT INTO `social_posts` (`id`, `user_id`, `content`, `media_type`, `media_urls`, `linked_product_id`, `total_likes`, `total_comments`, `total_shares`, `status`) VALUES
-- KOC (User 3) đăng video review, gắn kèm link trực tiếp tới sản phẩm iPhone
(1, 3, 'Đập hộp iPhone 15 Pro Max màu Titan siêu cháy! Anh em vào xem ngay link bên dưới nhé 👇', 'VIDEO', '["https://example.com/video_unbox.mp4"]', 1, 1500, 230, 45, 'APPROVED'),

-- Khách VIP (User 4) đăng khoe chiến tích mua ốp lưng rẻ
(2, 4, 'Mới săn được cái ốp lưng 19k rẻ bèo mà xịn thực sự, đóng gói cũng kỹ nữa.', 'IMAGE', '["https://example.com/post_oplung_1.jpg", "https://example.com/post_oplung_2.jpg"]', 3, 120, 15, 2, 'APPROVED');

-- -------------------------------------------------------------------------
-- 51. Seed User Follows (Theo dõi)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_follows`;
INSERT INTO `user_follows` (`follower_id`, `following_user_id`, `following_shop_id`) VALUES
-- User mới (ID 5) ấn theo dõi tài khoản KOC (User 3)
(5, 3, NULL),

-- Khách VIP (ID 4) ấn theo dõi Cửa Hàng Công Nghệ A (Shop 1) để canh Sale
(4, NULL, 1);

-- -------------------------------------------------------------------------
-- 52. Seed User Interactions (Lưu vết hành vi - Dùng cho AI Suggestion)
-- Chú ý: Bảng này có Primary Key ghép (id, created_at) do dùng Partitioning
-- -------------------------------------------------------------------------
TRUNCATE TABLE `user_interactions`;
INSERT INTO `user_interactions` (`user_id`, `product_id`, `post_id`, `action_type`, `duration_ms`, `ip_address`, `device_id`, `created_at`) VALUES
-- Hành vi 1: Khách VIP (ID 4) lướt xem Bài đăng số 1 trong 15 giây (15000ms)
(4, NULL, 1, 'VIEW', 15000, '113.190.22.33', 'uid_ip_vip_004', DATE_SUB(NOW(), INTERVAL 2 HOUR)),

-- Hành vi 2: Khách VIP (ID 4) thả LIKE cho Bài đăng số 1
(4, NULL, 1, 'LIKE', 0, '113.190.22.33', 'uid_ip_vip_004', DATE_SUB(NOW(), INTERVAL 115 MINUTE)),

-- Hành vi 3: Khách VIP bấm vào sản phẩm iPhone từ bài đăng, xem mất 45 giây
(4, 1, NULL, 'VIEW', 45000, '113.190.22.33', 'uid_ip_vip_004', DATE_SUB(NOW(), INTERVAL 114 MINUTE)),

-- Hành vi 4: Một khách vãng lai (Guest - Chưa login) xem lướt qua sản phẩm Samsung
(NULL, 2, NULL, 'VIEW', 5000, '8.8.8.8', 'guest_device_abc123', NOW());


-- *************************************************************************
-- [CỤM 13: REALTIME COMMUNICATIONS] - MOCK DATA
-- *************************************************************************

-- -------------------------------------------------------------------------
-- 53. Seed Notifications (Thông báo hệ thống / App Push)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `notifications`;
INSERT INTO `notifications` (`id`, `user_id`, `title`, `body`, `type`, `reference_id`, `is_read`, `deep_link`) VALUES
-- Thông báo cho Vendor (User 2)
(1, 2, 'Bạn có đơn hàng mới! 🎉', 'Khách Hàng VIP vừa đặt mua iPhone 15 Pro Max. Vui lòng chuẩn bị hàng trước 15:00 hôm nay.', 'ORDER', '1', 0, '/vendor/orders/1'),

-- Thông báo cho Khách VIP (User 4)
(2, 4, 'Đơn hàng đang được giao 🚚', 'Kiện hàng PKG-001-S1 của bạn đã được giao cho đơn vị vận chuyển GHTK.', 'ORDER', 'PKG-001-S1', 1, '/user/orders/1'),
(3, 4, 'Tặng bạn mã giảm 100K 🎁', 'Mã SAN100K đã được thêm vào ví voucher của bạn. Hạn sử dụng đến cuối tháng, dùng ngay!', 'PROMOTION', '1', 1, '/user/vouchers');

-- -------------------------------------------------------------------------
-- 54. Seed Chat Rooms (Phòng Chat)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `chat_rooms`;
INSERT INTO `chat_rooms` (`id`, `name`, `type`, `last_message`, `shop_id`) VALUES
-- Phòng chat hỗ trợ 1-1 giữa Khách VIP và Shop 1
(1, 'Hỗ trợ đơn hàng ORD-202310-001', 'SUPPORT', 'Dạ vâng ạ, shop sẽ bọc 3 lớp chống sốc cho anh/chị yên tâm nhé.', 1);

-- -------------------------------------------------------------------------
-- 55. Seed Chat Participants (Thành viên trong phòng chat)
-- -------------------------------------------------------------------------
TRUNCATE TABLE `chat_participants`;
INSERT INTO `chat_participants` (`room_id`, `user_id`, `role`, `last_read_message_id`) VALUES
-- Khách VIP (User 4) tham gia với tư cách người mua
(1, 4, 'MEMBER', 2),

-- Vendor A (User 2) tham gia với tư cách Admin/CSKH của Shop
(1, 2, 'ADMIN', 2);

-- -------------------------------------------------------------------------
-- 56. Seed Chat Messages (Chi tiết tin nhắn)
-- Lưu ý: Cột created_at dùng NOW() để tự động rơi vào đúng Partition của tháng hiện tại
-- -------------------------------------------------------------------------
TRUNCATE TABLE `chat_messages`;
INSERT INTO `chat_messages` (`id`, `room_id`, `sender_id`, `content`, `type`, `attachment_url`, `is_read`, `reply_to_id`, `created_at`) VALUES
-- Tin nhắn 1: Khách VIP gửi tin nhắn văn bản
(1, 1, 4, 'Shop ơi, mình vừa đặt đơn cái iPhone. Shop gói kỹ giúp mình nhé, mình mua đi tặng sếp.', 'TEXT', NULL, 1, NULL, DATE_SUB(NOW(), INTERVAL 10 MINUTE)),

-- Tin nhắn 2: Khách VIP gửi kèm mã sản phẩm để hỏi thêm (Giả lập UI hiển thị thẻ sản phẩm)
(2, 1, 4, 'Bản Titan Tự Nhiên này đúng không shop?', 'PRODUCT', '{"product_id": 1, "variant_id": 1}', 1, NULL, DATE_SUB(NOW(), INTERVAL 9 MINUTE)),

-- Tin nhắn 3: Vendor A trả lời lại tin nhắn số 1
(3, 1, 2, 'Dạ vâng ạ, shop sẽ bọc 3 lớp chống sốc cho anh/chị yên tâm nhé.', 'TEXT', NULL, 1, 1, DATE_SUB(NOW(), INTERVAL 5 MINUTE));


-- *************************************************************************
-- [POST-SEED SCRIPT] - Cập nhật dữ liệu logic sau khi seed xong
-- *************************************************************************

-- 1. Nâng cấp 1 tài khoản bất kỳ lên làm Super Admin (Qua Email)
-- Ví dụ: Nâng cấp tài khoản Khách Hàng VIP (customer.vip@gmail.com)
UPDATE `users`
SET `role_id` = 2
WHERE `email` = 'customer.vip@gmail.com';

-- HOẶC: Hạ cấp 1 tài khoản từ Super Admin xuống Khách hàng tiêu chuẩn (Qua Số điện thoại)
-- Ví dụ: Hạ cấp tài khoản có số điện thoại 0904444444
UPDATE `users`
SET `role_id` = 1
WHERE `phone_number` = '0904444444';


-- 2. Cập nhật trạng thái Kho (ở Cụm 5 & 7)
-- Cập nhật IMEI cho Đơn 1 (Bán Online)
UPDATE `product_items`
SET `order_id` = 1, `status` = 'SOLD', `sold_date` = NOW()
WHERE `id` = 1;

-- Cập nhật IMEI cho Đơn 2 (Bán tại POS)
UPDATE `product_items`
SET `order_id` = 2, `status` = 'SOLD', `sold_date` = NOW()
WHERE `id` = 3;


-- =========================================================================
-- CLEANUP PHASE
-- =========================================================================
-- Bật lại constraints để đảm bảo tính toàn vẹn dữ liệu
SET FOREIGN_KEY_CHECKS = 1;
