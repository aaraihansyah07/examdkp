<?php
// get_subkelas.php
require 'config.php'; // pastikan koneksi DB sudah dibuat

header('Content-Type: application/json');

if (isset($_GET['kode_mata_pelajaran'])) {
    $kode_mata_pelajaran = $_GET['kode_mata_pelajaran'];

    $stmt = $db->prepare("SELECT g.uuidguru, g.nama_guru FROM d_guru g
    left join d_penempatan_mapel_guru pg on pg.uuidguru = g.uuidguru
    WHERE pg.kode_mata_pelajaran = ?");
    $stmt->execute([$kode_mata_pelajaran]);

    $guru_by_mapel = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($guru_by_mapel);
} else {
    echo json_encode([]);
}
