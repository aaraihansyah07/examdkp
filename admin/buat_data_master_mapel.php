<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        $kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];
        $nama_mata_pelajaran = $_POST['nama_mata_pelajaran'];

        $sql5 = "SELECT COUNT(1) cek_dobel from d_mata_pelajaran where kode_mata_pelajaran = '$kode_mata_pelajaran'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_mapel.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO d_mata_pelajaran (kode_mata_pelajaran, nama_mata_pelajaran) 
            VALUES (:kode_mata_pelajaran, :nama_mata_pelajaran)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['kode_mata_pelajaran' => $kode_mata_pelajaran, 'nama_mata_pelajaran' => $nama_mata_pelajaran]);
        
            header('location:data_master_mapel.php');
        }
?>