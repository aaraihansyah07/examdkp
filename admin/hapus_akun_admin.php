<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $uname = $_POST['uname'];

    $sql6 = "DELETE from users where uname = :uname";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['uname' => $uname]);

    header('location:manajemen_akun_admin.php?h=Y');
?>