<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $exid = $_GET['exid'];
    $sql = "DELETE FROM exm_list where exid = $exid";
    $hasil = mysqli_query($koneksi, $sql);

    $sql2 = "DELETE FROM tmp_detail_soal_diagnostik WHERE EXID = $exid";
    $hasil = mysqli_query($koneksi, $sql2);
    
    header('location:asesmen_diagnostik.php');
?>