-- Railway DB schema snapshot (2026-04-27T06:40:45.252Z)
-- Tables: 15

-- TABLE LIST:
--   absensi
--   finance_lembur_tambahan
--   karyawan
--   lembur
--   log_distribusi_slip
--   omzet_bulanan
--   otp_codes
--   payroll
--   payroll_employee_input
--   payroll_period_config
--   pinjaman
--   pinjaman_cicilan
--   potongan_kontrak
--   slip_gaji
--   users

-- ============================================
CREATE TABLE `absensi` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint unsigned NOT NULL,
  `tanggal` date NOT NULL,
  `jam_masuk` datetime DEFAULT NULL,
  `jam_pulang` datetime DEFAULT NULL,
  `status_absensi` enum('hadir','sakit','izin','libur','setengah_hari','alfa') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'hadir',
  `kode_absensi` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foto_masuk` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foto_pulang` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude_masuk` decimal(10,7) DEFAULT NULL,
  `longitude_masuk` decimal(10,7) DEFAULT NULL,
  `latitude_pulang` decimal(10,7) DEFAULT NULL,
  `longitude_pulang` decimal(10,7) DEFAULT NULL,
  `terlambat_menit` int unsigned NOT NULL DEFAULT '0',
  `setengah_hari` tinyint(1) NOT NULL DEFAULT '0',
  `lembur_jam` decimal(6,2) NOT NULL DEFAULT '0.00',
  `keterangan` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_absensi_karyawan_tanggal` (`karyawan_id`,`tanggal`),
  KEY `idx_absensi_tanggal` (`tanggal`),
  KEY `idx_absensi_status` (`status_absensi`),
  KEY `idx_absensi_kode` (`kode_absensi`),
  CONSTRAINT `fk_absensi_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 27

-- ============================================
CREATE TABLE `finance_lembur_tambahan` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `periode_bulan` tinyint unsigned NOT NULL,
  `periode_tahun` smallint unsigned NOT NULL,
  `unit` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nominal` decimal(14,2) NOT NULL DEFAULT '0.00',
  `catatan` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_finance_lembur_unit` (`periode_bulan`,`periode_tahun`,`unit`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 0

-- ============================================
CREATE TABLE `karyawan` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `no_karyawan` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nama` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jabatan` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `departemen` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `divisi` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sub_divisi` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `penempatan` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pembagian_rekapan` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pembebanan` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bank` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'BCA',
  `no_rekening` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jenis_kelamin` enum('laki-laki','perempuan') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tempat_lahir` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `nik` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agama` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alamat_ktp` text COLLATE utf8mb4_unicode_ci,
  `alamat_rumah_kost` text COLLATE utf8mb4_unicode_ci,
  `nomor_telepon` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foto_ktp` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_kepegawaian` enum('training','kontrak','tetap','freelance','magang','resign') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'kontrak',
  `status_kerja` enum('training','kontrak','tetap','freelance','magang','resign') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'kontrak',
  `status_data` enum('aktif','nonaktif') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `tanggal_masuk_pertama` date DEFAULT NULL,
  `tanggal_kontrak` date DEFAULT NULL,
  `tanggal_selesai_kontrak` date DEFAULT NULL,
  `kenaikan_tiap_tahun` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_karyawan_user_id` (`user_id`),
  UNIQUE KEY `uq_karyawan_no_karyawan` (`no_karyawan`),
  UNIQUE KEY `uq_karyawan_nik` (`nik`),
  KEY `idx_karyawan_nama` (`nama`),
  KEY `idx_karyawan_unit` (`unit`),
  KEY `idx_karyawan_departemen` (`departemen`),
  KEY `idx_karyawan_divisi` (`divisi`),
  KEY `idx_karyawan_status_kepegawaian` (`status_kepegawaian`),
  KEY `idx_karyawan_status_kerja` (`status_kerja`),
  KEY `idx_karyawan_status_data` (`status_data`),
  CONSTRAINT `fk_karyawan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 11

-- ============================================
CREATE TABLE `lembur` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint unsigned NOT NULL,
  `tanggal` date NOT NULL,
  `jam_mulai` datetime NOT NULL,
  `jam_selesai` datetime NOT NULL,
  `total_jam` decimal(6,2) NOT NULL DEFAULT '0.00',
  `bukti_lembur` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_approval` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint unsigned DEFAULT NULL,
  `catatan_atasan` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lembur_karyawan_tanggal` (`karyawan_id`,`tanggal`),
  KEY `idx_lembur_status_approval` (`status_approval`),
  KEY `idx_lembur_approved_by` (`approved_by`),
  CONSTRAINT `fk_lembur_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_lembur_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 4

-- ============================================
CREATE TABLE `log_distribusi_slip` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slip_gaji_id` bigint unsigned NOT NULL,
  `karyawan_id` bigint unsigned NOT NULL,
  `didistribusikan_oleh` bigint unsigned NOT NULL,
  `tanggal_distribusi` datetime NOT NULL,
  `status_baca` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_log_distribusi_slip` (`slip_gaji_id`),
  KEY `idx_log_distribusi_karyawan` (`karyawan_id`),
  KEY `idx_log_distribusi_admin` (`didistribusikan_oleh`),
  CONSTRAINT `fk_log_distribusi_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_log_distribusi_slip` FOREIGN KEY (`slip_gaji_id`) REFERENCES `slip_gaji` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_log_distribusi_user` FOREIGN KEY (`didistribusikan_oleh`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 0

-- ============================================
CREATE TABLE `omzet_bulanan` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `periode_bulan` tinyint unsigned NOT NULL,
  `periode_tahun` smallint unsigned NOT NULL,
  `unit` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `total_omzet` decimal(14,2) NOT NULL DEFAULT '0.00',
  `is_custom_bonus` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_omzet_bulanan_periode_unit` (`periode_bulan`,`periode_tahun`,`unit`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 3

-- ============================================
CREATE TABLE `otp_codes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_otp_email_code` (`email`,`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 3

-- ============================================
CREATE TABLE `payroll` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint unsigned NOT NULL,
  `periode_bulan` tinyint unsigned NOT NULL,
  `periode_tahun` smallint unsigned NOT NULL,
  `hari_kerja` int unsigned NOT NULL DEFAULT '0',
  `total_masuk` int unsigned NOT NULL DEFAULT '0',
  `total_lembur_jam` decimal(8,2) NOT NULL DEFAULT '0.00',
  `total_terlambat` int unsigned NOT NULL DEFAULT '0',
  `total_setengah_hari` int unsigned NOT NULL DEFAULT '0',
  `gaji_pokok` decimal(14,2) NOT NULL DEFAULT '0.00',
  `tunjangan_jabatan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `tunjangan_lain` decimal(14,2) NOT NULL DEFAULT '0.00',
  `bonus_performa` decimal(14,2) NOT NULL DEFAULT '0.00',
  `bpjs` decimal(14,2) NOT NULL DEFAULT '0.00',
  `uang_makan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `transport` decimal(14,2) NOT NULL DEFAULT '0.00',
  `insentif` decimal(14,2) NOT NULL DEFAULT '0.00',
  `upah_lembur` decimal(14,2) NOT NULL DEFAULT '0.00',
  `potongan_keterlambatan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `potongan_setengah_hari` decimal(14,2) NOT NULL DEFAULT '0.00',
  `potongan_kontrak` decimal(14,2) NOT NULL DEFAULT '0.00',
  `potongan_pinjaman` decimal(14,2) NOT NULL DEFAULT '0.00',
  `potongan_kerajinan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_potongan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `gaji_bersih` decimal(14,2) NOT NULL DEFAULT '0.00',
  `status_payroll` enum('draft','processed','approved_finance','paid') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payroll_periode` (`karyawan_id`,`periode_bulan`,`periode_tahun`),
  KEY `idx_payroll_periode` (`periode_tahun`,`periode_bulan`),
  KEY `idx_payroll_status` (`status_payroll`),
  CONSTRAINT `fk_payroll_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- rows: 11

-- ============================================
CREATE TABLE `payroll_employee_input` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `payroll_id` bigint unsigned NOT NULL,
  `karyawan_id` bigint unsigned NOT NULL,
  `payroll_type` enum('non_sales','sales') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'non_sales',
  `gaji_pokok_per_hari` decimal(14,2) NOT NULL DEFAULT '0.00',
  `uang_makan_per_hari` decimal(14,2) NOT NULL DEFAULT '0.00',
  `subsidi` decimal(14,2) NOT NULL DEFAULT '0.00',
  `uang_kerajinan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `bpjs` decimal(14,2) NOT NULL DEFAULT '0.00',
  `bonus_performa` decimal(14,2) NOT NULL DEFAULT '0.00',
  `insentif` decimal(14,2) NOT NULL DEFAULT '0.00',
  `uang_transport` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `override_masuk` int DEFAULT NULL,
  `override_lembur` decimal(14,2) DEFAULT NULL,
  `override_izin` int DEFAULT NULL,
  `override_sakit` int DEFAULT NULL,
  `override_sakit_tanpa_surat` int DEFAULT NULL,
  `override_setengah_hari` int DEFAULT NULL,
  `override_kontrak` decimal(14,2) DEFAULT NULL,
  `override_pinjaman` decimal(14,2) DEFAULT NULL,
  `override_pinjaman_pribadi` decimal(14,2) DEFAULT NULL,
  `override_gaji_pokok` decimal(14,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payroll_employee_input_payroll` (`payroll_id`),
  KEY `idx_payroll_employee_input_karyawan` (`karyawan_id`),
  CONSTRAINT `fk_payroll_employee_input_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_payroll_employee_input_payroll` FOREIGN KEY (`payroll_id`) REFERENCES `payroll` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 11

-- ============================================
CREATE TABLE `payroll_period_config` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `periode_bulan` tinyint unsigned NOT NULL,
  `periode_tahun` smallint unsigned NOT NULL,
  `total_omzet` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payroll_period_config` (`periode_bulan`,`periode_tahun`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 1

-- ============================================
CREATE TABLE `pinjaman` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint unsigned NOT NULL,
  `jumlah_pinjaman` decimal(14,2) NOT NULL,
  `jumlah_angsuran` int unsigned NOT NULL DEFAULT '1',
  `angsuran_per_bulan` decimal(14,2) NOT NULL,
  `total_sudah_bayar` decimal(14,2) NOT NULL DEFAULT '0.00',
  `sisa_pinjaman` decimal(14,2) NOT NULL,
  `tanggal_pengajuan` date NOT NULL,
  `tanggal_approval` date DEFAULT NULL,
  `approved_by` bigint unsigned DEFAULT NULL,
  `status_pinjaman` enum('pending','approved','berjalan','lunas','rejected','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pinjaman_karyawan` (`karyawan_id`),
  KEY `idx_pinjaman_status` (`status_pinjaman`),
  KEY `idx_pinjaman_tanggal` (`tanggal_pengajuan`),
  CONSTRAINT `fk_pinjaman_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 3

-- ============================================
CREATE TABLE `pinjaman_cicilan` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `pinjaman_id` bigint unsigned NOT NULL,
  `urutan_cicilan` int unsigned NOT NULL,
  `bulan` tinyint unsigned NOT NULL,
  `tahun` smallint unsigned NOT NULL,
  `nominal_potongan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `nominal_terpotong` decimal(14,2) DEFAULT NULL,
  `payroll_id` bigint unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pinjaman_cicilan_periode` (`pinjaman_id`,`bulan`,`tahun`),
  UNIQUE KEY `uq_pinjaman_cicilan_urutan` (`pinjaman_id`,`urutan_cicilan`),
  KEY `idx_pinjaman_cicilan_periode` (`tahun`,`bulan`),
  KEY `idx_pinjaman_cicilan_payroll` (`payroll_id`),
  CONSTRAINT `fk_pinjaman_cicilan_pinjaman` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 2

-- ============================================
CREATE TABLE `potongan_kontrak` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `karyawan_id` bigint unsigned NOT NULL,
  `bulan` tinyint unsigned NOT NULL,
  `tahun` smallint unsigned NOT NULL,
  `nominal_potongan` decimal(14,2) NOT NULL DEFAULT '0.00',
  `keterangan` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_potongan_kontrak_periode` (`karyawan_id`,`bulan`,`tahun`),
  KEY `idx_potongan_kontrak_periode` (`tahun`,`bulan`),
  CONSTRAINT `fk_potongan_kontrak_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- rows: 55

-- ============================================
CREATE TABLE `slip_gaji` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `payroll_id` bigint unsigned NOT NULL,
  `nomor_slip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tanggal_distribusi` datetime DEFAULT NULL,
  `status_distribusi` enum('draft','didistribusikan','dibaca') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `file_slip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_slip_gaji_payroll_id` (`payroll_id`),
  UNIQUE KEY `uq_slip_gaji_nomor_slip` (`nomor_slip`),
  KEY `idx_slip_gaji_status` (`status_distribusi`),
  CONSTRAINT `fk_slip_gaji_payroll` FOREIGN KEY (`payroll_id`) REFERENCES `payroll` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 0

-- ============================================
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','karyawan') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_aktif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_role_status` (`role`,`status_aktif`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rows: 14

