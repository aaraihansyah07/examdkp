<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $id_subkelas = $_POST['id_subkelas'];
        $nama_subkelas = $_POST['nama_subkelas'];

        $sql5 = "SELECT COUNT(1) cek_dobel from d_subkelas where nama_subkelas = '$nama_subkelas'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_subkelas.php?dct=Y');
        }
        else {
            $sql4 = "UPDATE d_subkelas set nama_subkelas = '$nama_subkelas' where id = :id_subkelas";
            $stmt4 = $db->prepare($sql4);
            $stmt4->execute(['id_subkelas' => $id_subkelas]);

            header('location:data_master_subkelas.php?e=Y');
        }
    }
?>