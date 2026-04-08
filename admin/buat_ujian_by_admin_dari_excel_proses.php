<?php
require 'config.php';
require 'vendor/autoload.php';
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;

session_start();
if (!isset($_SESSION['fname']) || $_SESSION['role'] != '3') {
    header('location:../login.php');
    exit;
}

// === 1️⃣ Cek file upload ===
if (!isset($_FILES['excel_file']) || $_FILES['excel_file']['error'] !== UPLOAD_ERR_OK) {
    die("File belum diupload atau terjadi error upload");
}

$fileName  = $_FILES['excel_file']['name'];
$excelPath = $_FILES['excel_file']['tmp_name'];
$ext       = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

if (!in_array($ext, ['xlsx', 'xls'])) {
    die("Format file salah, harus .xlsx atau .xls");
}

// Load Excel
$spreadsheet = IOFactory::load($excelPath);
$sheet       = $spreadsheet->getActiveSheet();

// === 2️⃣ Ambil data POST ===
$id_ujian     = $_POST['id_ujian'] ?? null;
$durasi       = $_POST['durasi'] ?? 0;
$nama_bab     = $_POST['nama_bab'] ?? '';
$id_subkelas  = (array)($_POST['id_subkelas'] ?? []); // pastikan array
$user_create  = $_SESSION['uname'] ?? 'system';
$uuidguru     = $_POST['uuidguru'] ?? '';
$tanggal_ujian = $_POST['tanggal_ujian'] ?? date('Y-m-d H:i:s');
$soal_acak     = $_POST['soal_acak'] ?? 'N';
$option_acak   = $_POST['option_acak'] ?? 'N';
$st_susulan   = $_POST['st_susulan'];

// Ambil kode guru
$stmtGuru = $db->prepare("SELECT kode_guru FROM d_guru WHERE uuidguru = :uuid");
$stmtGuru->execute([':uuid' => $uuidguru]);
$kode_guru = $stmtGuru->fetchColumn() ?: '';

// Ambil info ujian
$stmtUjian = $db->prepare("SELECT kode_ujian, kode_mata_pelajaran FROM d_ujian WHERE id_ujian = :id");
$stmtUjian->execute([':id' => $id_ujian]);
$ujian = $stmtUjian->fetch(PDO::FETCH_ASSOC);
$kode_ujian = $ujian['kode_ujian'] ?? '';
$kode_mata_pelajaran = $ujian['kode_mata_pelajaran'] ?? '';

// === 3️⃣ Siapkan folder uploads ===
$uploadDir = __DIR__ . '/../uploads/';
if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

// helper agar tidak error jika null
function clean_text($v) {
    return trim((string)$v);
}

// Fungsi generate token
function generate_token($length = 7) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $token = '';
    for ($i=0; $i<$length; $i++) {
        $token .= $chars[random_int(0, strlen($chars)-1)];
    }
    return $token;
}

// === 4️⃣ Fungsi konversi Unicode Math → LaTeX ===
/**
 * Konversi Unicode Math ke LaTeX sederhana
 * Contoh: 𝐀 -> A, 𝛼 -> \alpha
 */
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


// === 5️⃣ Ambil semua gambar dari Excel ===
$imageMap = [];
$drawings = $sheet->getDrawingCollection();
foreach ($drawings as $drawing) {
    $coord = $drawing->getCoordinates();
    $cellCol = Coordinate::columnIndexFromString(preg_replace('/[0-9]/', '', $coord));
    $cellRow = (int)preg_replace('/[A-Z]/', '', $coord);

    if ($cellCol == 2) { // kolom B
        $imageName = uniqid('soal_') . '.png';
        $savePath = $uploadDir . $imageName;

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

// === 6️⃣ Loop tiap subkelas dan simpan ke DB ===
try {
    foreach ($id_subkelas as $subkelas) {
        // Ambil id_kelas
        $stmtKelas = $db->prepare("SELECT id_kelas FROM d_subkelas WHERE id = :sub");
        $stmtKelas->execute([':sub' => $subkelas]);
        $id_kelas = $stmtKelas->fetchColumn() ?: 0;

        // Cek duplikat
        $stmtCek = $db->prepare("
            SELECT 1 FROM f_soal_hdr 
            WHERE id_ujian = :id_ujian 
              AND id_kelas = :id_kelas 
              AND id_subkelas = :subkelas 
              AND kode_mata_pelajaran = :kode_mp
              AND nama_bab = :nama_bab
              AND st_susulan = :st_susulan
        ");
        $stmtCek->execute([
            ':id_ujian' => $id_ujian,
            ':id_kelas' => $id_kelas,
            ':subkelas' => $subkelas,
            ':kode_mp'  => $kode_mata_pelajaran,
            ':nama_bab' => $nama_bab,
            ':st_susulan' => $st_susulan
        ]);

        if ($stmtCek->fetch()) {
            echo "<script>alert('Ada ujian yang sudah pernah dibuat sebelumnya pada kelas yang dituju, silakan cek kembali daftar ujian yang sudah dibuat'); window.history.back();</script>";
            exit;
        }

        // Simpan header ujian
        $db->beginTransaction();
        $stmtHdr = $db->prepare("
            INSERT INTO f_soal_hdr
            (st_susulan, tanggal_ujian, kode_mata_pelajaran, kode_guru, uuidguru, id_kelas, kode_ujian, durasi, nama_bab, id_ujian, id_subkelas, createuser, token, soal_acak, option_acak)
            VALUES
            (:st_susulan, :tanggal_ujian, :kode_mata_pelajaran, :kode_guru, :uuidguru, :id_kelas, :kode_ujian, :durasi, :nama_bab, :id_ujian, :id_subkelas, :user_create, :token, :soal_acak, :option_acak)
        ");
        $stmtHdr->execute([
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
            ':id_subkelas' => $subkelas,
            ':user_create' => $user_create,
            ':token' => generate_token(),
            ':soal_acak' => $soal_acak,
            ':option_acak' => $option_acak
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

    echo "<script>alert('Soal berhasil disimpan!'); window.location.href='list_ujian.php';</script>";

} catch (PDOException $e) {
    $db->rollBack();
    die("Gagal insert ke database: " . $e->getMessage());
}
?>
