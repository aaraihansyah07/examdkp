<?php
require 'config.php';
require 'vendor/autoload.php';
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
session_start();
if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
    header('location:../login.php');
}

try {
    $id_ujian_hdr = $_POST['id_ujian_hdr'];
    $nama_ujian = $_POST['nama_ujian'];
    $nama_subkelas = $_POST['nama_subkelas'];

    // Query ambil 
    $sql = "SELECT 
    s.nis,
    s.nama_siswa,
    --COALESCE(CAST(SUM(d.nilai) AS TEXT), 'Belum Ujian') AS nilai,
    COALESCE(
        CAST(ROUND(SUM(d.nilai)::numeric, 1) AS TEXT),
        'Belum Ujian'
    ) AS nilai,
    '$nama_subkelas' subkelas
FROM d_siswa s
JOIN (
    -- ambil id_kelas dari ujian header yg dimaksud
    SELECT DISTINCT s2.id_subkelas
    FROM f_jawaban_siswa_hdr h2
    JOIN d_siswa s2 ON s2.uuidsiswa = h2.uuidsiswa
    WHERE h2.id_ujian_hdr = $id_ujian_hdr
) kls ON s.id_subkelas = kls.id_subkelas
LEFT JOIN f_jawaban_siswa_hdr h 
       ON h.uuidsiswa = s.uuidsiswa 
      AND h.id_ujian_hdr = $id_ujian_hdr
LEFT JOIN f_jawaban_siswa_dtl d 
       ON d.id_jawaban_siswa = h.id_jawaban_siswa
GROUP BY s.uuidsiswa, s.nis, s.nama_siswa
ORDER BY s.nama_siswa;
";
    $stmt = $db->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Buat Spreadsheet baru
    $spreadsheet = new Spreadsheet();
    $sheet = $spreadsheet->getActiveSheet();

    // Header kolom (ambil dari nama field)
    if (count($rows) > 0) {
        $colIndex = 1;
        foreach (array_keys($rows[0]) as $colName) {
            $sheet->setCellValueByColumnAndRow($colIndex, 1, $colName);
            $colIndex++;
        }

        // Data isi
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

    // --- siapkan nama file aman ---
    $safe_ujian = trim(preg_replace('/[^\w\s\-]/u', '', $nama_ujian));
    $safe_subkelas = trim(preg_replace('/[^\w\s\-]/u', '', $nama_subkelas));
    if ($safe_ujian === '') $safe_ujian = 'ujian';
    if ($safe_subkelas === '') $safe_subkelas = 'kelas';

    $filename = 'Hasil_Ujian_Siswa_' . str_replace(' ', '_', $safe_ujian) . '_' . str_replace(' ', '_', $safe_subkelas) . '.xlsx';

    // Simpan ke output (download browser)
    $writer = new Xlsx($spreadsheet);
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment;filename="'.$filename.'"');
    header('Cache-Control: max-age=0');

    $writer->save('php://output');
    exit;

} catch (PDOException $e) {
    echo "Koneksi / Query gagal: " . $e->getMessage();
}
