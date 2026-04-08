<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $user_update = $_SESSION['uname'];
        date_default_timezone_set("Asia/Jakarta");
        $now = date("Y-m-d H:i:s");
        $date_now = date("Y-m-d");

        $id_param = $_POST['id_param'];
        $jatah_pelanggaran = $_POST['jatah_pelanggaran'];
        $durasi_toleransi_idle = $_POST['durasi_toleransi_idle'];

        $sql4 = "UPDATE d_parameter_ujian set jatah_pelanggaran = $jatah_pelanggaran, 
        durasi_toleransi_idle = $durasi_toleransi_idle, updateuser = '$user_update', updatedate = '$now'
        where id_param = :id_param";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['id_param' => $id_param]);

        header('location:data_master_parameter.php?e=Y');
     }
?>