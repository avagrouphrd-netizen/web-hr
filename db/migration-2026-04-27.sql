-- =============================================================
-- Migration: 2026-04-27
-- Source:    db/hris_payroll_app_v2.sql (local) vs Railway snapshot
-- Target:    Railway MySQL (database `railway`)
-- Idempotent: safe to re-run; uses IF NOT EXISTS for tables.
-- Column adds use a guarded approach via INFORMATION_SCHEMA.
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------------------------------------------
-- 1. NEW TABLES
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `jadwal_karyawan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `karyawan_id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `shift` enum('pagi','lembur','siang','setengah_1','setengah_2','libur') NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_karyawan_tanggal` (`karyawan_id`,`tanggal`),
  KEY `idx_tanggal` (`tanggal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `laporan_kunjungan` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint(20) UNSIGNED NOT NULL,
  `tanggal` date NOT NULL,
  `waktu_submit` datetime NOT NULL,
  `nama_toko` varchar(255) NOT NULL,
  `foto_path` varchar(500) NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_laporan_kunjungan_karyawan_tanggal` (`karyawan_id`,`tanggal`),
  KEY `idx_laporan_kunjungan_tanggal` (`tanggal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payroll_bonus` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint(20) UNSIGNED NOT NULL,
  `periode_bulan` tinyint(3) UNSIGNED NOT NULL,
  `periode_tahun` smallint(5) UNSIGNED NOT NULL,
  `bonus_type` enum('sales','spv','manager','cs','host_live') NOT NULL,
  `nominal_bonus` decimal(14,2) NOT NULL DEFAULT 0.00,
  `catatan` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payroll_bonus_employee_period` (`karyawan_id`,`periode_bulan`,`periode_tahun`),
  KEY `idx_payroll_bonus_period` (`periode_tahun`,`periode_bulan`),
  CONSTRAINT `fk_payroll_bonus_employee` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `perjalanan_dinas` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint(20) UNSIGNED NOT NULL,
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date NOT NULL,
  `surat_path` varchar(500) NOT NULL,
  `catatan` text DEFAULT NULL,
  `status_approval` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `catatan_admin` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_perjalanan_dinas_karyawan` (`karyawan_id`),
  KEY `idx_perjalanan_dinas_status` (`status_approval`),
  KEY `idx_perjalanan_dinas_tanggal` (`tanggal_mulai`,`tanggal_selesai`),
  CONSTRAINT `fk_perjalanan_dinas_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `reimbursements` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint(20) UNSIGNED NOT NULL,
  `tanggal_pengajuan` date NOT NULL,
  `tanggal_biaya` date NOT NULL,
  `kategori` varchar(100) NOT NULL DEFAULT 'Perjalanan Dinas',
  `keterangan` text DEFAULT NULL,
  `nominal` decimal(14,2) NOT NULL DEFAULT 0.00,
  `nota_path` varchar(500) NOT NULL,
  `status_approval` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `catatan_admin` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_reimbursements_karyawan` (`karyawan_id`),
  KEY `idx_reimbursements_status` (`status_approval`),
  KEY `idx_reimbursements_tanggal_biaya` (`tanggal_biaya`),
  CONSTRAINT `fk_reimbursements_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 2. EXISTING TABLES — ADD COLUMNS (guarded so re-runnable)
-- -------------------------------------------------------------

-- karyawan.tipe_payroll_penjahit
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'karyawan' AND COLUMN_NAME = 'tipe_payroll_penjahit'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `karyawan` ADD COLUMN `tipe_payroll_penjahit` enum(''mingguan'',''bulanan'') DEFAULT NULL AFTER `jabatan`',
  'SELECT ''column karyawan.tipe_payroll_penjahit already exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- karyawan.penempatan_extra
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'karyawan' AND COLUMN_NAME = 'penempatan_extra'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `karyawan` ADD COLUMN `penempatan_extra` varchar(500) DEFAULT NULL AFTER `penempatan`',
  'SELECT ''column karyawan.penempatan_extra already exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- payroll_employee_input.kendaraan
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payroll_employee_input' AND COLUMN_NAME = 'kendaraan'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `payroll_employee_input` ADD COLUMN `kendaraan` decimal(14,2) NOT NULL DEFAULT 0.00 AFTER `uang_transport`',
  'SELECT ''column payroll_employee_input.kendaraan already exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- payroll_employee_input.perjalanan_dinas_reimburse
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payroll_employee_input' AND COLUMN_NAME = 'perjalanan_dinas_reimburse'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `payroll_employee_input` ADD COLUMN `perjalanan_dinas_reimburse` decimal(14,2) NOT NULL DEFAULT 0.00 AFTER `kendaraan`',
  'SELECT ''column payroll_employee_input.perjalanan_dinas_reimburse already exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- -------------------------------------------------------------
-- 3. EXTEND ENUM users.role to include 'spv'
-- -------------------------------------------------------------
ALTER TABLE `users`
  MODIFY COLUMN `role` enum('admin','karyawan','spv') NOT NULL DEFAULT 'karyawan';
