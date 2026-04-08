<?php
// get_subkelas.php
require 'config.php'; // pastikan koneksi DB sudah dibuat

header('Content-Type: application/json');

if (isset($_GET['kode_mata_pelajaran'])) {
    $kode_mata_pelajaran = $_GET['kode_mata_pelajaran'];

    $stmt = $db->prepare("SELECT id_ujian, nama_ujian FROM d_ujian WHERE kode_mata_pelajaran = ?");
    $stmt->execute([$kode_mata_pelajaran]);

    $ujian_by_mapel = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($ujian_by_mapel);
} else {
    echo json_encode([]);
}
