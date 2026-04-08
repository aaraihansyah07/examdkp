<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
        $jenis_ujian = $_POST['jenis_ujian'];
        $semester = $_POST['semester'];
        $kode_tahun_ajaran = $_POST['kode_tahun_ajaran'];
        $kode_mata_pelajaran = $_POST['kode_mata_pelajaran'];

        foreach ($kode_mata_pelajaran as $mp) {
            $sqlb = "SELECT nama_mata_pelajaran from d_mata_pelajaran where kode_mata_pelajaran = '$mp'";
            $hasilb = $db->query($sqlb);
            $barisb = $hasilb->fetch(PDO::FETCH_ASSOC); 
            $nama_mata_pelajaran = $barisb['nama_mata_pelajaran'];

            $sqlc = "SELECT nama_tahun_ajaran from d_tahun_ajaran where kode_tahun_ajaran = '$kode_tahun_ajaran'";
            $hasilc = $db->query($sqlc);
            $barisc = $hasilc->fetch(PDO::FETCH_ASSOC); 
            $nama_tahun_ajaran = $barisc['nama_tahun_ajaran'];
            
            $kode_ujian = $jenis_ujian.'.'.$mp.'.SMT'.$semester.'.'.$kode_tahun_ajaran;
            $nama_ujian = $jenis_ujian.' '.$nama_mata_pelajaran.' Semester '. $semester. ' '. $nama_tahun_ajaran;

            $sql5 = "SELECT COUNT(1) cek_dobel from d_ujian where kode_ujian = '$kode_ujian'";
            $hasil5 = $db->query($sql5);
            $baris5 = $hasil5->fetch(PDO::FETCH_ASSOC);

            if ($baris5['cek_dobel'] < 1) {
                  $sql6 = "INSERT INTO d_ujian (kode_ujian, nama_ujian, jenis_ujian, semester, kode_tahun_ajaran, kode_mata_pelajaran) 
                  VALUES (:kode_ujian, :nama_ujian, :jenis_ujian, :semester, :kode_tahun_ajaran, :mp)";
                  $stmt6 = $db->prepare($sql6);
                  $stmt6->execute(['kode_ujian' => $kode_ujian, 'nama_ujian' => $nama_ujian, 'jenis_ujian' => $jenis_ujian, 'semester' => $semester, 'kode_tahun_ajaran' => $kode_tahun_ajaran, 'mp' => $mp]);
            }        
        }
        header('location:data_master_nama_ujian.php');
?>