<?php
    include('config.php');
    $exid = $_GET['exid'];
    $sqlb = "SELECT status_assign from exm_list where exid = $exid";
    $hasilb = mysqli_query($koneksi, $sqlb);
    $barisb = mysqli_fetch_array($hasilb);

    if ($barisb['status_assign'] == 'Y') {
        echo "<script>window.alert('Asesmen ini sudah diassign, tidak bisa dihapus')</script>";
    }
    else {
        $sql = "DELETE FROM exm_list where exid = $exid";
        $hasil = mysqli_query($koneksi, $sql);
    
        $sql2 = "DELETE FROM tmp_detail_soal_diagnostik WHERE EXID = $exid";
        $hasil = mysqli_query($koneksi, $sql2);
        
        header('location:asesmen_diagnostik.php');
    }
?>