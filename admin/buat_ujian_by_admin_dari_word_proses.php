<?php
require 'config.php';
session_start();

if (!isset($_SESSION['fname']) || $_SESSION['role'] != '3') {
    header('location:../login.php');
    exit;
}

// Pastikan file ada
if (!isset($_FILES['word_file']) || $_FILES['word_file']['error'] !== UPLOAD_ERR_OK) {
    die("File tidak ada atau gagal upload");
}

$filePath = $_FILES['word_file']['tmp_name'];

// Convert Word → Plain text
$txt = shell_exec("pandoc -f docx -t plain " . escapeshellarg($filePath));

// Pisah soal berdasarkan nomor
$soalArray = preg_split('/\n?\s*\d+\.\s*/', $txt);
array_shift($soalArray); // hapus elemen kosong

// Ambil input
$id_ujian       = $_POST['id_ujian'];
$durasi         = $_POST['durasi'];
$nama_bab       = $_POST['nama_bab'];
$id_subkelas    = (array)$_POST['id_subkelas'];
$user_create    = $_SESSION['uname'];
$uuidguru       = $_POST['uuidguru'];
$tanggal_ujian  = $_POST['tanggal_ujian'];
$soal_acak      = $_POST['soal_acak'];
$option_acak    = $_POST['option_acak'];
$st_susulan     = $_POST['st_susulan'];

// Ambil kode guru
$stmtGuru = $db->prepare("SELECT kode_guru FROM d_guru WHERE uuidguru = :uuid");
$stmtGuru->execute([':uuid' => $uuidguru]);
$kode_guru = $stmtGuru->fetchColumn() ?: '';

// Ambil info ujian
$stmtUjian = $db->prepare("SELECT kode_ujian, kode_mata_pelajaran FROM d_ujian WHERE id_ujian = :id");
$stmtUjian->execute([':id' => $id_ujian]);
$ujian = $stmtUjian->fetch(PDO::FETCH_ASSOC);
$kode_ujian = $ujian['kode_ujian'];
$kode_mata_pelajaran = $ujian['kode_mata_pelajaran'];

function generate_token($length = 7) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $token = '';
    for ($i=0; $i<$length; $i++) $token .= $chars[random_int(0, strlen($chars)-1)];
    return $token;
}

try {
    foreach ($id_subkelas as $subkelas) {

        // Ambil id_kelas
        $stmtKelas = $db->prepare("SELECT id_kelas FROM d_subkelas WHERE id = :sub");
        $stmtKelas->execute([':sub' => $subkelas]);
        $id_kelas = $stmtKelas->fetchColumn() ?: 0;

        // Insert Header
        $db->beginTransaction();
        $stmtHdr = $db->prepare("
            INSERT INTO f_soal_hdr
            (st_susulan, tanggal_ujian, kode_mata_pelajaran, kode_guru, uuidguru, id_kelas, kode_ujian, durasi, nama_bab, id_ujian, id_subkelas, createuser, token, soal_acak, option_acak)
            VALUES
            (:st_susulan, :tanggal_ujian, :kode_mp, :kode_guru, :uuidguru, :id_kelas, :kode_ujian, :durasi, :nama_bab, :id_ujian, :id_subkelas, :createuser, :token, :soal_acak, :option_acak)
        ");
        $stmtHdr->execute([
            ':st_susulan' => $st_susulan,
            ':tanggal_ujian' => $tanggal_ujian,
            ':kode_mp' => $kode_mata_pelajaran,
            ':kode_guru' => $kode_guru,
            ':uuidguru' => $uuidguru,
            ':id_kelas' => $id_kelas,
            ':kode_ujian' => $kode_ujian,
            ':durasi' => $durasi,
            ':nama_bab' => $nama_bab,
            ':id_ujian' => $id_ujian,
            ':id_subkelas' => $subkelas,
            ':createuser' => $user_create,
            ':token' => generate_token(),
            ':soal_acak' => $soal_acak,
            ':option_acak' => $option_acak
        ]);

        $id_ujian_hdr = $db->lastInsertId('seq_soal_hdr');

        // Hitung nilai
        $totalSoal = count($soalArray);
        $nilai = $totalSoal > 0 ? 100 / $totalSoal : 0;

        $no = 1;
        foreach ($soalArray as $block) {

            // Ambil kunci
            preg_match('/Kunci:\s*([A-E])/i', $block, $m);
            $kunci = strtoupper($m[1] ?? '');

            // Ambil opsi
            preg_match_all('/([A-E])\.\s*(.+?)(?=(?:\n[A-E]\.|$))/s', $block, $opsi);
            $option = array_fill_keys(['A','B','C','D','E'], '');
            foreach ($opsi[1] as $idx => $huruf) {
                $option[$huruf] = trim($opsi[2][$idx]);
            }

            // Isi soal sebelum opsi
            $isi = trim(preg_replace('/A\..*/s', '', $block));

            $stmtDtl = $db->prepare("
                INSERT INTO f_soal_dtl (nilai, no_soal, id_ujian_hdr, isi_soal, option_a, option_b, option_c, option_d, option_e, kunci_jawaban)
                VALUES (:nilai, :no, :hdr, :isi, :a, :b, :c, :d, :e, :kunci)
            ");

            $stmtDtl->execute([
                ':nilai' => $nilai,
                ':no' => $no++,
                ':hdr' => $id_ujian_hdr,
                ':isi' => $isi,
                ':a' => $option['A'],
                ':b' => $option['B'],
                ':c' => $option['C'],
                ':d' => $option['D'],
                ':e' => $option['E'],
                ':kunci' => $kunci
            ]);
        }

        $db->commit();
    }

    echo "<script>alert('✅ Soal berhasil disimpan!'); window.location.href='list_ujian.php';</script>";

} catch (Exception $e) {
    $db->rollBack();
    die("Error: ".$e->getMessage());
}
