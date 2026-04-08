<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        $nis = $_POST['nis'];
        $nisn = $_POST['nisn'];
        //$tanggal_lahir = $_POST['tanggal_lahir'];
        $gender = $_POST['gender'];
        $nama_siswa = $_POST['nama_siswa'];
        $id_kelas = $_POST['id_kelas'];
        $id_subkelas = $_POST['id_subkelas'];
        $sql5 = "SELECT COUNT(1) cek_dobel from d_siswa where nis = '$nis'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_siswa.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO d_siswa (nisn, nis, nama_siswa, gender, st_active, kode_tahun_ajaran, id_kelas, id_subkelas) 
            VALUES (:nisn, :nis, :nama_siswa, :gender, 'Y', '2526', :id_kelas, :id_subkelas)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['nisn' => $nisn, 'nis' => $nis, 'nama_siswa' => $nama_siswa, 'gender' => $gender, 'id_kelas' => $id_kelas, 'id_subkelas' => $id_subkelas]);
        
            header('location:data_master_siswa.php');
        }
?>