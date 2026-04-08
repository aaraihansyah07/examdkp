-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 17, 2024 at 11:01 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_eval`
--

-- --------------------------------------------------------

--
-- Table structure for table `assign_ruang_kelas`
--

CREATE TABLE `assign_ruang_kelas` (
  `id` int(11) NOT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `id_mata_pelajaran` int(11) DEFAULT NULL,
  `jenis` char(1) DEFAULT NULL,
  `kode_assign` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `assign_ruang_kelas`
--

INSERT INTO `assign_ruang_kelas` (`id`, `id_kelas`, `id_mata_pelajaran`, `jenis`, `kode_assign`) VALUES
(1, 5, 2, 'D', 'diag1'),
(2, 1, 2, 'D', 'diag2'),
(3, 1, 2, 'D', 'diag3');

-- --------------------------------------------------------

--
-- Table structure for table `atmpt_list`
--

CREATE TABLE `atmpt_list` (
  `id` int(100) NOT NULL,
  `exid` int(100) NOT NULL,
  `uname` varchar(100) NOT NULL,
  `nq` int(100) NOT NULL,
  `cnq` int(100) NOT NULL,
  `ptg` int(100) NOT NULL,
  `status` int(10) NOT NULL,
  `subtime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `detail_materi_tugas`
--

CREATE TABLE `detail_materi_tugas` (
  `id` int(11) NOT NULL,
  `id_materi` int(11) DEFAULT NULL,
  `kode_materi` varchar(30) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `isi_materi` varchar(500) DEFAULT NULL,
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `seq_rubrik_asesmen` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `detail_materi_tugas`
--

INSERT INTO `detail_materi_tugas` (`id`, `id_materi`, `kode_materi`, `filename`, `isi_materi`, `exid`, `kode_assign`, `seq_rubrik_asesmen`) VALUES
(1, 1, 'mat1', NULL, 'Materi Sangat baik', NULL, 'diag1', 1),
(2, 1, 'mat1', NULL, 'Materi baik', NULL, 'diag1', 2),
(3, 1, 'mat1', NULL, 'Materi cukuo', NULL, 'diag1', 3),
(4, 1, 'mat1', NULL, 'Materi kurang', NULL, 'diag1', 4),
(5, 1, 'mat1', NULL, 'Materi sangat kurang', NULL, 'diag1', 5);

-- --------------------------------------------------------

--
-- Table structure for table `detail_soal_formatif_pbl`
--

CREATE TABLE `detail_soal_formatif_pbl` (
  `id` int(11) NOT NULL,
  `id_materi` int(11) DEFAULT NULL,
  `kode_materi` varchar(30) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `isi_materi` varchar(500) DEFAULT NULL,
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `seq_rubrik_asesmen` int(11) DEFAULT NULL,
  `jenis` char(1) DEFAULT NULL,
  `option_a` varchar(200) DEFAULT NULL,
  `option_b` varchar(200) DEFAULT NULL,
  `option_c` varchar(200) DEFAULT NULL,
  `option_d` varchar(200) DEFAULT NULL,
  `option_e` varchar(200) DEFAULT NULL,
  `kunci_jawaban` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exm_list`
--

CREATE TABLE `exm_list` (
  `exid` int(100) NOT NULL,
  `exname` varchar(100) NOT NULL,
  `nq` int(50) DEFAULT NULL,
  `desp` varchar(100) NOT NULL,
  `subt` datetime NOT NULL,
  `extime` datetime NOT NULL,
  `datetime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `subject` varchar(100) NOT NULL,
  `id_mata_pelajaran` int(11) DEFAULT NULL,
  `kelas` varchar(10) DEFAULT NULL,
  `id_guru` int(11) DEFAULT NULL,
  `status_assign` char(1) DEFAULT NULL,
  `kode_assign` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exm_list`
--

INSERT INTO `exm_list` (`exid`, `exname`, `nq`, `desp`, `subt`, `extime`, `datetime`, `subject`, `id_mata_pelajaran`, `kelas`, `id_guru`, `status_assign`, `kode_assign`) VALUES
(1, 'Algoritma Berpikir', NULL, 'Asesmen diagnostik Algoritma Berpikir', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2024-09-10 01:46:59', '', 2, '5', 19, 'Y', 'diag1'),
(2, 'Media Digital', NULL, 'Diagnostik Media Digital', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2024-09-10 02:38:58', '', 2, '1', 19, 'Y', 'diag2'),
(3, 'Jaringan Dasar', NULL, 'Jaringan Dasar', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2024-09-10 03:38:40', '', 2, '1', 19, 'N', 'diag3');

-- --------------------------------------------------------

--
-- Table structure for table `master_kelas`
--

CREATE TABLE `master_kelas` (
  `id` int(11) NOT NULL,
  `nama_kelas` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `master_kelas`
--

INSERT INTO `master_kelas` (`id`, `nama_kelas`) VALUES
(1, '10-E1'),
(2, '10-E2'),
(3, '10-E3'),
(4, '10-E4'),
(5, '10-E5'),
(6, '11-F1'),
(10, '11-F2'),
(11, '11-F3'),
(12, '11-F4'),
(13, '11-F5'),
(14, '12-F1'),
(15, '12-F2'),
(16, '12-F3'),
(17, '12-F4'),
(18, '12-F5');

-- --------------------------------------------------------

--
-- Table structure for table `master_mata_pelajaran`
--

CREATE TABLE `master_mata_pelajaran` (
  `ID` int(11) NOT NULL,
  `KODE_MATA_PELAJARAN` varchar(100) DEFAULT NULL,
  `NAMA_MATA_PELAJARAN` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `master_mata_pelajaran`
--

INSERT INTO `master_mata_pelajaran` (`ID`, `KODE_MATA_PELAJARAN`, `NAMA_MATA_PELAJARAN`) VALUES
(1, 'PEL001', 'Matematika'),
(2, 'PEL002', 'Informatika'),
(3, 'PEL003', 'Bahasa Inggris'),
(5, 'PEL004', 'Bahasa Jepang'),
(6, 'PEL005', 'Bahasa Indonesia'),
(7, 'PEL006', 'Penjas'),
(8, 'PEL007', 'BTIK'),
(9, 'PEL008', 'Biologi'),
(10, 'PEL009', 'Ekonomi');

-- --------------------------------------------------------

--
-- Table structure for table `materi_tugas`
--

CREATE TABLE `materi_tugas` (
  `id` int(11) NOT NULL,
  `jenis` char(1) DEFAULT NULL,
  `kode_materi` varchar(20) DEFAULT NULL,
  `nama_materi` varchar(70) DEFAULT NULL,
  `id_mata_pelajaran` int(11) DEFAULT NULL,
  `id_guru` int(11) DEFAULT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `date_from` datetime DEFAULT NULL,
  `date_to` datetime DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `materi_tugas`
--

INSERT INTO `materi_tugas` (`id`, `jenis`, `kode_materi`, `nama_materi`, `id_mata_pelajaran`, `id_guru`, `id_kelas`, `date_from`, `date_to`, `status`, `exid`, `kode_assign`) VALUES
(1, NULL, 'mat1', 'Algoritma Berpikir', 2, 19, 5, NULL, NULL, NULL, NULL, 'diag1');

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `id` int(11) NOT NULL,
  `fname` varchar(100) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `feedback` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `message`
--

INSERT INTO `message` (`id`, `fname`, `date`, `feedback`) VALUES
(5, 'Teacher Rosey', '2021-12-12 13:01:00', 'Please kindly complete all the homework and submit tomorrow '),
(6, 'Teacher Rosey', '2021-12-13 06:23:18', 'Hello this is an annoucement');

-- --------------------------------------------------------

--
-- Table structure for table `pengerjaan_asesmen_diagnostik`
--

CREATE TABLE `pengerjaan_asesmen_diagnostik` (
  `id` int(11) NOT NULL,
  `id_siswa` int(11) DEFAULT NULL,
  `status_pengerjaan` char(1) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `exid` int(11) DEFAULT NULL,
  `hasil_nilai` int(11) DEFAULT NULL,
  `feedback_guru` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pengerjaan_asesmen_diagnostik`
--

INSERT INTO `pengerjaan_asesmen_diagnostik` (`id`, `id_siswa`, `status_pengerjaan`, `kode_assign`, `exid`, `hasil_nilai`, `feedback_guru`) VALUES
(1, 17, 'Y', 'diag1', 1, 60, 'Sudah lumayan, mari selanjutnya belajar bersama');

-- --------------------------------------------------------

--
-- Table structure for table `pengerjaan_asesmen_diagnostik_dtl`
--

CREATE TABLE `pengerjaan_asesmen_diagnostik_dtl` (
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `no_soal` int(11) DEFAULT NULL,
  `jawaban_siswa` char(1) DEFAULT NULL,
  `kunci_jawaban` char(1) DEFAULT NULL,
  `nilai` int(11) DEFAULT NULL,
  `id_pengerjaan` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pengerjaan_asesmen_diagnostik_dtl`
--

INSERT INTO `pengerjaan_asesmen_diagnostik_dtl` (`exid`, `kode_assign`, `no_soal`, `jawaban_siswa`, `kunci_jawaban`, `nilai`, `id_pengerjaan`) VALUES
(1, 'diag1', 1, 'B', 'B', 1, 1),
(1, 'diag1', 2, 'C', 'C', 1, 1),
(1, 'diag1', 3, 'C', 'C', 1, 1),
(1, 'diag1', 4, 'C', 'C', 1, 1),
(1, 'diag1', 5, 'C', 'C', 1, 1),
(1, 'diag1', 6, 'E', 'B', 0, 1),
(1, 'diag1', 7, 'E', 'C', 0, 1),
(1, 'diag1', 8, 'E', 'A', 0, 1),
(1, 'diag1', 9, 'E', 'B', 0, 1),
(1, 'diag1', 10, 'E', 'E', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `pengerjaan_asesmen_formatif`
--

CREATE TABLE `pengerjaan_asesmen_formatif` (
  `id` int(11) NOT NULL,
  `id_siswa` int(11) DEFAULT NULL,
  `status_pengerjaan` char(1) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `exid` int(11) DEFAULT NULL,
  `hasil_nilai` int(11) DEFAULT NULL,
  `feedback_guru` varchar(500) DEFAULT NULL,
  `kode_materi` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengerjaan_asesmen_formatif_dtl`
--

CREATE TABLE `pengerjaan_asesmen_formatif_dtl` (
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `no_soal` int(11) DEFAULT NULL,
  `jawaban_siswa` char(1) DEFAULT NULL,
  `kunci_jawaban` char(1) DEFAULT NULL,
  `nilai` int(11) DEFAULT NULL,
  `id_pengerjaan` int(11) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `kode_materi` varchar(30) DEFAULT NULL,
  `jawaban_panjang` varchar(700) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pengerjaan_asesmen_formatif_dtl`
--

INSERT INTO `pengerjaan_asesmen_formatif_dtl` (`exid`, `kode_assign`, `no_soal`, `jawaban_siswa`, `kunci_jawaban`, `nilai`, `id_pengerjaan`, `filename`, `kode_materi`, `jawaban_panjang`) VALUES
(NULL, 'diag1', NULL, NULL, NULL, NULL, 1, NULL, 'for1', 'Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan Test pengerjaan');

-- --------------------------------------------------------

--
-- Table structure for table `qstn_list`
--

CREATE TABLE `qstn_list` (
  `exid` int(11) NOT NULL,
  `qid` int(11) NOT NULL,
  `qstn` varchar(200) NOT NULL,
  `qstn_o1` varchar(100) NOT NULL,
  `qstn_o2` varchar(100) NOT NULL,
  `qstn_o3` varchar(100) NOT NULL,
  `qstn_o4` varchar(100) NOT NULL,
  `qstn_ans` varchar(100) NOT NULL,
  `sno` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rubrik_asesmen`
--

CREATE TABLE `rubrik_asesmen` (
  `id` int(11) NOT NULL,
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(20) DEFAULT NULL,
  `rentang_from` int(11) DEFAULT NULL,
  `rentang_to` int(11) DEFAULT NULL,
  `kategori` varchar(30) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `status_rubrik` char(1) DEFAULT NULL,
  `nama_kategori` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `rubrik_asesmen`
--

INSERT INTO `rubrik_asesmen` (`id`, `exid`, `kode_assign`, `rentang_from`, `rentang_to`, `kategori`, `level`, `status_rubrik`, `nama_kategori`) VALUES
(1, 1, 'diag1', 90, 100, 'Sangat Baik', 1, 'Y', NULL),
(2, 1, 'diag1', 80, 89, 'Baik', 2, 'Y', NULL),
(3, 1, 'diag1', 70, 79, 'Cukup', 3, 'Y', NULL),
(4, 1, 'diag1', 60, 69, 'Kurang', 4, 'Y', NULL),
(5, 1, 'diag1', 0, 59, 'Sangat Kurang', 5, 'Y', NULL),
(11, 2, 'diag2', 90, 100, 'Sangat Paham', 1, 'Y', NULL),
(12, 2, 'diag2', 80, 89, 'Paham', 2, 'Y', NULL),
(13, 2, 'diag2', 70, 79, 'Cukup Paham', 3, 'Y', NULL),
(14, 2, 'diag2', 60, 69, 'Kurang Paham', 4, 'Y', NULL),
(15, 2, 'diag2', 0, 59, 'Sangat kurang paham', 5, 'Y', NULL),
(23, 3, 'diag3', NULL, NULL, NULL, 1, 'E', NULL),
(24, 3, 'diag3', NULL, NULL, NULL, 2, 'E', NULL),
(25, 3, 'diag3', NULL, NULL, NULL, 3, 'E', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `soal_formatif_pbl`
--

CREATE TABLE `soal_formatif_pbl` (
  `id` int(11) NOT NULL,
  `jenis` char(1) DEFAULT NULL,
  `kode_materi` varchar(20) DEFAULT NULL,
  `nama_materi` varchar(70) DEFAULT NULL,
  `id_mata_pelajaran` int(11) DEFAULT NULL,
  `id_guru` int(11) DEFAULT NULL,
  `id_kelas` int(11) DEFAULT NULL,
  `date_from` datetime DEFAULT NULL,
  `date_to` datetime DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  `exid` int(11) DEFAULT NULL,
  `kode_assign` varchar(30) DEFAULT NULL,
  `status_assign` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tmp_detail_soal_diagnostik`
--

CREATE TABLE `tmp_detail_soal_diagnostik` (
  `ID` int(11) NOT NULL,
  `NO_SOAL` int(11) DEFAULT NULL,
  `ISI_SOAL` varchar(500) DEFAULT NULL,
  `OPTION_A` varchar(200) DEFAULT NULL,
  `OPTION_B` varchar(200) DEFAULT NULL,
  `OPTION_C` varchar(200) DEFAULT NULL,
  `OPTION_D` varchar(200) DEFAULT NULL,
  `OPTION_E` varchar(200) DEFAULT NULL,
  `KUNCI_JAWABAN` char(1) DEFAULT NULL,
  `FILENAME` varchar(500) DEFAULT NULL,
  `EXID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tmp_detail_soal_diagnostik`
--

INSERT INTO `tmp_detail_soal_diagnostik` (`ID`, `NO_SOAL`, `ISI_SOAL`, `OPTION_A`, `OPTION_B`, `OPTION_C`, `OPTION_D`, `OPTION_E`, `KUNCI_JAWABAN`, `FILENAME`, `EXID`) VALUES
(1, 1, 'Algoritma sering digunakan dalam kehidupan sehari-hari. Mana yang merupakan contoh sederhana dari algoritma?', 'Menyapa teman di pagi hari', 'Urutan langkah membuat nasi goreng', 'Menulis puisi', 'Membaca novel', 'Berbicara dengan teman', 'B', '', 1),
(2, 2, 'Mengapa penting bagi algoritma untuk memiliki urutan langkah yang jelas? ', 'Agar lebih cepat selesai', 'Agar komputer dapat memahami', 'Agar tidak membingungkan', 'Agar bisa diulang-ulang', 'Agar terlihat rapi', 'C', '', 1),
(3, 3, 'Dalam algoritma, apa yang dimaksud dengan \"kondisi\"? ', 'Langkah pertama dalam algoritma', 'Perintah yang harus selalu dilakukan', 'Keputusan yang harus dibuat berdasarkan suatu keadaan', 'Penutup algoritma', 'Langkah terakhir dalam algoritma', 'C', '', 1),
(4, 4, 'Jika kamu diminta membuat algoritma untuk menentukan apakah seorang siswa lulus ujian atau tidak, apa yang harus kamu lakukan?', 'Menyusun daftar nama siswa', 'Membuat daftar soal ujian', 'Menghitung nilai siswa dan membandingkannya dengan batas kelulusan', 'Menulis hasil ujian di papan', 'Menentukan soal yang paling sulit', 'C', '', 1),
(5, 5, 'Apa yang dimaksud dengan \"iterasi\" dalam algoritma? ', 'Memulai algoritma dari awal', 'Menjalankan algoritma satu kali', 'Mengulang langkah tertentu dalam algoritma', 'Mengakhiri algoritma', 'Melompati langkah dalam algoritma', 'C', '', 1),
(6, 6, 'Algoritma harus efisien. Apa artinya \"efisien\" dalam konteks ini?', 'Menggunakan sebanyak mungkin langkah', 'Menggunakan sesedikit mungkin langkah', 'Menggunakan langkah-langkah yang mudah dipahami', 'Menggunakan bahasa yang formal', 'Menggunakan instruksi yang rumit', 'B', '', 1),
(7, 7, 'Bagaimana kamu bisa mengecek apakah algoritma yang kamu buat sudah benar?', 'Menanyakan kepada teman', 'Membaca ulang langkah-langkahnya', 'Mencobanya dengan data atau situasi nyata', 'Mengubah urutan langkahnya', 'Membuat algoritma baru', 'C', '', 1),
(8, 8, 'Contoh mana yang merupakan algoritma dalam kehidupan nyata?', 'Urutan langkah mencuci tangan', 'Mendengarkan musik', 'Menggambar pemandangan', 'Membaca cerita', 'Berlari di lapangan', 'A', '', 1),
(9, 9, 'Dalam algoritma, apa fungsi dari simbol \"panah\" pada diagram alir (flowchart)?', 'Menandakan dimulainya algoritma', 'Menunjukkan hubungan antar langkah', 'Menyelesaikan algoritma', 'Menghentikan algoritma', 'Menambahkan langkah baru', 'B', '', 1),
(10, 10, 'Algoritma sering digunakan dalam pemrograman. Apa tujuan utama dari algoritma dalam pemrograman?', 'Untuk membuat program lebih rumit', 'Untuk mempermudah penulisan kode', 'Untuk menghibur pengguna', 'Untuk membuat program terlihat menarik', 'Untuk memastikan program berjalan dengan benar', 'E', '', 1),
(11, 1, 'Soal 1', 'Benar', 'Salah', 'Salah', 'Salah', 'Salah', 'A', 'WhatsApp Image 2024-09-03 at 00.24.39.jpeg', 2),
(12, 2, 'Soal 2', 'Salah', 'Benar', 'Salah', 'Salah', 'Salah', 'B', '', 2),
(13, 3, 'Soal 3', 'Salah', 'Salah', 'Benar', 'Salah', 'Salah', 'C', '', 2),
(14, 4, 'Soal 4', 'Salah', 'Salah', 'Salah', 'Benar', 'Salah', 'D', '', 2),
(15, 5, 'Soal 5', 'Salah', 'Salah', 'Salah', 'Salah', 'Benar', 'E', '', 2),
(16, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `uname` varchar(100) NOT NULL,
  `pword` varchar(255) NOT NULL,
  `fname` char(100) NOT NULL,
  `dob` date NOT NULL,
  `gender` char(10) NOT NULL,
  `email` varchar(100) NOT NULL,
  `kelas` int(11) DEFAULT NULL,
  `subject` int(11) DEFAULT NULL,
  `role` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `uname`, `pword`, `fname`, `dob`, `gender`, `email`, `kelas`, `subject`, `role`) VALUES
(17, 'razane', '1234', 'Razane Haidouf Hakikue', '1998-08-11', 'F', '', 5, NULL, 'siswa'),
(18, 'gokuyo', '1234', 'Son Goku', '2000-08-18', 'M', '', 1, NULL, 'siswa'),
(19, 'raihan', '1234', 'Raihansyah', '0000-00-00', 'M', 'rhnsyh@gg.com', NULL, 2, 'guru'),
(20, 'admin', 'admin', 'Admin', '0000-00-00', 'M', 'admin@test.com', NULL, NULL, 'admin'),
(21, 'ripai', '1234', 'Ahmad Ripai', '0000-00-00', '', '', NULL, 1, 'guru'),
(22, 'ronaldo', '1234s', 'Ronaldo Sanchez Dos Gandos', '2000-08-24', 'M', '', 5, NULL, 'siswa'),
(23, 'chocou', '1234', 'Chourouk', '0000-00-00', '', '', NULL, NULL, 'admin'),
(24, 'anbar', '1234', 'Anbarsari Nirwana Putri', '2004-08-24', 'F', '', 5, NULL, 'siswa'),
(25, 'yudho', '1234', 'Yudhoyono', '0000-00-00', '', '', NULL, 5, 'guru'),
(26, 'davie', '1234', 'Davie Nida', '2024-09-02', 'M', '', 1, NULL, 'siswa'),
(27, 'rafi', '1234', 'Rafi', '0000-00-00', '', '', NULL, 1, 'guru'),
(28, 'vinda', '1234', 'Vinda', '0000-00-00', '', '', NULL, NULL, 'admin'),
(29, 'vinda12', '1234', 'Vinda Lestari', '2000-09-04', 'F', '', 5, NULL, 'siswa'),
(30, 'tasya', '1234', 'tasya', '0000-00-00', '', '', NULL, 5, 'guru'),
(31, 'grecellas', 'Kookie07', 'Grecella Sebayang', '0000-00-00', '', '', NULL, 2, 'guru'),
(32, 'rizal', '1234', 'rizal', '0000-00-00', '', '', NULL, 9, 'guru');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assign_ruang_kelas`
--
ALTER TABLE `assign_ruang_kelas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `atmpt_list`
--
ALTER TABLE `atmpt_list`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `detail_materi_tugas`
--
ALTER TABLE `detail_materi_tugas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `detail_soal_formatif_pbl`
--
ALTER TABLE `detail_soal_formatif_pbl`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exm_list`
--
ALTER TABLE `exm_list`
  ADD PRIMARY KEY (`exid`);

--
-- Indexes for table `master_kelas`
--
ALTER TABLE `master_kelas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `master_mata_pelajaran`
--
ALTER TABLE `master_mata_pelajaran`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `materi_tugas`
--
ALTER TABLE `materi_tugas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pengerjaan_asesmen_diagnostik`
--
ALTER TABLE `pengerjaan_asesmen_diagnostik`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pengerjaan_asesmen_formatif`
--
ALTER TABLE `pengerjaan_asesmen_formatif`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `qstn_list`
--
ALTER TABLE `qstn_list`
  ADD PRIMARY KEY (`qid`);

--
-- Indexes for table `rubrik_asesmen`
--
ALTER TABLE `rubrik_asesmen`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `soal_formatif_pbl`
--
ALTER TABLE `soal_formatif_pbl`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tmp_detail_soal_diagnostik`
--
ALTER TABLE `tmp_detail_soal_diagnostik`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assign_ruang_kelas`
--
ALTER TABLE `assign_ruang_kelas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `atmpt_list`
--
ALTER TABLE `atmpt_list`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `detail_materi_tugas`
--
ALTER TABLE `detail_materi_tugas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `detail_soal_formatif_pbl`
--
ALTER TABLE `detail_soal_formatif_pbl`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exm_list`
--
ALTER TABLE `exm_list`
  MODIFY `exid` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `master_kelas`
--
ALTER TABLE `master_kelas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `master_mata_pelajaran`
--
ALTER TABLE `master_mata_pelajaran`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `materi_tugas`
--
ALTER TABLE `materi_tugas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `pengerjaan_asesmen_diagnostik`
--
ALTER TABLE `pengerjaan_asesmen_diagnostik`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pengerjaan_asesmen_formatif`
--
ALTER TABLE `pengerjaan_asesmen_formatif`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `qstn_list`
--
ALTER TABLE `qstn_list`
  MODIFY `qid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `rubrik_asesmen`
--
ALTER TABLE `rubrik_asesmen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `soal_formatif_pbl`
--
ALTER TABLE `soal_formatif_pbl`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tmp_detail_soal_diagnostik`
--
ALTER TABLE `tmp_detail_soal_diagnostik`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
