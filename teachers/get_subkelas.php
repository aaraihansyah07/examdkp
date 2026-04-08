<?php
// get_subkelas.php
require 'config.php'; // pastikan koneksi DB sudah dibuat

header('Content-Type: application/json');

if (isset($_GET['nama_kelas'])) {
    $nama_kelas = $_GET['nama_kelas'];

    $stmt = $db->prepare("SELECT id, nama_subkelas FROM d_subkelas WHERE nama_kelas = ? ORDER BY nama_subkelas");
    $stmt->execute([$nama_kelas]);

    $subkelas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($subkelas);
} else {
    echo json_encode([]);
}
