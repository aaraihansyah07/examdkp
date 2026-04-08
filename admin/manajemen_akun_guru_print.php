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
    $sql = "SELECT g.kode_guru, g.nama_guru, case when (gender = 'L') then 'Laki-laki' when (gender = 'P') then 'Perempuan' else '' end gender, 
    u.uname username
    from users u
    left join d_guru g on g.kode_guru = u.uname
    where u.role = '1' order by g.nama_guru";
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

    // Simpan ke output (download browser)
    $writer = new Xlsx($spreadsheet);
    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment;filename="Data_akun_guru.xlsx"');
    header('Cache-Control: max-age=0');

    $writer->save('php://output');
    exit;

} catch (PDOException $e) {
    echo "Koneksi / Query gagal: " . $e->getMessage();
}
