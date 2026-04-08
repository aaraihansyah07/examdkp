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
    $nama_kelas_filter = $_POST['nama_kelas_filter'];
    $nama_subkelas_filter = $_POST['nama_subkelas_filter'];
    $sql = "SELECT u.uname NIS, s.nama_siswa, case when (gender = 'L') then 'Laki-laki' else 'Perempuan' end gender, 
    s.nis, sk.nama_subkelas
    from users u
    left join d_siswa s on s.nis = u.uname
    left join d_tahun_ajaran ta on ta.kode_tahun_ajaran = s.kode_tahun_ajaran
    left join d_kelas k on k.id = s.id_kelas
    left join d_subkelas sk on sk.id = s.id_subkelas
    where ('$nama_kelas_filter' = '' or k.nama_kelas = '$nama_kelas_filter')
    and ('$nama_subkelas_filter' = '' or sk.nama_subkelas = '$nama_subkelas_filter')
    and u.role = '2'
    order by K.nama_kelas, sk.nama_subkelas, s.nama_siswa";
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
    header('Content-Disposition: attachment;filename="Data_akun_siswa.xlsx"');
    header('Cache-Control: max-age=0');

    $writer->save('php://output');
    exit;

} catch (PDOException $e) {
    echo "Koneksi / Query gagal: " . $e->getMessage();
}
