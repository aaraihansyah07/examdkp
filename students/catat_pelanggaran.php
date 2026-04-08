<?php
require 'config.php';
session_start();

$uuidsiswa = $_POST['uuidsiswa'] ?? null;
$id_ujian_hdr = $_POST['id_ujian_hdr'] ?? null;

if (!$uuidsiswa || !$id_ujian_hdr) {
    echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap']);
    exit;
}

try {
    $sql = "UPDATE f_jawaban_siswa_hdr 
            SET pelanggaran_count = pelanggaran_count + 1
            WHERE uuidsiswa = :uuidsiswa AND id_ujian_hdr = :id_ujian_hdr";
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':uuidsiswa' => $uuidsiswa,
        ':id_ujian_hdr' => $id_ujian_hdr
    ]);

    // Ambil nilai terbaru setelah update
    $row = $db->query("SELECT pelanggaran_count 
                       FROM f_jawaban_siswa_hdr 
                       WHERE uuidsiswa = '$uuidsiswa' 
                       AND id_ujian_hdr = '$id_ujian_hdr'")
              ->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'pelanggaran_count' => $row['pelanggaran_count']
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
