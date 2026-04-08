<?php
session_start();
if ($_SESSION['fname'] == null or $_SESSION['role'] <> '1') {
    header('location:../login.php');
}
require 'config.php';

$mp = $_POST['mp'];
$kls = $_POST['kls'];
$ju = $_POST['ju'];

$id_ujian_hdr = $_POST['id_ujian_hdr'];
$id_ujian = $_POST['id_ujian'];
$durasi = $_POST['durasi'];
// $waktu_mulai = $_POST['waktu_mulai'];
// $waktu_berakhir = $_POST['waktu_berakhir'];
$nama_bab = $_POST['nama_bab'];
$uuidguru = $_POST['uuidguru'];
$id_subkelas = $_POST['id_subkelas'];
$user_update = $_SESSION['uname'];
$tanggal_ujian = $_POST['tanggal_ujian'];
$soal_acak = $_POST['soal_acak'];
$option_acak = $_POST['option_acak'];
date_default_timezone_set("Asia/Jakarta");
$now = date("Y-m-d H:i:s");
$st_susulan = $_POST['st_susulan'];

$sqlz = "SELECT kode_ujian from d_ujian where id_ujian = $id_ujian";
$hasilz = $db->query($sqlz);
$barisz = $hasilz->fetch(PDO::FETCH_ASSOC);
$kode_ujian = $barisz['kode_ujian'];

$sqlx = "SELECT kode_guru from d_guru where uuidguru = '$uuidguru'";
$hasilx = $db->query($sqlx);
$barisx = $hasilx->fetch(PDO::FETCH_ASSOC);
$kode_guru = $barisx['kode_guru'];

// Update Header
$stmt = $db->prepare("
    UPDATE f_soal_hdr SET
        st_susulan = :st_susulan,
        id_ujian = :id_ujian,
        kode_ujian = :kode_ujian,
        durasi = :durasi,
        nama_bab = :nama_bab,
        uuidguru = :uuidguru,
        kode_guru = :kode_guru,
        updatedate = :now,
        id_subkelas = :id_subkelas,
        updateuser = :user_update,
        tanggal_ujian = :tanggal_ujian,
        soal_acak = :soal_acak,
        option_acak = :option_acak
    WHERE id_ujian_hdr = :id_ujian_hdr
");
$stmt->execute([
    ':st_susulan' => $st_susulan,
    ':id_ujian' => $id_ujian,
    ':kode_ujian' => $kode_ujian,
    ':durasi' => $durasi,
    ':nama_bab' => $nama_bab,
    ':uuidguru' => $uuidguru,
    ':kode_guru' => $kode_guru,
    ':now' => $now,
    ':id_subkelas' => $id_subkelas,
    ':user_update' => $user_update,
    ':id_ujian_hdr' => $id_ujian_hdr,
    ':tanggal_ujian' => $tanggal_ujian,
    ':soal_acak' => $soal_acak,
    ':option_acak' => $option_acak,
]);

$uploadDir = '../uploads/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$soalList = $_POST['soal'];
$urutSoal = 1;
$warning = [];

// Validasi isian kosong (jika tidak dihapus)
function isQuillEmptyCheck($html) {
    // hapus semua tag HTML dan whitespace
    return trim(strip_tags($html)) === '';
}

function unicodeMathToLatex($text) {
    if (!$text) return '';

    // 1️⃣ Lindungi <br> dulu dengan placeholder
    //$placeholder = '___BR___';
    //$text = str_ireplace(['<br>', '<br/>'], $placeholder, $text);

    // 2️⃣ Minus Unicode → minus biasa
    $text = str_replace('−', '-', $text);

    // 3️⃣ Panah Unicode → \to
    $text = str_replace('→', '\\to', $text);

    // 4️⃣ Huruf Math Unicode → ASCII
    $unicodeMap = [
        '𝑎'=>'a','𝑏'=>'b','𝑐'=>'c','𝑑'=>'d','𝑒'=>'e','𝑓'=>'f','𝑔'=>'g','𝑖'=>'i','𝑗'=>'j',
        '𝑘'=>'k','𝑙'=>'l','𝑚'=>'m','𝑛'=>'n','𝑜'=>'o','𝑝'=>'p','𝑞'=>'q','𝑟'=>'r','𝑠'=>'s',
        '𝑡'=>'t','𝑢'=>'u','𝑣'=>'v','𝑤'=>'w','𝑥'=>'x','𝑦'=>'y','𝑧'=>'z',
        '𝐴'=>'A','𝐵'=>'B','𝐶'=>'C','𝐷'=>'D','𝐸'=>'E','𝐹'=>'F','𝐺'=>'G','𝐻'=>'H','𝐼'=>'I',
        '𝐽'=>'J','𝐾'=>'K','𝐿'=>'L','𝑀'=>'M','𝑁'=>'N','𝑂'=>'O','𝑃'=>'P','𝑄'=>'Q','𝑅'=>'R',
        '𝑆'=>'S','𝑇'=>'T','𝑈'=>'U','𝑉'=>'V','𝑊'=>'W','𝑋'=>'X','𝑌'=>'Y','𝑍'=>'Z'
    ];
    $text = strtr($text, $unicodeMap);

    // 5️⃣ Akar √(...) atau √x → \sqrt{...}
    $text = preg_replace_callback('/√(\((.*?)\)|[a-zA-Z0-9]+)/u', function($matches) {
        return '\\sqrt{' . (isset($matches[2]) && $matches[2] != '' ? $matches[2] : $matches[1]) . '}';
    }, $text);

    // 6️⃣ Pecahan (a)/(b) → \frac{a}{b}
    $text = preg_replace_callback('/\(([^()]+)\)\/\(([^()]+)\)/', function($matches) {
        return '\\frac{' . $matches[1] . '}{' . $matches[2] . '}';
    }, $text);

    // 7️⃣ Limit lim(x→...) → \lim_{x \to ...}
    $text = preg_replace_callback('/(?:\(?lim\)?)[⁡┬]*\(?([a-zA-Z0-9]+)\\\\to([a-zA-Z0-9]+)\)?/i', function($matches) {
        return '\\lim_{' . trim($matches[1]) . ' \\to ' . trim($matches[2]) . '}';
    }, $text);

    // 8️⃣ Hapus karakter sisa Excel
    $text = str_replace(['⁡','〖','〗','┬','(',')'], '', $text);

    // 9️⃣ Ganti placeholder <br> dengan newline LaTeX
    // $text = str_ireplace($placeholder, ' \\\\ ', $text);

    // 🔟 Jika ada \\ → wrap dengan display math $$
    // if (strpos($text, '\\\\') !== false) {
    //     $text = '$$' . $text . '$$';
    // }

    return trim($text);
}

foreach ($soalList as $index => $soal) {
    $seq_soal_dtl = $soal['seq_soal_dtl'];
    $option_a_unicode = $soal['option_a'];
    $option_b_unicode = $soal['option_b'];
    $option_c_unicode = $soal['option_c'];
    $option_d_unicode = $soal['option_d'];
    $option_e_unicode = $soal['option_e'];
    $isi_soal_unicode = $soal['isi_soal'];
    $option_a = unicodeMathToLatex($soal['option_a']);
    $option_b = unicodeMathToLatex($soal['option_b']);
    $option_c = unicodeMathToLatex($soal['option_c']);
    $option_d = unicodeMathToLatex($soal['option_d']);
    $option_e = unicodeMathToLatex($soal['option_e']);
    $isi_soal = unicodeMathToLatex($soal['isi_soal']);
    $kunci_jawaban = $soal['kunci_jawaban'];
    $hapus_soal = $soal['hapus_soal'];
    $hapus_gambar = $soal['hapus_gambar'];
    $gambar_soal_filename = $soal['gambar_soal_filename'];

    // Jika soal dihapus, langsung proses hapus (skip validasi dan skip urutSoal)
    if (!empty($seq_soal_dtl) && $hapus_soal == 1) {
        $stmtDel = $db->prepare("SELECT gambar_soal_filename FROM f_soal_dtl WHERE seq_soal_dtl = :id AND id_ujian_hdr = :hdr");
        $stmtDel->execute([':id' => $seq_soal_dtl, ':hdr' => $id_ujian_hdr]);
        $row = $stmtDel->fetch(PDO::FETCH_ASSOC);

        if ($row && !empty($row['gambar_soal_filename'])) {
            $gambar = $row['gambar_soal_filename'];

            $stmtCek = $db->prepare("SELECT COUNT(*) as jml FROM f_soal_dtl WHERE gambar_soal_filename = :gambar");
            $stmtCek->execute([':gambar' => $gambar]);
            $cek = $stmtCek->fetch(PDO::FETCH_ASSOC);

            if ($cek['jml'] == 1) {
                if (file_exists($uploadDir . $gambar)) {
                    unlink($uploadDir . $gambar);
                }
            }
        }

        $stmt = $db->prepare("DELETE FROM f_soal_dtl WHERE seq_soal_dtl = :id AND id_ujian_hdr = :hdr");
        $stmt->execute([':id' => $seq_soal_dtl, ':hdr' => $id_ujian_hdr]);

        // Lewati soal yang dihapus, tidak renumbering dan tidak lanjut ke bawah
        continue;
    }

    // Handle gambar baru
    $gambarBaru = null;
    if (isset($_FILES['soal']['name'][$index]['gambar']) && $_FILES['soal']['name'][$index]['gambar'] != '') {
        $fileSize = $_FILES['soal']['size'][$index]['gambar'];
        if ($fileSize > 1024 * 1024) {
            echo "<script>alert('Ukuran gambar soal ke-".($index+1)." melebihi 1MB!'); window.location.href='daftar_ujian_saya_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."'';</script>";
            exit;
        }

        $gambarTmp = $_FILES['soal']['tmp_name'][$index]['gambar'];
        $originalName = $_FILES['soal']['name'][$index]['gambar'];
        $ext = pathinfo($originalName, PATHINFO_EXTENSION);
        $newName = uniqid('soal_') . '.' . $ext;

        move_uploaded_file($gambarTmp, $uploadDir . $newName);
        $gambarBaru = $newName;

        if (!empty($gambar_soal_filename) && file_exists($uploadDir . $gambar_soal_filename)) {
            unlink($uploadDir . $gambar_soal_filename);
        }
    } elseif ($hapus_gambar == 1) {
        if (!empty($gambar_soal_filename) && file_exists($uploadDir . $gambar_soal_filename)) {
            unlink($uploadDir . $gambar_soal_filename);
        }
        $gambar_soal_filename = null;
    }

    $soalKosong = [];

    if (isQuillEmptyCheck($isi_soal)) $soalKosong[] = "Isi Soal";
    if (isQuillEmptyCheck($option_a)) $soalKosong[] = "Option A";
    if (isQuillEmptyCheck($option_b)) $soalKosong[] = "Option B";
    if (isQuillEmptyCheck($option_c)) $soalKosong[] = "Option C";
    if (isQuillEmptyCheck($option_d)) $soalKosong[] = "Option D";
    if (isQuillEmptyCheck($option_e)) $soalKosong[] = "Option E";
    if (isQuillEmptyCheck($kunci_jawaban)) $soalKosong[] = "Kunci Jawaban";


    if (!empty($soalKosong)) {
        $warning[] = "Soal ke-".$urutSoal." belum lengkap: ".implode(', ', $soalKosong);
    }

    // Jika soal lama -> UPDATE
    if (!empty($seq_soal_dtl)) {
        $stmt = $db->prepare("
            UPDATE f_soal_dtl SET 
                no_soal = :no_soal,
                isi_soal = :isi_soal,
                option_a = :option_a,
                option_b = :option_b,
                option_c = :option_c,
                option_d = :option_d,
                option_e = :option_e,
                isi_soal_unicode = :isi_soal_unicode,
                option_a_unicode = :option_a_unicode,
                option_b_unicode = :option_b_unicode,
                option_c_unicode = :option_c_unicode,
                option_d_unicode = :option_d_unicode,
                option_e_unicode = :option_e_unicode,
                kunci_jawaban = :kunci_jawaban,
                gambar_soal_filename = :gambar
            WHERE seq_soal_dtl = :id AND id_ujian_hdr = :hdr
        ");
        $stmt->execute([
            ':no_soal' => $urutSoal,
            ':isi_soal' => $isi_soal,
            ':option_a' => $option_a,
            ':option_b' => $option_b,
            ':option_c' => $option_c,
            ':option_d' => $option_d,
            ':option_e' => $option_e,
            ':isi_soal_unicode' => $isi_soal_unicode,
            ':option_a_unicode' => $option_a_unicode,
            ':option_b_unicode' => $option_b_unicode,
            ':option_c_unicode' => $option_c_unicode,
            ':option_d_unicode' => $option_d_unicode,
            ':option_e_unicode' => $option_e_unicode,
            ':kunci_jawaban' => $kunci_jawaban,
            ':gambar' => $gambarBaru ?? $gambar_soal_filename,
            ':id' => $seq_soal_dtl,
            ':hdr' => $id_ujian_hdr
        ]);
    }
    // Jika soal baru -> INSERT
    else {
        $stmt = $db->prepare("
            INSERT INTO f_soal_dtl (id_ujian_hdr, no_soal, isi_soal, option_a, option_b, option_c, option_d, option_e,  option_a_unicode, option_b_unicode, option_c_unicode, option_d_unicode, option_e_unicode, isi_soal_unicode, kunci_jawaban, gambar_soal_filename)
            VALUES (:hdr, :no_soal, :isi_soal, :option_a, :option_b, :option_c, :option_d, :option_e, :option_a_unicode, :option_b_unicode, :option_c_unicode, :option_d_unicode, :option_e_unicode, :isi_soal_unicode, :kunci_jawaban, :gambar)
        ");
        $stmt->execute([
            ':hdr' => $id_ujian_hdr,
            ':no_soal' => $urutSoal,
            ':isi_soal' => $isi_soal,
            ':option_a' => $option_a,
            ':option_b' => $option_b,
            ':option_c' => $option_c,
            ':option_d' => $option_d,
            ':option_e' => $option_e,
            ':isi_soal_unicode' => $isi_soal_unicode,
            ':option_a_unicode' => $option_a_unicode,
            ':option_b_unicode' => $option_b_unicode,
            ':option_c_unicode' => $option_c_unicode,
            ':option_d_unicode' => $option_d_unicode,
            ':option_e_unicode' => $option_e_unicode,
            ':kunci_jawaban' => $kunci_jawaban,
            ':gambar' => $gambarBaru
        ]);
    }

    $urutSoal++; // Increment urutan soal hanya untuk soal aktif (yang tidak dihapus)
}

$sql5 = "SELECT COUNT(1) jml_soal FROM f_soal_dtl WHERE id_ujian_hdr = $id_ujian_hdr";
$hasil5 = $db->query($sql5);
$baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);
$jml_soal = $baris5['jml_soal'];
$nilai = 100/$jml_soal;

$sql4 = "UPDATE f_soal_dtl set nilai = '$nilai' where id_ujian_hdr = :id_ujian_hdr";
$stmt4 = $db->prepare($sql4);
$stmt4->execute(['id_ujian_hdr' => $id_ujian_hdr]);

// Tampilkan warning jika ada, tapi tetap simpan
if (!empty($warning)) {
    $msg = implode("\\n", $warning);
    echo "<script>alert('Perhatian:\\n$msg'); window.location.href='daftar_ujian_saya_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
} else {
    echo "<script>alert('Soal berhasil diperbarui!'); window.location.href='daftar_ujian_saya_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
}
?>
