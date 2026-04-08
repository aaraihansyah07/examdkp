<?php
require 'vendor/autoload.php'; // Pastikan PhpSpreadsheet sudah diinstall
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;

include('config.php');

if (!isset($_FILES['excel_file'])) {
    die("File belum diupload!");
}

$fileName = $_FILES['excel_file']['name'];
$excelPath = $_FILES['excel_file']['tmp_name'];
$ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

if (!in_array($ext, ['xlsx', 'xls'])) {
    // Format salah, kembali ke form
    header("Location: test.php?error=format");
    exit;
}

$spreadsheet = IOFactory::load($excelPath);
$sheet = $spreadsheet->getActiveSheet();


// Nilai default sesuai permintaan
$id_ujian    = 31;
$kode_ujian  = 'UH.KIM.SMT1.2526';
$id_kelas    = 8;
$id_subkelas = 4;
$nama_bab    = 'test_unsur';
$durasi      = 90;

// Ambil ID baru dari sequence
$sql5 = "SELECT nextval('seq_soal_hdr') seq_id";
$hasil5 = $db->query($sql5);    
$baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);
$id_new = $baris5['seq_id'];

try {
    $db->beginTransaction();
    // Insert ke f_soal_hdr
    $stmtHdr = $db->prepare("
        INSERT INTO f_soal_hdr (id_ujian, kode_ujian, id_kelas, id_subkelas, nama_bab, durasi, id_ujian_hdr)
        VALUES (:id_ujian, :kode_ujian, :id_kelas, :id_subkelas, :nama_bab, :durasi, :id_ujian_hdr)
    ");
    $stmtHdr->execute([
        ':id_ujian'    => $id_ujian,
        ':kode_ujian'  => $kode_ujian,
        ':id_kelas'    => $id_kelas,
        ':id_subkelas' => $id_subkelas,
        ':nama_bab'    => $nama_bab,
        ':durasi'      => $durasi,
        ':id_ujian_hdr'=> $id_new
    ]);

    // Folder upload gambar ../uploads/
    $uploadDir = realpath(__DIR__ . '/../uploads');
    if ($uploadDir === false) {
        // Jika folder tidak ada, buat foldernya
        $uploadDir = __DIR__ . '/../uploads';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
    } else {
        $uploadDir = rtrim($uploadDir, '/') . '/';
    }

    // Ambil semua gambar dari sheet
    $drawings = $sheet->getDrawingCollection();
    $imageMap = []; // mapping: [baris] => nama_file_gambar

    foreach ($drawings as $drawing) {
        $coord = $drawing->getCoordinates(); // Contoh: B2
        $cellCol = Coordinate::columnIndexFromString(preg_replace('/[0-9]/', '', $coord)); // kolom angka
        $cellRow = (int)preg_replace('/[A-Z]/', '', $coord); // baris angka

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

            // Simpan hanya nama file (tanpa path)
            $imageMap[$cellRow] = $imageName;
        }
    }

    // Loop data Excel mulai baris ke-2
    $highestRow = $sheet->getHighestRow();
    $totalSoal = $highestRow - 1; // data mulai baris 2
    $nilai = 100 / $totalSoal;

    foreach ($sheet->getRowIterator(2) as $row) {
        $rowIndex = $row->getRowIndex();

        $cellIterator = $row->getCellIterator();
        $cellIterator->setIterateOnlyExistingCells(false);

        $data = [];
        foreach ($cellIterator as $cell) {
            $data[] = $cell->getValue();
        }

        $no_soal    = $data[0] ?? '';
        $pertanyaan = $data[2] ?? '';
        $opsi_a     = $data[3] ?? '';
        $opsi_b     = $data[4] ?? '';
        $opsi_c     = $data[5] ?? '';
        $opsi_d     = $data[6] ?? '';
        $opsi_e     = $data[7] ?? '';
        $jawaban    = $data[8] ?? '';

        // Ambil nama file gambar jika ada
        $gambarSoal = $imageMap[$rowIndex] ?? null;

        // Insert ke f_soal_dtl
        $stmtDtl = $db->prepare("
            INSERT INTO f_soal_dtl 
            (nilai, no_soal, id_ujian_hdr, isi_soal, gambar_soal_filename, option_a, option_b, option_c, option_d, option_e, kunci_jawaban)
            VALUES 
            (:nilai, :no_soal, :id_ujian_hdr, :pertanyaan, :gambar_soal, :opsi_a, :opsi_b, :opsi_c, :opsi_d, :opsi_e, :jawaban)
        ");
        $stmtDtl->execute([
            ':nilai'       => $nilai,
            ':no_soal'       => $no_soal,
            ':id_ujian_hdr'  => $id_new,
            ':pertanyaan'    => $pertanyaan,
            ':gambar_soal'   => $gambarSoal,
            ':opsi_a'        => $opsi_a,
            ':opsi_b'        => $opsi_b,
            ':opsi_c'        => $opsi_c,
            ':opsi_d'        => $opsi_d,
            ':opsi_e'        => $opsi_e,
            ':jawaban'       => $jawaban
        ]);
    }
     echo "Upload & insert selesai!";
     $db->commit();
    
}
catch (Exception $e) {
    $db->rollBack();
    // tangani error
    echo "Gagal: " . $e->getMessage();
}