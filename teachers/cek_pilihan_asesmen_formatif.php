<?php
    if (isset($_POST['buat_akun'])) {
        $jenis = $_POST['jenis'];

        if ($jenis == 'S') {
            header('location:buat_asesmen_formatif_pilih_rubrik.php');
        }
    }
?>