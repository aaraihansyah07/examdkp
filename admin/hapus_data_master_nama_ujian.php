<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $id_ujian = $_POST['id_ujian'];

    $sql6 = "DELETE from d_ujian where id_ujian = :id_ujian";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['id_ujian' => $id_ujian]);

    header('location:data_master_nama_ujian.php?h=Y');
?>