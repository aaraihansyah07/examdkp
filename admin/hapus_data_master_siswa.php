<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    $uuidsiswa = $_POST['uuidsiswa'];

    $sql = "SELECT nis from d_siswa where uuidsiswa = '$uuidsiswa'";
    $hasil = $db->query($sql);
    $baris = $hasil->fetch(PDO::FETCH_ASSOC);
    $nis = $baris['nis'];

    $sql6 = "DELETE from d_siswa where uuidsiswa = :uuidsiswa";
    $stmt6 = $db->prepare($sql6);
    $stmt6->execute(['uuidsiswa' => $uuidsiswa]);

    $sql2 = "DELETE from users where uname = :nis and role = '2'";
    $stmt2 = $db->prepare($sql2);
    $stmt2->execute(['nis' => $nis]);

    header('location:data_master_siswa.php?h=Y');
?>