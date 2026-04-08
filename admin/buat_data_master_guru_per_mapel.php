<?php
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $uuidguru = $_POST['uuidguru'];
        //$tanggal_lahir = $_POST['tanggal_lahir'];
        $kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];

        $sql6 = "SELECT kode_guru from d_guru where uuidguru = '$uuidguru'";
        $hasil6 = $db->query($sql6);
        $baris6 = $hasil6->fetch(PDO::FETCH_ASSOC);
        $kode_guru = $baris6['kode_guru'];

        $sql5 = "SELECT COUNT(1) cek_dobel from d_penempatan_mapel_guru where uuidguru = '$uuidguru' AND kode_mata_pelajaran = '$kode_mata_pelajaran'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_guru_per_mapel.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO d_penempatan_mapel_guru (uuidguru, kode_guru, kode_mata_pelajaran) 
            VALUES (:uuidguru, :kode_guru, :kode_mata_pelajaran)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['uuidguru' => $uuidguru, 'kode_guru' => $kode_guru, 'kode_mata_pelajaran' => $kode_mata_pelajaran]);
        
            header('location:data_master_guru_per_mapel.php');
        }
?>