<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        $nip = $_POST['nip'];
        //$tanggal_lahir = $_POST['tanggal_lahir'];
        $gender = $_POST['gender'];
        $nama_guru = $_POST['nama_guru'];
        //$kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];
        $sql5 = "SELECT COUNT(1) cek_dobel from d_guru where nip = '$nip'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_guru.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO d_guru (nip, nama_guru, tanggal_lahir, gender) 
            VALUES (:nip, :nama_guru, :tanggal_lahir, :gender)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['nip' => $nip, 'nama_guru' => $nama_guru, 'tanggal_lahir' => $tanggal_lahir, 'gender' => $gender]);
        
            header('location:data_master_guru.php');
        }
?>