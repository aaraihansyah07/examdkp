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
    // Query ambil 
    $nama_kelas = $_POST['nama_kelas'];
    $nama_subkelas = $_POST['nama_subkelas'];
    $kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];
    $jenis_ujian = $_POST['jenis_ujian'];

    $sql = "SELECT j.nama_ujian, token, tanggal_ujian, sk.nama_subkelas
            FROM f_soal_hdr h
            LEFT JOIN d_kelas k ON k.id = h.id_kelas
            LEFT JOIN d_subkelas sk ON sk.id = h.id_subkelas
            LEFT JOIN d_ujian j ON j.kode_ujian = h.kode_ujian 
            WHERE ( :nama_kelas = '' OR k.nama_kelas = :nama_kelas )
            AND ( :nama_subkelas = '' OR sk.nama_subkelas = :nama_subkelas )
            AND ( :kode_mata_pelajaran = '' OR h.kode_mata_pelajaran = :kode_mata_pelajaran )
            AND ( :jenis_ujian = '' OR j.jenis_ujian = :jenis_ujian )
            AND h.st_posting = 'Y'
            ORDER BY j.nama_ujian, sk.nama_subkelas";

    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':nama_kelas' => $nama_kelas,
        ':nama_subkelas' => $nama_subkelas,
        ':kode_mata_pelajaran' => $kode_mata_pelajaran,
        ':jenis_ujian' => $jenis_ujian
    ]);
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

    // Simpan ke output (download browser)
    $writer = new Xlsx($spreadsheet);
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment;filename="Data_token_ujian.xlsx"');
    header('Cache-Control: max-age=0');

    $writer->save('php://output');
    exit;

} catch (PDOException $e) {
    echo "Koneksi / Query gagal: " . $e->getMessage();
}
