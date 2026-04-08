<?php
    $host = "localhost";
    $user_db = "postgres";
    $pass = "1234";
    $port = "5432";
    $dbname = "db_exam";

    $db = new PDO("pgsql:dbname=$dbname; host=$host", $user_db, $pass);
?>