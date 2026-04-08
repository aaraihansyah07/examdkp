<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $kode_guru = $_POST['kode_guru'];

    $sql6 = "DELETE from users where uname = :uname";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['uname' => $kode_guru]);

    header('location:manajemen_akun_guru.php?h=Y');
?>