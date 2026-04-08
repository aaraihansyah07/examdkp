<?php
ob_start(); // tangkap output tak sengaja agar FPDF tidak gagal
session_start();
if (!isset($_SESSION['uname'])) {
    $user = "Login";
} else {
    $user = $_SESSION['uname'];
    $nama_lengkap = $_SESSION['fname'];
}
include('config.php');

require('../fpdf/fpdf.php');

// Ambil input POST (amankan dengan default)
$id_ujian_hdr = $_POST['id_ujian_hdr'] ?? '';
$kode_ujian = $_POST['kode_ujian'] ?? '';
$nama_bab = $_POST['nama_bab'] ?? '';
$tanggal_ujian = $_POST['tanggal_ujian'] ?? '';
$nama_ujian = $_POST['nama_ujian'] ?? '';
$nama_subkelas = $_POST['nama_subkelas'] ?? '';
$id_subkelas_siswa = $_POST['id_subkelas_siswa'] ?? '';
$nama_guru = $_POST['nama_guru'];

$jml_siswa_ikut_ujian = $_POST['jml_siswa_ikut_ujian'] ?? 0;
$jml_siswa_tidak_ikut_ujian = $_POST['jml_siswa_tidak_ikut_ujian'] ?? 0;

// Ambil semua hasil siswa untuk header id_ujian_hdr
$sql2 = "SELECT 
    s.uuidsiswa,
    s.nis,
    s.nama_siswa,
    --COALESCE(CAST(SUM(d.nilai) AS TEXT), 'Belum Ujian') AS nilai
    COALESCE(
        CAST(ROUND(SUM(d.nilai)::numeric, 1) AS TEXT),
        'Belum Ujian'
    ) AS nilai
FROM d_siswa s
JOIN (
    -- ambil id_kelas dari ujian header yg dimaksud
    SELECT DISTINCT s2.id_subkelas
    FROM f_jawaban_siswa_hdr h2
    JOIN d_siswa s2 ON s2.uuidsiswa = h2.uuidsiswa
    WHERE h2.id_ujian_hdr = :id_ujian_hdr
) kls ON s.id_subkelas = kls.id_subkelas
LEFT JOIN f_jawaban_siswa_hdr h 
       ON h.uuidsiswa = s.uuidsiswa 
      AND h.id_ujian_hdr = :id_ujian_hdr
LEFT JOIN f_jawaban_siswa_dtl d 
       ON d.id_jawaban_siswa = h.id_jawaban_siswa
GROUP BY s.uuidsiswa, s.nis, s.nama_siswa
ORDER BY s.nama_siswa;
";
$stmt2 = $db->prepare($sql2);
$stmt2->execute([':id_ujian_hdr' => $id_ujian_hdr]);
$rows = $stmt2->fetchAll(PDO::FETCH_ASSOC); // <-- ambil semua baris

// === PDF Setup ===
$pdf = new FPDF('P', 'mm', 'A4');
$pdf->AddPage();
$pdf->SetMargins(10, 10, 10);

// === Title ===
$pdf->SetFont('Arial', 'B', 16);
$pdf->Cell(0, 10, 'Hasil Ujian Siswa', 0, 1, 'C');
$pdf->Ln(2);

// === Logo Centered (cek path logo) ===
$logoPath = '../smadkp.png';
if (file_exists($logoPath)) {
    $pdf->Image($logoPath, 90, $pdf->GetY(), 30);
    $pdf->Ln(45);
} else {
    $pdf->Ln(10);
}

// === Header Layout ===
$pdf->SetFont('Arial', '', 8);
$leftX = 20;
$rightX = 110;

function addFieldRow($pdf, $x, $label, $value, $y = null) {
    if ($y !== null) $pdf->SetY($y);
    $pdf->SetX($x);
    $pdf->Cell(25, 6, $label, 0, 0);
    $pdf->Cell(5, 6, ':', 0, 0);
    $pdf->Cell(60, 6, $value, 0, 1);
}

// Baris header info (kiri & kanan)
$yStart = $pdf->GetY();
addFieldRow($pdf, $leftX, 'Nama Ujian', $nama_ujian, $yStart);



$yStart = $pdf->GetY();
addFieldRow($pdf, $leftX, 'Nama Bab', $nama_bab, $yStart);
addFieldRow($pdf, $rightX, 'Tanggal Ujian', $tanggal_ujian, $yStart);

$yStart = $pdf->GetY();
addFieldRow($pdf, $leftX, 'Kelas', $nama_subkelas, $yStart);
addFieldRow($pdf, $rightX, 'Siswa Ikut Ujian', $jml_siswa_ikut_ujian . ' siswa', $yStart);


$yStart = $pdf->GetY();
addFieldRow($pdf, $leftX, 'Guru Mapel', $nama_guru, $yStart);
addFieldRow($pdf, $rightX, 'Siswa Belum Ujian', $jml_siswa_tidak_ikut_ujian . ' siswa', $yStart);

// === Header Tabel ===
$pdf->Ln(6);
$pdf->SetFont('Arial', 'B', 8);
$pdf->SetFillColor(128, 0, 0); // Maroon
$pdf->SetTextColor(255);

$wKode = 30;
$wNama = 120;
$wNilai = 30;

$pdf->Cell($wKode, 7, 'NIS', 1, 0, 'C', true);
$pdf->Cell($wNama, 7, 'Nama Siswa', 1, 0, 'C', true);
$pdf->Cell($wNilai, 7, 'Nilai', 1, 1, 'C', true);

// === Isi Tabel ===
$pdf->SetFont('Arial', '', 4);
$pdf->SetTextColor(0);

$cellLineHeight = 3.5; // tinggi per baris teks

if (!$rows) {
    // Tidak ada data
    $pdf->Cell($wKode + $wNama + $wNilai, 6, 'Tidak ada data siswa untuk ujian ini.', 1, 1, 'C');
} else {
    foreach ($rows as $row) {
        $nis = $row['nis'] ?? '';
        $nama_siswa_row = $row['nama_siswa'] ?? '';
        $nilai = $row['nilai'] ?? '0';

        $pdf->SetFont('Arial', '', 8);

        // hitung tinggi baris (pakai MultiCell dalam buffer)
        $nb = ceil($pdf->GetStringWidth($nama_siswa_row) / ($wNama - 2));
        if ($nb < 1) $nb = 1;
        $rowHeight = $nb * $cellLineHeight;

        // simpan posisi awal
        $x = $pdf->GetX();
        $y = $pdf->GetY();

        // 1. NIS
        $pdf->Cell($wKode, $rowHeight, $nis, 1, 0, 'C');

        // 2. Nama Siswa (pakai MultiCell, tapi setelah itu kembalikan posisi X)
        $pdf->MultiCell($wNama, $cellLineHeight, $nama_siswa_row, 1, 'L');
        $pdf->SetXY($x + $wKode + $wNama, $y);

        // 3. Nilai
        $pdf->Cell($wNilai, $rowHeight, $nilai, 1, 0, 'C');

        // pindah ke baris berikutnya (ambil Y tertinggi)
        $pdf->Ln($rowHeight);
    }

}

// --- siapkan nama file aman ---
$safe_ujian = trim(preg_replace('/[^\w\s\-]/u', '', $nama_ujian));
$safe_subkelas = trim(preg_replace('/[^\w\s\-]/u', '', $nama_subkelas));
if ($safe_ujian === '') $safe_ujian = 'ujian';
if ($safe_subkelas === '') $safe_subkelas = 'kelas';

$filename = 'Hasil_Ujian_Siswa_' . str_replace(' ', '_', $safe_ujian) . '_' . str_replace(' ', '_', $safe_subkelas) . '.pdf';

// Bersihkan output buffer jika ada (untuk menghindari error FPDF)
if (ob_get_length()) {
    ob_end_clean();
}

// Output PDF
$pdf->Output('I', $filename);
exit;
