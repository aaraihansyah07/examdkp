<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $id_kelas = $_POST['id_kelas'];

    echo $id_kelas;

    $sql6 = "DELETE from d_kelas where id = :id_kelas";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['id_kelas' => $id_kelas]);

    header('location:data_master_kelas.php?h=Y');
?>