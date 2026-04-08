<?php
// get_subkelas.php
require 'config.php'; // pastikan koneksi DB sudah dibuat

header('Content-Type: application/json');

if (isset($_GET['id_subkelas'])) {
    $id_subkelas = $_GET['id_subkelas'];

    $stmt = $db->prepare("SELECT nis, nama_siswa FROM d_siswa s
    WHERE id_subkelas = ? 
    AND not exists 
    (select 1 from users u where u.uname = s.nis)
    ORDER BY nama_siswa");
    $stmt->execute([$id_subkelas]);

    $siswa = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($siswa);
} else {
    echo json_encode([]);
}
