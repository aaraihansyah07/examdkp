<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '2') {
        header('location:../login.php');
    }
    ob_start();
    $uname = $_SESSION['uname'];
    $fname = $_SESSION['fname'];

   if (!isset($uname)) {
    header('location:../login.php');
   } 
    include('config.php');

    $sql2 = "SELECT uuidsiswa from d_siswa where nis = '$uname'";
    $hasil2 = $db->query($sql2);
    $baris2 = $hasil2->fetch(PDO::FETCH_ASSOC);
    
    $_SESSION['uuidsiswa'] = $baris2['uuidsiswa'];
?>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Halaman Masuk Ujian</title>
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
  <div class="pt-2 flex justify-center">
    <button 
      type="button"
      onclick="document.getElementById('popup').classList.remove('hidden')"
      class="w-60 bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold">
      Ganti Password Akun
    </button>
  </div>

  <!-- Popup -->
<div id="popup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
  <div class="bg-white p-6 rounded-lg shadow-lg w-80">
    <h2 class="text-lg font-semibold mb-4">Ganti Password</h2>
    
    <form action="#" method="POST">
      <div style="position:relative">
      <input type="password" name="password_baru" placeholder="Password Baru" id="inputPassword"
        class="w-full border rounded-lg px-3 py-2 mb-4 focus:outline-none focus:ring-2 focus:ring-blue-400" required>
        <span onclick="togglePassword()" 
            style="position:absolute; top:30%; right:10px; transform:translateY(-50%); cursor:pointer;">
            👁️
        </span>
      </div>
      
      <div class="flex justify-end space-x-2">
        <button type="button" 
          onclick="document.getElementById('popup').classList.add('hidden')"
          class="px-4 py-2 bg-gray-300 rounded-lg hover:bg-gray-400">
          Batal
        </button>
        
        <button type="submit" name="ganti_password"
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
          Ganti Password
        </button>
      </div>
    </form>
  </div>
</div>


  <!-- Main Content -->
  <main class="flex flex-col md:flex-row justify-center items-stretch gap-6 px-4 py-10 max-w-6xl mx-auto w-full" style="margin-top:-5%">
    <!-- Instruksi -->
    <section class="bg-white rounded-xl shadow-md p-6 flex-1">
      <h2 class="text-lg font-semibold text-blue-700 mb-4 border-b pb-2" style="text-align:center">Instruksi</h2>
      <ol class="list-decimal list-inside text-gray-700 space-y-2" style="text-align:justify">
        <li>
          <span>Masukkan dengan benar 7 digit <b>token ujian</b> yang diberikan oleh guru/admin, dan pastikan tidak ada spasi di depan/di belakang
        </li>
        <li>
          <span>Klik Lanjut untuk menuju halaman dimulainya ujian.</span>
        </li>
        <li>
          <span>Pastikan <b>Nama</b> dan <b>NIS</b> ketika login sesuai</span>.
        </li>
      </ol>
    </section>

    <!-- Form Pilihan -->
    <section class="bg-white rounded-xl shadow-md p-6 flex-1">
      <h2 class="text-lg font-semibold text-blue-700 mb-4 border-b pb-2" style="text-align:center">Masukkan 7 Digit Token Ujian</h2>

      <form action="halaman_persiapan_ujian.php" method="POST" class="space-y-4">
        <!-- <div>
          <label class="block text-gray-700 mb-1">Pilih Mata Pelajaran</label>
            <select required name="kode_mata_pelajaran" class="w-full border rounded px-3 py-2 focus:outline-none focus:ring focus:ring-blue-300">
                <option value="">--Pilih Mata Pelajaran--</option>
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

        <div>
          <!-- <label class="block text-gray-700 mb-1">Masukkan Token</label> -->
          <input autocomplete="off" type="text" name="token" class="w-full border rounded px-3 py-2 focus:outline-none focus:ring focus:ring-blue-300" required>
        </div>

        <div class="pt-2">
          <button name="lanjut" type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold">
            Lanjut
          </button>
        </div>
      </form>
      <?php

      ?>
    </section>
  </main>

  <!-- Footer -->
  <footer class="text-center text-sm text-gray-600 py-4 border-t bg-white">
    2025 E-EXAM SMAN 1 Dukupuntang. All rights reserved
  </footer>

  <?php
    if (isset($_POST['ganti_password'])) {
        $user_update = $_SESSION['uname'];
       
        $password_baru = $_POST['password_baru'];
        
        $salt = base64_encode(random_bytes(16));
        $hashed_pw = crypt($password_baru, '$2y$10$' . substr(strtr($salt, '+', '.'), 0, 22)); // $2y$10$ = bcrypt cost 10
        date_default_timezone_set("Asia/Jakarta");
        $now = new DateTime();
        $now = $now->format("Y-m-d h:i:s"); 

        $sql4 = "UPDATE users set pword = '$hashed_pw', updatedate = '$now', updateuser = '$user_update'
        where uname = :uname and role='2'";
        $stmt4 = $db->prepare($sql4);
        $stmt4->execute(['uname' => $user_update]);

        echo "<script>alert('Password berhasil diganti');</script>";
    }
?>

  <script>
      function togglePassword() {
          const input = document.getElementById("inputPassword");
          input.type = input.type === "password" ? "text" : "password";
      }
  </script>
</body>
</html>
