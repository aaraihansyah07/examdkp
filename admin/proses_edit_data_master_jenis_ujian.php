<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $kode_jenis_ujian = $_POST['kode_jenis_ujian'];
        $nama_jenis_ujian = $_POST['nama_jenis_ujian'];

        $sql4 = "UPDATE d_jenis_ujian set nama_jenis_ujian = '$nama_jenis_ujian' where kode_jenis_ujian = :kode_jenis_ujian";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['kode_jenis_ujian' => $kode_jenis_ujian]);

        header('location:data_master_jenis_ujian.php?e=Y');
    }
?>