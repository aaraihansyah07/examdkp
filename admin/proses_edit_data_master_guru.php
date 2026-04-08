<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $uuidguru = $_POST['uuidguru'];
        $nama_guru = $_POST['nama_guru'];
        $nip = $_POST['nip'];
        //$kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];
        $gender = $_POST['gender'];
        //$tanggal_lahir = $_POST['tanggal_lahir'];

        // $sql5 = "SELECT COUNT(1) cek_dobel from d_guru where nip = '$nip'";
        // $hasil5 = $db->query($sql5);
        // $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        // if ($baris5['cek_dobel'] > 0) {
        //     header('location:data_master_guru.php?dct=Y');
        // }

        $sql4 = "UPDATE d_guru set nip = '$nip', gender = '$gender', 
        nama_guru = '$nama_guru'
        where uuidguru = :uuidguru";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['uuidguru' => $uuidguru]);

        header('location:data_master_guru.php?e=Y');
    }
?>