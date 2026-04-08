<?php
require 'config.php';
session_start();
if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
    header('location:../login.php');
}

$id_ujian = $_POST['id_ujian'];
$soalList = $_POST['soal'];
// $waktu_mulai = $_POST['waktu_mulai'];
// $waktu_berakhir = $_POST['waktu_berakhir'];
$durasi = $_POST['durasi'];
$nama_bab = $_POST['nama_bab'];
$id_subkelas = $_POST['id_subkelas'];
$user_create = $_SESSION['uname'];
$uuidguru = $_POST['uuidguru'];
$tanggal_ujian = $_POST['tanggal_ujian'];
$soal_acak = $_POST['soal_acak'];
$option_acak = $_POST['option_acak'];
$st_susulan = $_POST['st_susulan'];

$sql5b = "SELECT kode_guru FROM d_guru WHERE uuidguru = '$uuidguru'";
$hasil5b = $db->query($sql5b);
$baris5b = $hasil5b->fetch(PDO::FETCH_ASSOC);
$kode_guru = $baris5b['kode_guru'];

$sql5 = "SELECT kode_ujian, kode_mata_pelajaran FROM d_ujian WHERE id_ujian = $id_ujian";
$hasil5 = $db->query($sql5);
$baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);
$kode_ujian = $baris5['kode_ujian'];
$kode_mata_pelajaran = $baris5['kode_mata_pelajaran'];

// $sql5c = "SELECT count(1) cek_ada from f_soal_hdr 
// where id_ujian = $id_ujian AND id_kelas = $id_kelas AND id_subkelas = $id_subkelas
// AND nama_bab = '$nama_bab' AND kode_mata_pelajaran = '$kode_mata_pelajaran' AND st_susulan = '$st_susulan'";
// $hasil5c = $db->query($sql5c);
// $baris5c = $hasil5->fetch(PDO::FETCH_ASSOC);

// if ($baris5c['cek_ada'] > 0) {

// }


// Pastikan folder uploads ada
$uploadDir = '../uploads/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Cache gambar agar tidak upload berulang
$gambarSoalUploadCache = [];

  function generate_token($length = 7) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // hindari O, I, 1, 0
    $token = '';
    for ($i = 0; $i < $length; $i++) {
        $token .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $token;
}

function unicodeMathToLatex($text) {
    if (!$text) return '';

    // 1️⃣ Minus Unicode → minus biasa
    $text = str_replace('−', '-', $text);

    // 2️⃣ Panah Unicode → \to
    $text = str_replace('→', '\\to', $text);

    // 3️⃣ Huruf Math Unicode → ASCII
    $unicodeMap = [
        '𝑎'=>'a','𝑏'=>'b','𝑐'=>'c','𝑑'=>'d','𝑒'=>'e','𝑓'=>'f','𝑔'=>'g','𝑖'=>'i','𝑗'=>'j',
        '𝑘'=>'k','𝑙'=>'l','𝑚'=>'m','𝑛'=>'n','𝑜'=>'o','𝑝'=>'p','𝑞'=>'q','𝑟'=>'r','𝑠'=>'s',
        '𝑡'=>'t','𝑢'=>'u','𝑣'=>'v','𝑤'=>'w','𝑥'=>'x','𝑦'=>'y','𝑧'=>'z',
        '𝐴'=>'A','𝐵'=>'B','𝐶'=>'C','𝐷'=>'D','𝐸'=>'E','𝐹'=>'F','𝐺'=>'G','𝐻'=>'H','𝐼'=>'I',
        '𝐽'=>'J','𝐾'=>'K','𝐿'=>'L','𝑀'=>'M','𝑁'=>'N','𝑂'=>'O','𝑃'=>'P','𝑄'=>'Q','𝑅'=>'R',
        '𝑆'=>'S','𝑇'=>'T','𝑈'=>'U','𝑉'=>'V','𝑊'=>'W','𝑋'=>'X','𝑌'=>'Y','𝑍'=>'Z'
    ];
    $text = strtr($text, $unicodeMap);

    // 4️⃣ Akar √(...) atau √x → \sqrt{...}
    $text = preg_replace_callback('/√(\((.*?)\)|[a-zA-Z0-9]+)/u', function($matches) {
        return '\\sqrt{' . (isset($matches[2]) && $matches[2] != '' ? $matches[2] : $matches[1]) . '}';
    }, $text);

    // 5️⃣ Pecahan (a)/(b) → \frac{a}{b}
    $text = preg_replace_callback('/\(([^()]+)\)\/\(([^()]+)\)/', function($matches) {
        return '\\frac{' . $matches[1] . '}{' . $matches[2] . '}';
    }, $text);

    // 6️⃣ Limit lim(x→...) → \lim_{x \to ...}
    $text = preg_replace_callback('/(?:\(?lim\)?)[⁡┬]*\(?([a-zA-Z0-9]+)\\\\to([a-zA-Z0-9]+)\)?/i', function($matches) {
        return '\\lim_{' . trim($matches[1]) . ' \\to ' . trim($matches[2]) . '}';
    }, $text);

    // 7️⃣ Hapus karakter sisa Excel
    $text = str_replace(['⁡','〖','〗','┬','(',')'], '', $text);

    return trim($text);
}

foreach ($id_subkelas as $subkelas) {
    $sql6 = "SELECT id_kelas FROM d_subkelas WHERE id = $subkelas";
    $hasil6 = $db->query($sql6);
    $baris6 = $hasil6->fetch(PDO::FETCH_ASSOC);
    $id_kelas = $baris6['id_kelas'];
    $token = generate_token();

    $sqlcekdobel = "SELECT count(1) cek_ada
    FROM f_soal_hdr WHERE id_ujian = $id_ujian AND id_kelas = $id_kelas AND id_subkelas = $subkelas 
    AND kode_mata_pelajaran = '$kode_mata_pelajaran' AND nama_bab = '$nama_bab' AND st_susulan = '$st_susulan'";
    $hasilcekdobel = $db->query($sqlcekdobel);
    $bariscekdobel = $hasilcekdobel->fetch(PDO::FETCH_ASSOC);
    $cekdobel = $bariscekdobel['cek_ada'];

    if ($cekdobel > 0) {
        echo "<script>alert('Ada ujian yang sudah pernah dibuat sebelumnya pada kelas yang dituju, silakan cek kembali daftar ujian yang sudah dibuat'); window.history.back();</script>";
        exit;
    }


    // Simpan header ujian
    $stmt = $db->prepare("INSERT INTO f_soal_hdr (st_susulan, tanggal_ujian, token, kode_mata_pelajaran, kode_guru, uuidguru, id_kelas, kode_ujian, durasi, nama_bab, id_ujian, id_subkelas, createuser, soal_acak, option_acak) 
                        VALUES (:st_susulan, :tanggal_ujian, :token, :kode_mata_pelajaran, :kode_guru, :uuidguru, :id_kelas, :kode_ujian, :durasi, :nama_bab, :id_ujian, :subkelas, :user_create, :soal_acak, :option_acak)");
    $stmt->execute([
        ':st_susulan' => $st_susulan,
        ':tanggal_ujian' => $tanggal_ujian,
        ':token' => $token,
        ':kode_mata_pelajaran' => $kode_mata_pelajaran,
        ':kode_guru' => $kode_guru,
        ':uuidguru' => $uuidguru,
        ':id_kelas' => $id_kelas,
        ':kode_ujian' => $kode_ujian,
        ':durasi' => $durasi,
        ':nama_bab' => $nama_bab,
        ':id_ujian' => $id_ujian,
        ':subkelas' => $subkelas,
        ':user_create' => $user_create,
        ':soal_acak' => $soal_acak,
        ':option_acak' => $option_acak
    ]);

    $id_ujian_hdr = $db->lastInsertId('seq_soal_hdr');

    foreach ($soalList as $index => $soal) {
        $isi_soal = unicodeMathToLatex($soal['isi_soal']);
        $option_a = unicodeMathToLatex($soal['option_a']);
        $option_b = unicodeMathToLatex($soal['option_b']);
        $option_c = unicodeMathToLatex($soal['option_c']);
        $option_d = unicodeMathToLatex($soal['option_d']);
        $option_e = unicodeMathToLatex($soal['option_e']);
        $isi_soal_unicode = $soal['isi_soal'];
        $option_a_unicode = $soal['option_a'];
        $option_b_unicode = $soal['option_b'];
        $option_c_unicode = $soal['option_c'];
        $option_d_unicode = $soal['option_d'];
        $option_e_unicode = $soal['option_e']; 
        $kunci = $soal['kunci'];

        // Handle gambar
        $gambarFilename = null;

        // Cek apakah gambar soal ini sudah diupload sebelumnya (cache)
        if (isset($gambarSoalUploadCache[$index])) {
            $gambarFilename = $gambarSoalUploadCache[$index];
        } else {
            if (isset($_FILES['soal']['name'][$index]['gambar']) && $_FILES['soal']['name'][$index]['gambar'] != '') {
                $gambarTmp = $_FILES['soal']['tmp_name'][$index]['gambar'];
                $originalName = $_FILES['soal']['name'][$index]['gambar'];
                $fileSize = $_FILES['soal']['size'][$index]['gambar'];
                $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
                $allowedExt = ['jpg', 'jpeg', 'png', 'gif'];

                if (!in_array($ext, $allowedExt)) {
                    echo "<script>alert('Gagal upload: Format gambar harus JPG, PNG, atau GIF.'); window.history.back();</script>";
                    exit;
                }

                if ($fileSize > 1024 * 1024) {
                    echo "<script>alert('Gagal upload: Ukuran gambar tidak boleh lebih dari 1MB.'); window.history.back();</script>";
                    exit;
                }

                $newName = uniqid('soal_') . '.' . $ext;
                move_uploaded_file($gambarTmp, $uploadDir . $newName);
                $gambarFilename = $newName;

                // Simpan ke cache supaya subkelas berikutnya pakai file yang sama
                $gambarSoalUploadCache[$index] = $gambarFilename;
            }
        }

        // Simpan detail soal
        $stmt2 = $db->prepare("INSERT INTO f_soal_dtl (id_ujian_hdr, option_a, option_b, option_c, option_d, option_e, isi_soal, option_a_unicode, option_b_unicode, option_c_unicode, option_d_unicode, option_e_unicode, isi_soal_unicode,  gambar_soal_filename, kunci_jawaban, no_soal) 
                            VALUES (:id_ujian_hdr, :a, :b, :c, :d, :e, :isi_soal, :a_unicode, :b_unicode, :c_unicode, :d_unicode, :e_unicode, :isi_soal_unicode, :gambar_soal_filename, :kunci_jawaban, :no_soal)");
        $stmt2->execute([
            ':id_ujian_hdr' => $id_ujian_hdr,
            ':a' => $option_a,
            ':b' => $option_b,
            ':c' => $option_c,
            ':d' => $option_d,
            ':e' => $option_e,
            ':isi_soal' => $isi_soal,
            ':a_unicode' => $option_a_unicode,
            ':b_unicode' => $option_b_unicode,
            ':c_unicode' => $option_c_unicode,
            ':d_unicode' => $option_d_unicode,
            ':e_unicode' => $option_e_unicode,
            ':isi_soal_unicode' => $isi_soal_unicode,
            ':gambar_soal_filename' => $gambarFilename,
            ':kunci_jawaban' => $kunci,
            ':no_soal' => $index + 1
        ]);
    }

    $sqlnilai = "SELECT COUNT(1) jml_soal FROM f_soal_dtl WHERE id_ujian_hdr = $id_ujian_hdr";
    $hasilnilai = $db->query($sqlnilai);
    $barisnilai = $hasilnilai->fetch(PDO::FETCH_ASSOC);
    $jml_soal = $barisnilai['jml_soal'];
    $nilai = 100/$jml_soal;

    $sql4 = "UPDATE f_soal_dtl set nilai = '$nilai' where id_ujian_hdr = :id_ujian_hdr";
    $stmt4 = $db->prepare($sql4);
    $stmt4->execute(['id_ujian_hdr' => $id_ujian_hdr]);
}

echo "<script>alert('Soal berhasil disimpan!'); window.location.href='list_ujian.php';</script>";
exit;
?>
