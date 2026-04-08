<?php
    if (isset($_POST['ganti_password'])) {
        include('config.php');
        session_start();
        $user_update = $_SESSION['uname'];
       
        $password_baru = $_POST['password_baru'];
        
        $salt = base64_encode(random_bytes(16));
        $hashed_pw = crypt($password_baru, '$2y$10$' . substr(strtr($salt, '+', '.'), 0, 22)); // $2y$10$ = bcrypt cost 10
        date_default_timezone_set("Asia/Jakarta");
        $now = new DateTime();
        $now = $now->format("Y-m-d h:i:s"); 

        $sql4 = "UPDATE users set pword = '$hashed_pw', updatedate = '$now', updateuser = '$user_update'
        where uname = :uname and role='1'";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['uname' => $user_update]);

        echo "<script>alert('Password berhasil diganti'); window.location.href='dashboard.php';</script>";
    }
?>