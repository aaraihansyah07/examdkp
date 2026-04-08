<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        
        include('config.php');
        $uuidpenempatanmapel = $_POST['uuidpenempatanmapel'];
        $uuidguru = $_POST['uuidguru'];

        $sql2b = "SELECT kode_guru from d_guru where uuidguru = '$uuidguru'";
        $hasil2b = $db->query($sql2b);
        $baris2b = $hasil2b->fetch(PDO::FETCH_ASSOC);
        
        $kode_guru = $baris2b['kode_guru'];
        $kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];
        //$tanggal_lahir = $_POST['tanggal_lahir'];

        // $sql5 = "SELECT COUNT(1) cek_dobel from d_guru where nip = '$nip'";
        // $hasil5 = $db->query($sql5);
        // $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        // if ($baris5['cek_dobel'] > 0) {
        //     header('location:data_master_guru.php?dct=Y');
        // }

        $sql4 = "UPDATE d_penempatan_mapel_guru set uuidguru = '$uuidguru', kode_mata_pelajaran = '$kode_mata_pelajaran', kode_guru = '$kode_guru'
        where uuidpenempatanmapel = :uuidpenempatanmapel";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['uuidpenempatanmapel' => $uuidpenempatanmapel]);

        header('location:data_master_guru_per_mapel.php?e=Y');
    }
?>