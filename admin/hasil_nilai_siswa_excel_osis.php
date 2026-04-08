<?php
require 'config.php';
require 'vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

session_start();
if ($_SESSION['fname'] == null || $_SESSION['role'] <> '3') {
    header('location:../login.php');
    exit;
}

try {
    $id_ujian_hdr = $_POST['id_ujian_hdr'];
    $nama_ujian = $_POST['nama_ujian'];
    $nama_subkelas = $_POST['nama_subkelas'];

    // ==========================
    // QUERY AMBIL DATA JAWABAN
    // ==========================
    $sql = "
        SELECT 
            s.nis,
            sk.nama_subkelas,
            s.nama_siswa,

            -- Soal dan opsi untuk nomor 1 (tanpa tag HTML)
            regexp_replace(s1.isi_soal, '<[^>]*>', '', 'g') AS soal_1,
            regexp_replace(s1.option_a, '<[^>]*>', '', 'g') AS option_1a,
            regexp_replace(s1.option_b, '<[^>]*>', '', 'g') AS option_1b,
            regexp_replace(s1.option_c, '<[^>]*>', '', 'g') AS option_1c,

            -- Soal dan opsi untuk nomor 2 (tanpa tag HTML)
            regexp_replace(s2.isi_soal, '<[^>]*>', '', 'g') AS soal_2,
            regexp_replace(s2.option_a, '<[^>]*>', '', 'g') AS option_2a,
            regexp_replace(s2.option_b, '<[^>]*>', '', 'g') AS option_2b,
            regexp_replace(s2.option_c, '<[^>]*>', '', 'g') AS option_2c,

            -- Jawaban siswa untuk soal 1
            CASE d1.jawaban_siswa
                WHEN 'A' THEN regexp_replace(s1.option_a, '<[^>]*>', '', 'g')
                WHEN 'B' THEN regexp_replace(s1.option_b, '<[^>]*>', '', 'g')
                WHEN 'C' THEN regexp_replace(s1.option_c, '<[^>]*>', '', 'g')
                WHEN 'D' THEN regexp_replace(s1.option_d, '<[^>]*>', '', 'g')
                WHEN 'E' THEN regexp_replace(s1.option_e, '<[^>]*>', '', 'g')
                ELSE NULL
            END AS jawaban_soal_1,

            -- Jawaban siswa untuk soal 2
            CASE d2.jawaban_siswa
                WHEN 'A' THEN regexp_replace(s2.option_a, '<[^>]*>', '', 'g')
                WHEN 'B' THEN regexp_replace(s2.option_b, '<[^>]*>', '', 'g')
                WHEN 'C' THEN regexp_replace(s2.option_c, '<[^>]*>', '', 'g')
                WHEN 'D' THEN regexp_replace(s2.option_d, '<[^>]*>', '', 'g')
                WHEN 'E' THEN regexp_replace(s2.option_e, '<[^>]*>', '', 'g')
                ELSE NULL
            END AS jawaban_soal_2

        FROM d_siswa s
        LEFT JOIN d_kelas k ON k.id = s.id_kelas
        LEFT JOIN d_subkelas sk ON sk.id = s.id_subkelas

        LEFT JOIN f_jawaban_siswa_hdr h 
            ON h.uuidsiswa = s.uuidsiswa 
            AND h.id_ujian_hdr = $id_ujian_hdr

        LEFT JOIN f_jawaban_siswa_dtl d1 
            ON d1.id_jawaban_siswa = h.id_jawaban_siswa 
            AND d1.no_soal = 1
        LEFT JOIN f_jawaban_siswa_dtl d2 
            ON d2.id_jawaban_siswa = h.id_jawaban_siswa 
            AND d2.no_soal = 2

        LEFT JOIN f_soal_dtl s1 
            ON s1.id_ujian_hdr = $id_ujian_hdr 
            AND s1.no_soal = 1
        LEFT JOIN f_soal_dtl s2 
            ON s2.id_ujian_hdr = $id_ujian_hdr 
            AND s2.no_soal = 2

        WHERE s.id_kelas = (
                SELECT id_kelas FROM f_jawaban_siswa_hdr 
                WHERE id_ujian_hdr = $id_ujian_hdr LIMIT 1
            )
          AND s.id_subkelas = (
                SELECT id_subkelas FROM f_jawaban_siswa_hdr 
                WHERE id_ujian_hdr = $id_ujian_hdr LIMIT 1
            )

        ORDER BY s.nama_siswa
    ";

    $stmt = $db->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // ==========================
    // BUAT SPREADSHEET
    // ==========================
    $spreadsheet = new Spreadsheet();
    $sheet = $spreadsheet->getActiveSheet();

    // Header kolom otomatis dari nama field
    if (count($rows) > 0) {
        $colIndex = 1;
        foreach (array_keys($rows[0]) as $colName) {
            $sheet->setCellValueByColumnAndRow($colIndex, 1, $colName);
            $colIndex++;
        }

        // Isi data
        $rowIndex = 2;
        foreach ($rows as $row) {
            $colIndex = 1;
            foreach ($row as $value) {
                $sheet->setCellValueByColumnAndRow($colIndex, $rowIndex, $value);
                $colIndex++;
            }
            $rowIndex++;
        }
    }

    // ==========================
    // NAMA FILE AMAN
    // ==========================
    $safe_ujian = trim(preg_replace('/[^\w\s\-]/u', '', $nama_ujian));
    $safe_subkelas = trim(preg_replace('/[^\w\s\-]/u', '', $nama_subkelas));
    if ($safe_ujian === '') $safe_ujian = 'ujian';
    if ($safe_subkelas === '') $safe_subkelas = 'kelas';

    $filename = 'Jawaban_' . str_replace(' ', '_', $safe_ujian) . '_' . str_replace(' ', '_', $safe_subkelas) . '.xlsx';

    // ==========================
    // OUTPUT KE BROWSER (DOWNLOAD)
    // ==========================
    $writer = new Xlsx($spreadsheet);
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment;filename="'.$filename.'"');
    header('Cache-Control: max-age=0');
    $writer->save('php://output');
    exit;

} catch (PDOException $e) {
    echo "Koneksi / Query gagal: " . $e->getMessage();
}
?>
