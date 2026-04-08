<?php
    $host = "localhost";
    $user_db = "postgres";
    $pass = "1234";
    $port = "5432";
    $dbname = "db_exam";

    $db = new PDO("pgsql:dbname=$dbname; host=$host", $user_db, $pass);

    function getUserIP() {
        // Cek apakah pengguna menggunakan proxy atau load balancer
        if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
            // IP dari shared internet
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            // IP dari proxy atau load balancer
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        } else {
            // IP langsung dari remote address
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        return $ip;
    }
    $ip_address = getUserIP();
?>