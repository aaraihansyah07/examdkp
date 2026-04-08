<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        $nisn = $_POST['nisn'];
        $uuidsiswa = $_POST['uuidsiswa'];
        $nama_siswa = $_POST['nama_siswa'];
        $nis = $_POST['nis'];
        $id_kelas = $_POST['id_kelas'];
        $id_subkelas = $_POST['id_subkelas'];
        $gender = $_POST['gender'];
        //$tanggal_lahir = $_POST['tanggal_lahir'];

        $sql4 = "UPDATE d_siswa set nisn = '$nisn', nis = '$nis', nama_siswa = '$nama_siswa', gender = '$gender', 
        id_kelas = $id_kelas, id_subkelas = $id_subkelas
        where uuidsiswa = :uuidsiswa";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['uuidsiswa' => $uuidsiswa]);

        header('location:data_master_siswa.php?e=Y');
    }
?>