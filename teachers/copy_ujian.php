<?php
    require 'config.php';
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '1') {
        header('location:../login.php');
    }
    $id_ujian_hdr = $_POST['id_ujian_hdr'];
    $id_kelas = $_POST['id_kelas'];
    $st_susulan_copy = $_POST['st_susulan_copy'];
    $user_create = $_SESSION['uname'];

    $mp = $_POST['mp'];
    $kls = $_POST['kls'];
    $ju = $_POST['ju'];
    // $sk = $_POST['sk'];
    
    function generate_token($length = 7) {
        $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // hindari O, I, 1, 0
        $token = '';
        for ($i = 0; $i < $length; $i++) {
            $token .= $chars[random_int(0, strlen($chars) - 1)];
        }
        return $token;
    }


    if (!isset($_POST['id_subkelas'])) {
        echo "<script>alert('Pilih subkelas yang dituju untuk dicopy!'); window.location.href='daftar_ujian_saya_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
    }

    else {
        $id_subkelas = $_POST['id_subkelas'];
        
        foreach ($id_subkelas as $subkelas) {
            $sql6 = "SELECT nextval('seq_soal_hdr') seq_soal_hdr;";
            $hasil6 = $db->query($sql6);
            $baris6 = $hasil6->fetch(PDO::FETCH_ASSOC);
            $seq_soal_hdr = $baris6['seq_soal_hdr'];
            $token = generate_token();

            $sql6b = "SELECT id_ujian, id_kelas, kode_mata_pelajaran, nama_bab from f_soal_hdr where id_ujian_hdr = $id_ujian_hdr";
            $hasil6b = $db->query($sql6b);
            $baris6b = $hasil6b->fetch(PDO::FETCH_ASSOC);
            $id_ujian_sumber = $baris6b['id_ujian'];
            $id_kelas_sumber = $baris6b['id_kelas'];
            $kode_mata_pelajaran_sumber = $baris6b['kode_mata_pelajaran'];
            $nama_bab_sumber = $baris6b['nama_bab'];

            $sql6c = "SELECT count(1) cek_ada from f_soal_hdr 
            where id_ujian = $id_ujian_sumber AND id_kelas = $id_kelas_sumber
            AND kode_mata_pelajaran = '$kode_mata_pelajaran_sumber' AND nama_bab = '$nama_bab_sumber' AND id_subkelas = $subkelas AND st_susulan = '$st_susulan_copy'";
            $hasil6c = $db->query($sql6c);
            $baris6c = $hasil6c->fetch(PDO::FETCH_ASSOC);

            if ($baris6c['cek_ada'] > 0) {
                echo "<script>alert('Ada ujian yang sudah pernah dibuat sebelumnya pada kelas yang dituju, silakan cek kembali daftar ujian yang sudah dibuat'); window.location.href='daftar_ujian_saya_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
                exit;
            }
            
            // Simpan header ujian
            $stmt = $db->prepare("INSERT INTO f_soal_hdr (st_susulan, token, durasi, id_ujian_hdr, kode_mata_pelajaran, kode_guru, uuidguru, id_kelas, kode_ujian, waktu_mulai, waktu_berakhir, nama_bab, id_ujian, id_subkelas, createuser, tanggal_ujian, soal_acak, option_acak) 
                                SELECT :st_susulan, :token, durasi, :seq_soal_hdr, kode_mata_pelajaran, kode_guru, uuidguru, :id_kelas, kode_ujian, waktu_mulai, waktu_berakhir, nama_bab, id_ujian, :subkelas, :user_create, tanggal_ujian, soal_acak, option_acak
                                FROM f_soal_hdr WHERE id_ujian_hdr = :id_ujian_hdr");
            $stmt->execute([
                ':st_susulan' => $st_susulan_copy,
                ':token' => $token,
                ':seq_soal_hdr' => $seq_soal_hdr,
                ':id_ujian_hdr' => $id_ujian_hdr,
                ':id_kelas' => $id_kelas,
                ':subkelas' => $subkelas,
                ':user_create' => $user_create
            ]);
            
            $stmt2 = $db->prepare("INSERT INTO f_soal_dtl (id_ujian_hdr, option_a, option_b, option_c, option_d, option_e, option_a_unicode, option_b_unicode, option_c_unicode, option_d_unicode, option_e_unicode, kunci_jawaban, nilai, isi_soal, isi_soal_unicode, gambar_soal_filename, no_soal) 
                    SELECT :seq_soal_hdr, option_a, option_b, option_c, option_d, option_e, option_a_unicode, option_b_unicode, option_c_unicode, option_d_unicode, option_e_unicode, kunci_jawaban, nilai, isi_soal, isi_soal_unicode, gambar_soal_filename, no_soal
                    FROM f_soal_dtl WHERE id_ujian_hdr = :id_ujian_hdr");
            $stmt2->execute([
                ':id_ujian_hdr' => $id_ujian_hdr,
                ':seq_soal_hdr' => $seq_soal_hdr
            ]);
        }
        echo "<script>alert('Soal berhasil dicopy sebagai draft!'); window.location.href='daftar_ujian_saya_edit.php?hdrujn=$id_ujian_hdr&mp=".$mp."&kls=".$kls."&ju=".$ju."';</script>";
    }

    

?>