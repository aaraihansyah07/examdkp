<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $id_ujian_hdr = $_POST['id_ujian_hdr'];

    $sqlb = "SELECT st_posting from f_soal_hdr where id_ujian_hdr = $id_ujian_hdr";
    $hasilb = $db->query($sqlb);
    $barisb = $hasilb->fetch(PDO::FETCH_ASSOC);

    $mp = $_POST['mp'];
    $ju = $_POST['ju'];
    $kls = $_POST['kls'];

    $loc = "mp=".$mp."&kls=".$kls."&ju=".$ju;
    $loc2 = "h=Y&mp=".$mp."&kls=".$kls."&ju=".$ju;

    if ($barisb['st_posting'] == 'Y') {
        echo "<script>alert('Ujian ini tidak bisa dihapus karena sudah pernah diposting sebelumnya'); window.location.href='list_ujian.php?".$loc."';</script>";
    }
    else {
        $sql6 = "DELETE from f_soal_dtl where id_ujian_hdr = :id_ujian_hdr";
        $stmt6 = $db->prepare($sql6);
        $stmt6->execute(['id_ujian_hdr' => $id_ujian_hdr]);

        $sql7 = "DELETE from f_soal_hdr where id_ujian_hdr = :id_ujian_hdr";
        $stmt7 = $db->prepare($sql7);
        $stmt7->execute(['id_ujian_hdr' => $id_ujian_hdr]);
        header('location:list_ujian.php?'.$loc2);
    }

?>