<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    session_start();
    $user_create = $_SESSION['uname'];

    $uname = $_POST['uname'];
    $fname = $_POST['fname'];
    $pword = $_POST['pword'];

    $uname = strtolower($uname);

    $salt = base64_encode(random_bytes(16));
    $hashed_pw = crypt($pword, '$2y$10$' . substr(strtr($salt, '+', '.'), 0, 22));
    
    $sql5 = "SELECT COUNT(1) cek_dobel from users where uname = '$uname' and role = '3'";
    $hasil5 = $db->query($sql5);
    $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

    if ($baris5['cek_dobel'] > 0) {
        header('location:manajemen_akun_admin.php?dct=Y');
    }
    else {
        $sql6 = "INSERT INTO users (uname, fname, pword, createuser, role) 
        VALUES (:uname, :fname, :pword, :user_create, '3')";
        $stmt6 = $db->prepare($sql6);
        $stmt6->execute(['uname' => $uname, 'fname' => $fname, 'pword' => $hashed_pw, 'user_create' => $user_create]);

        header('location:manajemen_akun_admin.php');
    }
?>