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

    $sql5b = "SELECT tanggal_ujian from f_soal_hdr where id_ujian_hdr = $id_ujian_hdr";
    $hasil5b = $db->query($sql5b);
    $baris5b = $hasil5b->fetch(PDO::FETCH_ASSOC);

    $tanggal_ujian = $baris5b['tanggal_ujian'];

    if ($date_now < $tanggal_ujian) {
        $sql4 = "UPDATE f_soal_hdr set st_posting = null, updateuser = :user_update, updatedate = :updatedate, userposting = :userposting where id_ujian_hdr = :id_ujian_hdr";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['id_ujian_hdr' => $id_ujian_hdr, 'user_update' => $user_update, 'updatedate' => $now, 'userposting' => $user_update]);

        echo "<script>alert('Soal ujian berhasil dijadikan draft kembali!'); window.location.href='list_ujian_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
    }
    else {
         echo "<script>alert('Tidak dapat dijadikan draft kembali karena sudah melebihi atau sama dengan tanggal ujian'); window.location.href='list_ujian_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
    }

?>