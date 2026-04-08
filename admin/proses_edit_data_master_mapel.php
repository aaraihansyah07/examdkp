<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $id_mata_pelajaran = $_POST['id_mata_pelajaran'];
        $kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];
        $nama_mata_pelajaran = $_POST['nama_mata_pelajaran'];

        $sql4 = "UPDATE d_mata_pelajaran set kode_mata_pelajaran = '$kode_mata_pelajaran', 
        nama_mata_pelajaran = '$nama_mata_pelajaran'
        where id = :id_mata_pelajaran";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['id_mata_pelajaran' => $id_mata_pelajaran]);

        header('location:data_master_mapel.php?e=Y');
     }
?>