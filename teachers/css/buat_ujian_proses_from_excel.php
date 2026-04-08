<?php
require 'config.php';
session_start();
// if ($_SESSION['fname'] == null or $_SESSION['role'] <> '2') {
//     header('location:../login.php');
// }

require 'vendor/autoload.php';
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;

// Cek file upload
if (!isset($_FILES['excel_file'])) {
    die("File belum diupload atau format file salah");
}

$fileName   = $_FILES['excel_file']['name'];
$excelPath  = $_FILES['excel_file']['tmp_name'];
$ext        = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

if (!in_array($ext, ['xlsx', 'xls'])) {
    header("Location: buat_ujian_proses_from_excel.php?error=format");
    exit;
}

// Load Excel
$spreadsheet = IOFactory::load($excelPath);
$sheet       = $spreadsheet->getActiveSheet();

// Ambil data POST
$id_ujian     = $_POST['id_ujian'];
$durasi       = $_POST['durasi'];
$nama_bab     = $_POST['nama_bab'];
$id_subkelas  = $_POST['id_subkelas'];
$user_create  = $_SESSION['uname'];
$uuidguru     = $_POST['uuidguru'];
$kode_guru    = $_POST['kode_guru'];
$tanggal_ujian = $_POST['tanggal_ujian'];
$soal_acak = $_POST['soal_acak'];
$option_acak = $_POST['option_acak'];
$st_susulan = $_POST['st_susulan'];

// Ambil info ujian
$sql5    = "SELECT kode_ujian, kode_mata_pelajaran FROM d_ujian WHERE id_ujian = $id_ujian";
$hasil5  = $db->query($sql5);
$baris5  = $hasil5->fetch(PDO::FETCH_ASSOC);
$kode_ujian = $baris5['kode_ujian'];
$kode_mata_pelajaran = $baris5['kode_mata_pelajaran'];

// Siapkan folder uploads
$uploadDir = realpath(__DIR__ . '/../uploads');
if ($uploadDir === false) {
    $uploadDir = __DIR__ . '/../uploads';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
} else {
    $uploadDir = rtrim($uploadDir, '/') . '/';
}

// helper agar tidak error jika null
function clean_text($v) {
    return trim((string)$v);
}

// Fungsi buat token
function generate_token($length = 7) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
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

// ========================================
// 1️⃣ Ambil semua gambar dari Excel SEKALI
// ========================================
$imageMap = []; // mapping [baris] => nama_file_gambar
$drawings = $sheet->getDrawingCollection();

foreach ($drawings as $drawing) {
    $coord   = $drawing->getCoordinates(); // contoh: B2
    $cellCol = Coordinate::columnIndexFromString(preg_replace('/[0-9]/', '', $coord));
    $cellRow = (int)preg_replace('/[A-Z]/', '', $coord);

    if ($cellCol == 2) { // kolom B
        $imageName = uniqid('soal_') . '.png';
        $savePath  = $uploadDir . $imageName;

        if ($drawing instanceof \PhpOffice\PhpSpreadsheet\Worksheet\MemoryDrawing) {
            ob_start();
            call_user_func($drawing->getRenderingFunction(), $drawing->getImageResource());
            $imageData = ob_get_contents();
            ob_end_clean();
            file_put_contents($savePath, $imageData);
        } else {
            copy($drawing->getPath(), $savePath);
        }

        $imageMap[$cellRow] = $imageName;
    }
}

// ========================================
// 2️⃣ Loop untuk tiap subkelas
// ========================================
try {
    foreach ($id_subkelas as $subkelas) {
        // Ambil id_kelas
        $sql6   = "SELECT id_kelas FROM d_subkelas WHERE id = $subkelas";
        $hasil6 = $db->query($sql6);
        $baris6 = $hasil6->fetch(PDO::FETCH_ASSOC);
        $id_kelas = $baris6['id_kelas'];

        // Cek duplikat
        $kode_unik = $id_ujian.$id_kelas.$subkelas.$kode_mata_pelajaran.$nama_bab.$st_susulan;
        $sqlcek    = "SELECT id_ujian, id_kelas, id_subkelas, kode_mata_pelajaran, nama_bab, st_susulan 
                      FROM f_soal_hdr 
                      WHERE id_ujian = $id_ujian AND id_kelas = $id_kelas 
                      AND id_subkelas = $subkelas AND kode_mata_pelajaran = '$kode_mata_pelajaran' 
                      AND nama_bab = '$nama_bab' AND st_susulan = '$st_susulan'";
        $hasilcek  = $db->query($sqlcek);
        $bariscek  = $hasilcek->fetch(PDO::FETCH_ASSOC);
        $cekdobel  = $bariscek ? $bariscek['id_ujian'].$bariscek['id_kelas'].$bariscek['id_subkelas'].$bariscek['kode_mata_pelajaran'].$bariscek['nama_bab'].$bariscek['st_susulan'] : '';

        if ($cekdobel == $kode_unik) {
            echo "<script>alert('Ada ujian yang sudah pernah dibuat sebelumnya pada kelas yang dituju.'); window.history.back();</script>";
            exit;
        }

        // Simpan header ujian
        $db->beginTransaction();
        $stmt = $db->prepare("
            INSERT INTO f_soal_hdr 
            (st_susulan, tanggal_ujian, kode_mata_pelajaran, kode_guru, uuidguru, id_kelas, kode_ujian, durasi, nama_bab, id_ujian, id_subkelas, createuser, token, soal_acak, option_acak) 
            VALUES 
            (:st_susulan, :tanggal_ujian, :kode_mata_pelajaran, :kode_guru, :uuidguru, :id_kelas, :kode_ujian, :durasi, :nama_bab, :id_ujian, :subkelas, :user_create, :token, :soal_acak, :option_acak)
        ");
        $stmt->execute([
            ':st_susulan' => $st_susulan,
            ':tanggal_ujian' => $tanggal_ujian,
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
            ':token' => generate_token(),
            ':soal_acak' => $soal_acak,
            ':option_acak' => $option_acak,
        ]);

        $id_ujian_hdr = $db->lastInsertId('seq_soal_hdr');

         // Loop tiap soal
        $highestRow = $sheet->getHighestRow();
        $totalSoal  = $highestRow - 1;
        $nilai      = $totalSoal > 0 ? 100 / $totalSoal : 0;

        foreach ($sheet->getRowIterator(2) as $row) {

            $rowIndex = $row->getRowIndex();
            $cellIterator = $row->getCellIterator();
            $cellIterator->setIterateOnlyExistingCells(false); // agar index tetap konsisten

            // ambil cell per kolom (A sampai I saja)
            $data = [];
            foreach ($cellIterator as $cell) {
                $data[] = $cell->getValue();
            }

            //---------------------------------------------------
            // 1️⃣ Ambil & validasi no soal (kolom A)
            //---------------------------------------------------
            $no_soal_raw = clean_text($data[0] ?? '');

            // 1.a. Jika kolom A kosong → berarti soal selesai → STOP looping
            if ($no_soal_raw === '' || $no_soal_raw === null) {
                break;
            }

            // 1.b. Jika kolom A ada isinya tapi bukan angka → ERROR
            if (!ctype_digit($no_soal_raw)) {
                throw new Exception("No soal di baris $rowIndex tidak valid. Kolom A harus berisi angka atau kosong untuk berhenti.");
            }

            // 1.c. Jika valid angka → gunakan
            $no_soal = intval($no_soal_raw);

            //---------------------------------------------------
            // 2️⃣ Isi soal & opsi → BOLEH KOSONG
            //---------------------------------------------------
            $isi_soal = clean_text(unicodeMathToLatex($data[2] ?? ''));
            $opsi_a   = clean_text(unicodeMathToLatex($data[3] ?? ''));
            $opsi_b   = clean_text(unicodeMathToLatex($data[4] ?? ''));
            $opsi_c   = clean_text(unicodeMathToLatex($data[5] ?? ''));
            $opsi_d   = clean_text(unicodeMathToLatex($data[6] ?? ''));
            $opsi_e   = clean_text(unicodeMathToLatex($data[7] ?? ''));

            //---------------------------------------------------
            // 3️⃣ Kunci jawaban → optional, tapi jika ada harus A–E
            //---------------------------------------------------
            $jawaban_raw = clean_text($data[8] ?? '');
            $jawaban = strtoupper($jawaban_raw);

            if ($jawaban !== '' && !in_array($jawaban, ['A','B','C','D','E'])) {
                throw new Exception("Kunci jawaban tidak valid di baris $rowIndex. Harus A–E.");
            }

            //---------------------------------------------------
            // 4️⃣ Simpan ke database
            //---------------------------------------------------
            $stmtDtl = $db->prepare("
                INSERT INTO f_soal_dtl
                (nilai, no_soal, id_ujian_hdr, isi_soal, isi_soal_unicode, gambar_soal_filename,
                option_a, option_a_unicode, option_b, option_b_unicode, option_c, option_c_unicode,
                option_d, option_d_unicode, option_e, option_e_unicode, kunci_jawaban)
                VALUES
                (:nilai, :no_soal, :id_ujian_hdr, :pertanyaan, :pertanyaan_unicode, :gambar_soal,
                :opsi_a, :opsi_a_unicode, :opsi_b, :opsi_b_unicode, :opsi_c, :opsi_c_unicode,
                :opsi_d, :opsi_d_unicode, :opsi_e, :opsi_e_unicode, :jawaban)
            ");

            $stmtDtl->execute([
                ':nilai' => $nilai,
                ':no_soal' => $no_soal,
                ':id_ujian_hdr' => $id_ujian_hdr,
                ':pertanyaan' => $isi_soal,
                ':pertanyaan_unicode' => $data[2] ?? '',
                ':gambar_soal' => $imageMap[$rowIndex] ?? null,
                ':opsi_a' => $opsi_a,
                ':opsi_a_unicode' => $data[3] ?? '',
                ':opsi_b' => $opsi_b,
                ':opsi_b_unicode' => $data[4] ?? '',
                ':opsi_c' => $opsi_c,
                ':opsi_c_unicode' => $data[5] ?? '',
                ':opsi_d' => $opsi_d,
                ':opsi_d_unicode' => $data[6] ?? '',
                ':opsi_e' => $opsi_e,
                ':opsi_e_unicode' => $data[7] ?? '',
                ':jawaban' => $jawaban
            ]);
        }

        $db->commit();
    }
}
catch (Exception $e) {
    $db->rollBack();
    echo "Gagal: " . $e->getMessage();
}

echo "<script>alert('Soal berhasil disimpan!'); window.location.href='daftar_ujian_saya.php';</script>";
exit;
?>
