<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        $kode_jenis_ujian = $_POST['kode_jenis_ujian'];
        $nama_jenis_ujian = $_POST['nama_jenis_ujian'];
        
        $sql5 = "SELECT COUNT(1) cek_dobel from d_jenis_ujian where kode_jenis_ujian = '$kode_jenis_ujian'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_jenis_ujian.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO d_jenis_ujian (kode_jenis_ujian, nama_jenis_ujian) 
            VALUES (:kode_jenis_ujian, :nama_jenis_ujian)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['kode_jenis_ujian' => $kode_jenis_ujian, 'nama_jenis_ujian' => $nama_jenis_ujian]);
        
            header('location:data_master_jenis_ujian.php');
        }
?>