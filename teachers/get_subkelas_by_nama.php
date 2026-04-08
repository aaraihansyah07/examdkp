<?php
// get_subkelas.php
require 'config.php'; // pastikan koneksi DB sudah dibuat

header('Content-Type: application/json');

if (isset($_GET['nama_kelas'])) {
    $nama_kelas = $_GET['nama_kelas'];
    
    $sql = "SELECT id from d_kelas where nama_kelas = '$nama_kelas'";
    $hasil = $db->query($sql);
    $baris = $hasil->fetch(PDO::FETCH_ASSOC);
    $id_kelas = $baris['id'];

    $stmt = $db->prepare("SELECT id, nama_subkelas FROM d_subkelas WHERE id_kelas = ? ORDER BY nama_subkelas");
    $stmt->execute([$id_kelas]);

    $subkelas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($subkelas);
} else {
    echo json_encode([]);
}
