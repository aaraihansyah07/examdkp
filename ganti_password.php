<?php
    if (isset($_POST['ganti_password'])) {
        include('config.php');
        $id_user = $_POST['id_user'];
        $new_pw = $_POST['new_pw'];

        $sql = "UPDATE users set pword = '$new_pw' where id = $id_user";
        $hasil = mysqli_query($koneksi, $sql);
    }
    header('location:dashboard.php');
?>