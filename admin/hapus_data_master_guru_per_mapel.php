<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $uuidpenempatanmapel = $_POST['uuidpenempatanmapel'];
    //echo $uuidpenempatanmapel;
    $sql6 = "DELETE from d_penempatan_mapel_guru where uuidpenempatanmapel = :uuidpenempatanmapel";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['uuidpenempatanmapel' => $uuidpenempatanmapel]);

    header('location:data_master_guru_per_mapel.php?h=Y');
?>