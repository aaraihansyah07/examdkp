<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        session_start();
        $user_create = $_SESSION['uname'];
        $kode_guru = $_POST['kode_guru'];
        $pword = $_POST['pword'];

        $salt = base64_encode(random_bytes(16));
        $hashed_pw = crypt($pword, '$2y$10$' . substr(strtr($salt, '+', '.'), 0, 22)); // $2y$10$ = bcrypt cost 10

        $sql5b = "SELECT nama_guru from d_guru where kode_guru = '$kode_guru'";
        $hasil5b = $db->query($sql5b);
        $baris5b = $hasil5b->fetch(PDO::FETCH_ASSOC);
        $nama_siswa = $baris5b['nama_guru'];
        
        $sql5 = "SELECT COUNT(1) cek_dobel from users where uname = '$kode_guru'";
        $hasil5 = $db->query($sql5);
        $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

        if ($baris5['cek_dobel'] > 0) {
            header('location:manajemen_akun_guru.php?dct=Y');
        }
        else{
            $sql6 = "INSERT INTO users (uname, pword, fname, role, createuser) 
            VALUES (:kode_guru, :pword, :fname, '1', :user_create)";
            $stmt6 = $db->prepare($sql6);
            $stmt6->execute(['kode_guru' => $kode_guru, 'pword' => $hashed_pw, 'fname' => $nama_siswa, 'user_create' => $user_create]);
        
            header('location:manajemen_akun_guru.php');
        }
?>