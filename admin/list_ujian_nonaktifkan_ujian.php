<?php
    require 'config.php';
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    $id_ujian_hdr = $_POST['id_ujian_hdr'];
    $user_update = $_SESSION['uname'];
    date_default_timezone_set("Asia/Jakarta");
    $now = date("Y-m-d H:i:s");
    $date_now = date("Y-m-d");
    $mp = $_POST['mp'];
    $kls = $_POST['kls'];
    $ju = $_POST['ju'];

    $sql4 = "UPDATE f_soal_hdr set st_nonaktif_ujian = 'Y', updateuser = :user_update, updatedate = :updatedate, userposting = :userposting where id_ujian_hdr = :id_ujian_hdr";
    $stmt4 = $db->prepare($sql4);
    $stmt4->execute(['id_ujian_hdr' => $id_ujian_hdr, 'user_update' => $user_update, 'updatedate' => $now, 'userposting' => $user_update]);

    echo "<script>alert('Soal ujian berhasil dinonaktifkan!'); window.location.href='list_ujian_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";

?>