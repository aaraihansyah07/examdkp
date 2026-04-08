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
    $mp = $_POST['mp'];
    $kls = $_POST['kls'];
    $ju = $_POST['ju'];


    $sql5 = "SELECT COUNT(1) AS cek_kosong
    FROM f_soal_dtl
    WHERE id_ujian_hdr = $id_ujian_hdr
    AND (
        trim(REGEXP_REPLACE(isi_soal, '<[^>]+>', '', 'g')) = '' OR
        trim(REGEXP_REPLACE(option_a, '<[^>]+>', '', 'g')) = '' OR
        trim(REGEXP_REPLACE(option_b, '<[^>]+>', '', 'g')) = '' OR
        trim(REGEXP_REPLACE(option_c, '<[^>]+>', '', 'g')) = '' OR
        trim(REGEXP_REPLACE(option_d, '<[^>]+>', '', 'g')) = '' OR
        trim(REGEXP_REPLACE(option_e, '<[^>]+>', '', 'g')) = '' OR
        trim(REGEXP_REPLACE(kunci_jawaban, '<[^>]+>', '', 'g')) = ''
    );
    ";
    $hasil5 = $db->query($sql5);
    $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);
    $cek_kosong = $baris5['cek_kosong'];

    if ($cek_kosong > 0) {
         echo "<script>alert('Tidak dapat diposting karena masih ada isi soal/option/kunci jawaban yang masih kosong, silakan cek kembali!'); window.location.href='list_ujian_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
    }

    else {
        $sql4 = "UPDATE f_soal_hdr set st_posting = 'Y', updateuser = :user_update, updatedate = :updatedate, userposting = :userposting where id_ujian_hdr = :id_ujian_hdr";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['id_ujian_hdr' => $id_ujian_hdr, 'user_update' => $user_update, 'updatedate' => $now, 'userposting' => $user_update]);

        echo "<script>alert('Ujian berhasil diposting!'); window.location.href='list_ujian_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
    }

?>