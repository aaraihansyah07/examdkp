<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $uuidguru = $_POST['uuidguru'];

    $sql = "SELECT kode_guru from d_guru where uuidguru = '$uuidguru'";
    $hasil = $db->query($sql);
    $baris = $hasil->fetch(PDO::FETCH_ASSOC);
    $kode_guru = $baris['kode_guru'];

    $sql7 = "DELETE from d_penempatan_mapel_guru where uuidguru = :uuidguru";
    $stmt7 = $db->prepare($sql7);
    $stmt7->execute(['uuidguru' => $uuidguru]);

    $sql6 = "DELETE from d_guru where uuidguru = :uuidguru";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['uuidguru' => $uuidguru]);

    $sql2 = "DELETE from users where uname = :kode_guru and role = '1'";
    $stmt2 = $db->prepare($sql2);
    $stmt2->execute(['kode_guru' => $kode_guru]);

    header('location:data_master_guru.php?h=Y');
?>