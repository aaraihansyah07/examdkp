<?php
    if (isset($_POST['edit_akun'])) {
        session_start();
        if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
            header('location:../login.php');
        }
        include('config.php');
        session_start();
        $user_update = $_SESSION['uname'];

        $nis = $_POST['nis'];
        $pword = $_POST['pword'];
        
        $salt = base64_encode(random_bytes(16));
        $hashed_pw = crypt($pword, '$2y$10$' . substr(strtr($salt, '+', '.'), 0, 22)); // $2y$10$ = bcrypt cost 10
        date_default_timezone_set("Asia/Jakarta");
        $now = new DateTime();
        $now = $now->format("Y-m-d h:i:s"); 

        $sql4 = "UPDATE users set pword = '$hashed_pw', updatedate = '$now', updateuser = '$user_update', st_generate = null
        where uname = :uname and role='2'";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['uname' => $nis]);

        header('location:manajemen_akun_siswa.php?e=Y');
    }
?>