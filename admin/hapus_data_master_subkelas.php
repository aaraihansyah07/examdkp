<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $id_subkelas = $_POST['id_subkelas'];

    $sql6 = "DELETE from d_subkelas where id = :id_subkelas";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['id_subkelas' => $id_subkelas]);

    header('location:data_master_subkelas.php?h=Y');
?>