<?php
    session_start();
    if (!isset($_SESSION['fname']) || $_SESSION['role'] != '2') {
        header('location:../login.php');
        exit;
    }
    ob_start();
    $uname = $_SESSION['uname'];
    $fname = $_SESSION['fname'];
    date_default_timezone_set("Asia/Jakarta");
    $date_now = date("Y-m-d");

   if (!isset($uname)) {
    header('location:../login.php');
   } 

    include('config.php');

    if (isset($_POST['lanjut'])) {
        $token_input = $_POST['token'];
        $sql = "SELECT id_subkelas from d_siswa where nis = '$uname'";
        $hasil = $db->query($sql);
        // $baris = $hasil->fetch(PDO::FETCH_ASSOC);
        // $id_subkelas_siswa = $baris['id_subkelas'];

        $baris = $hasil->fetch(PDO::FETCH_ASSOC);

        if (!$baris) {
            die("Data siswa tidak ditemukan");
        }

        $id_subkelas_siswa = $baris['id_subkelas'];

        $sql3 = "SELECT token, id_ujian_hdr, tanggal_ujian, st_nonaktif_ujian from f_soal_hdr where token = '$token_input' AND st_posting = 'Y' AND st_nonaktif_token is null AND id_subkelas = '$id_subkelas_siswa'";
        $hasil3 = $db->query($sql3);
        //$baris3 = $hasil3->fetch(PDO::FETCH_ASSOC);
        $baris3 = $hasil3->fetch(PDO::FETCH_ASSOC);

        if (!$baris3) {
            echo "<script>alert('Token yang dimasukkan tidak sesuai'); window.location.href='halaman_awal_ujian.php';</script>";
            exit;
        }
        $id_ujian_hdr_cek = $baris3['id_ujian_hdr'];
        $tanggal_ujian = $baris3['tanggal_ujian'];
        $st_nonaktif_ujian = $baris3['st_nonaktif_ujian'];

        if (!isset($baris3['token'])) {
            echo "<script>alert('Token yang dimasukkan tidak sesuai'); window.location.href='halaman_awal_ujian.php';</script>";
            exit;
        }
        else if (isset($baris3['token']) && ($tanggal_ujian == $date_now) && ($st_nonaktif_ujian == NULL)){
          $_SESSION['token'] = $token_input;
          
          $sql4 = "SELECT count(1) cek_ada from f_jawaban_siswa_hdr where id_ujian_hdr = $id_ujian_hdr_cek AND nis = '$uname' AND st_selesai = 'Y'";
          $hasil4 = $db->query($sql4);
          $baris4 = $hasil4->fetch(PDO::FETCH_ASSOC);

          if ($baris4['cek_ada'] > 0) {
                echo "<script>alert('Anda sudah pernah mengikuti ujian ini sebelumnya'); window.location.href='halaman_awal_ujian.php';</script>";
                exit;
          }
        }
        else if (isset($baris3['token']) && ($tanggal_ujian == $date_now) && ($st_nonaktif_ujian == 'Y')){
            echo "<script>alert('Ujian ini sudah dinonaktifkan operator, harap hubungi operator untuk info lebih lanjut'); window.location.href='halaman_awal_ujian.php';</script>";
            exit;
        }
        else if (isset($baris3['token']) && ($tanggal_ujian !== $date_now)){
            echo "<script>alert('Tidak bisa mengakses ujian ini di luar jadwal ujian'); window.location.href='halaman_awal_ujian.php';</script>";
            exit;
        }
    }
    
    $sql2 = "SELECT sk.nama_subkelas, h.id_ujian, h.nama_bab, h.kode_ujian, durasi, u.nama_ujian, h.kode_mata_pelajaran, h.id_ujian_hdr, u.jenis_ujian, 
    (select count(1) from f_soal_dtl d where h.id_ujian_hdr = d.id_ujian_hdr) jml_soal
    from f_soal_hdr h
    left join d_ujian u on u.id_ujian = h.id_ujian
    left join d_subkelas sk on sk.id = h.id_subkelas
    where token = '$token_input'";
    $hasil2 = $db->query($sql2);
    $baris2 = $hasil2->fetch(PDO::FETCH_ASSOC);

?>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Halaman Persiapan Ujian</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen flex flex-col justify-between">

  <!-- Header -->
  <header class="bg-white border-b py-4 px-6 flex justify-between items-center">
    <h1 class="text-xl font-bold text-gray-800">E-EXAM SMAN 1 DUKUPUNTANG</h1>
    <div class="text-sm text-gray-600">
        <span class="font-medium text-blue-600"><?php echo $fname .' ('. $uname.')';?></span> | <a href="../logout.php" class="text-red-500 hover:underline">Sign Out</a>
    </div>
  </header>

  <!-- Main Content -->
  <main class="flex flex-col md:flex-row justify-center items-stretch gap-6 px-4 py-10 max-w-6xl mx-auto w-full">
    <!-- Instruksi -->
    <section class="bg-white rounded-xl shadow-md p-6 flex-1">
      <h2 class="text-lg font-semibold text-blue-700 mb-4 border-b pb-2" style="text-align:center">Instruksi Jalannya Ujian</h2>
      <ol class="list-decimal list-inside text-gray-700 space-y-2" style="text-align:justify">
        <li>
          <span>Pastikan data siswa <b>(Nama dan NIS)</b> beserta ujian yang akan diikuti sesuai
        </li>
        <li>
          <span>Kerjakan ujian secara <b>jujur</b> dan <b>teliti</b></span>
        </li>
        <li>
          <!-- <?php
            // $sql2b = "SELECT round(jatah_pelanggaran) jatah from d_parameter_ujian limit 1";
            // $hasil2b = $db->query($sql2b);
            // $baris2b = $hasil2b->fetch(PDO::FETCH_ASSOC);

            // $jatah = $baris2b['jatah'];
            // if (!isset($baris2b['jatah'])) {
            //   $jatah = 3;
            // }
          
          ?> -->
          <span>Pelanggaran seperti membuka tab lain/halaman lain selain halaman ujian dan back via browser akan terdeteksi sistem sebagai bentuk pelanggaran 
            dan apabila terdeteksi <b>5 kali melakukan pelanggaran tersebut maka otomatis ujian akan berakhir</b></span>.
        </li>
      </ol>
    </section>

    <!-- Form Pilihan -->
    <section class="bg-white rounded-xl shadow-md p-6 flex-1">
      <h2 class="text-lg font-semibold text-blue-700 mb-4 border-b pb-2" style="text-align:center">Persiapan Ujian</h2>
      <h3>Nama Ujian  : <?php echo $baris2['nama_ujian'];?></h3>
      <h3>Nama bab &nbsp : <?php echo $baris2['nama_bab'];?></h3>
      <h3>Jumlah Soal : <?php echo $baris2['jml_soal']. ' Soal';?></h3>
      <h3>Durasi &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $baris2['durasi']. ' Menit';?></h3>
      <h3>Kelas &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $baris2['nama_subkelas'];?></h3><br>
    
      <h3 style='font-weight:bold'>NAMA : <?php echo $fname;?></h3>
      <h3 style='font-weight:bold'>NIS &nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $uname;?></h3>
      <form action="pengerjaan_ujian.php" method="POST" class="space-y-4">
        <!-- <div>
          <label class="block text-gray-700 mb-1">Pilih Mata Pelajaran</label>
            <select required name="kode_mata_pelajaran" class="w-full border rounded px-3 py-2 focus:outline-none focus:ring focus:ring-blue-300">
                <option value="">--Pilih Mata Pelajaran--</option>
                <?php
                    $sql3 = "SELECT kode_mata_pelajaran, nama_mata_pelajaran from d_mata_pelajaran order by nama_mata_pelajaran";
                    $hasil3 = $db->query($sql3);
                    while($baris3 = $hasil3->fetch(PDO::FETCH_ASSOC)) {
                ?>
                    <option value='<?php echo $baris3['kode_mata_pelajaran'];?>'><?php echo $baris3['nama_mata_pelajaran'];?></option>
                <?php
                    }
                ?>
            </select>
        </div>

        <div>
          <label class="block text-gray-700 mb-1">Pilih Jenis Ujian</label>
          <select name="jenis_ujian" class="w-full border rounded px-3 py-2 focus:outline-none focus:ring focus:ring-blue-300">
            <option value="">-- Pilih Jenis Ujian --</option>
            <option value="UH">Ulangan Harian</option>
            <option value="UTS">Ulangan Tengah Semester</option>
            <option value="UAS">Ulangan Akhir Semester</option>
          </select>
        </div>

        <div>
          <label class="block text-gray-700 mb-1">Pilih Ujian</label>
          <select name="nama_ujian" class="w-full border rounded px-3 py-2 focus:outline-none focus:ring focus:ring-blue-300">
            <option value="">-- Pilih --</option>
            <option>Bab 1</option>
            <option>Bab 2</option>
          </select>
        </div> -->
        <div class="pt-2">
          <button name="mulai_ujian" type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold">
            MULAI UJIAN
          </button>
        </div>
      </form>
    </section>
  </main>

  <!-- Footer -->
  <footer class="text-center text-sm text-gray-600 py-4 border-t bg-white">
    2025 E-EXAM SMAN 1 Dukupuntang. All rights reserved
  </footer>
</body>
</html>
