<?php
session_start();
if(!isset($_SESSION['uname'])){ http_response_code(401); exit; }

header('Content-Type: application/json');
require 'config.php';

try {
    $db->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
    $data = json_decode(file_get_contents("php://input"),true);

    $uuidsiswa = $data['uuidsiswa'] ?? '';
    $nis = $data['nis'] ?? $_SESSION['uname'];
    $id_ujian_hdr = $data['id_ujian_hdr'] ?? null;
    $kode_mapel = $data['kode_mata_pelajaran'] ?? null;
    $id_kelas = $data['id_kelas'] ?? null;
    $id_subkelas = $data['id_subkelas'] ?? null;
    $uuidguru = $data['uuidguru'] ?? null;
    $jawabanUser = $data['jawaban'] ?? [];
    $isSubmitFinal = $data['submit_final'] ?? false;

    if(!$uuidsiswa || !$nis || !$id_ujian_hdr){
        http_response_code(400);
        echo json_encode(["status"=>"error","message"=>"Parameter kurang"]); 
        exit;
    }

    // Ambil kunci jawaban
    $stmt = $db->prepare("SELECT no_soal,kunci_jawaban,COALESCE(nilai,0) AS nilai
                          FROM f_soal_dtl
                          WHERE id_ujian_hdr=?
                          ORDER BY no_soal");
    $stmt->execute([$id_ujian_hdr]);
    $datas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $kunciJawaban = [];
    foreach($datas as $row) 
        $kunciJawaban[(int)$row['no_soal']] = ['kunci'=>$row['kunci_jawaban'],'nilai'=>(float)$row['nilai']];

    $db->beginTransaction();

    // Cek HDR siswa
    $stmt_cek = $db->prepare("
        SELECT id_jawaban_siswa, st_selesai
        FROM f_jawaban_siswa_hdr
        WHERE uuidsiswa=? AND id_ujian_hdr=?
    ");
    $stmt_cek->execute([$uuidsiswa, $id_ujian_hdr]);
    $hdr = $stmt_cek->fetch(PDO::FETCH_ASSOC);

    if($hdr){
        $id_jawaban_siswa = $hdr['id_jawaban_siswa'];
        if($hdr['st_selesai'] === 'Y'){
            $db->rollBack();
            http_response_code(403);
            echo json_encode(["status"=>"error","message"=>"Anda sudah menyelesaikan ujian ini."]);
            exit;
        }
    } else {
        // Buat HDR baru dengan st_selesai = 'N'
        $stmt_hdr = $db->prepare("
            INSERT INTO f_jawaban_siswa_hdr
            (uuidsiswa,id_ujian_hdr,id_kelas,id_subkelas,kode_mata_pelajaran,uuidguru,nis,st_selesai)
            VALUES(?,?,?,?,?,?,?, 'N')
            RETURNING id_jawaban_siswa
        ");
        $stmt_hdr->execute([$uuidsiswa,$id_ujian_hdr,$id_kelas,$id_subkelas,$kode_mapel,$uuidguru,$nis]);
        $id_jawaban_siswa = $stmt_hdr->fetchColumn();
    }

    // Batch insert/update jawaban
    if(!empty($jawabanUser)){
        $values=[]; $placeholders=[];
        foreach($jawabanUser as $noSoal=>$jawab){
            $info = $kunciJawaban[$noSoal] ?? ['kunci'=>null,'nilai'=>0];
            $nilaiSoal = ($jawab === $info['kunci']) ? $info['nilai'] : 0;
            $placeholders[]="(?,?,?,?,?)";
            $values[]=$id_jawaban_siswa;
            $values[]=$noSoal;
            $values[]=$jawab;
            $values[]=$info['kunci'];
            $values[]=$nilaiSoal;
        }
        if(!empty($placeholders)){
            $sql="INSERT INTO f_jawaban_siswa_dtl
                  (id_jawaban_siswa,no_soal,jawaban_siswa,kunci_jawaban,nilai)
                  VALUES ".implode(",",$placeholders)."
                  ON CONFLICT(id_jawaban_siswa,no_soal) DO UPDATE
                  SET jawaban_siswa=EXCLUDED.jawaban_siswa,
                      kunci_jawaban=EXCLUDED.kunci_jawaban,
                      nilai=EXCLUDED.nilai";
            $stmt = $db->prepare($sql);
            $stmt->execute($values);
        }
    }

    // Jika submit final → update st_selesai
    if($isSubmitFinal){
        $stmt_update = $db->prepare("
            UPDATE f_jawaban_siswa_hdr
            SET st_selesai = 'Y'
            WHERE id_jawaban_siswa = ?
        ");
        $stmt_update->execute([$id_jawaban_siswa]);
    }

    $db->commit();

    echo json_encode([
        "status"=>"success",
        "message"=>$isSubmitFinal?"Jawaban berhasil disimpan dan ujian selesai":"Jawaban berhasil disimpan",
        "id_jawaban_siswa"=>$id_jawaban_siswa,
        "clear_local"=>$isSubmitFinal,
        "redirect"=>$isSubmitFinal?"halaman_akhir_ujian.php":null
    ]);

}catch(PDOException $e){
    if($db->inTransaction()) $db->rollBack();
    http_response_code(500);
    echo json_encode(["status"=>"error","message"=>"Gagal simpan jawaban: ".$e->getMessage()]);
}
?>
