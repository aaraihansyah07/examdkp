<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $kode_jenis_ujian = $_POST['kode_jenis_ujian'];

    $sql6 = "DELETE from d_jenis_ujian where kode_jenis_ujian = :kode_jenis_ujian";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['kode_jenis_ujian' => $kode_jenis_ujian]);

    header('location:data_master_jenis_ujian.php?h=Y');
?>