<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $nama_kelas = $_POST['nama_kelas'];
    $sql6 = "INSERT INTO d_kelas (nama_kelas) 
    VALUES (:nama_kelas)";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['nama_kelas' => $nama_kelas]);

    header('location:data_master_kelas.php');
?>