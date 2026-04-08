<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $id_mata_pelajaran = $_POST['id_mata_pelajaran'];

    $sql6 = "DELETE from d_mata_pelajaran where id = :id_mata_pelajaran";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['id_mata_pelajaran' => $id_mata_pelajaran]);

    header('location:data_master_mapel.php?h=Y');
?>