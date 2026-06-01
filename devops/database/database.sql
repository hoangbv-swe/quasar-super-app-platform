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
-- [TODO] Chèn các câu lệnh DDL để tạo bảng, index, constraints ở đây.


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
