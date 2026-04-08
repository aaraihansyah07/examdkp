<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        $id_kelas = $_POST['id_kelas'];
        $nama_subkelas = $_POST['nama_subkelas'];
        
        $sql5 = "SELECT COUNT(1) cek_dobel from d_subkelas where nama_subkelas = '$nama_subkelas'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:data_master_subkelas.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO d_subkelas (id_kelas, nama_subkelas) 
            VALUES (:id_kelas, :nama_subkelas)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['nama_subkelas' => $nama_subkelas, 'id_kelas' => $id_kelas]);
        
            header('location:data_master_subkelas.php');
        }
?>