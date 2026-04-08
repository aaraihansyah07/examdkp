<?php
    session_start();
    session_unset();
    session_destroy();
    ob_start();

    include('config.php');

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
        <span class="font-medium text-blue-600"><a href="../login.php" class="text-red-500 hover:underline">Sign In</a>
    </div>
  </header>

  <!-- Main Content -->
  <main class="flex flex-col md:flex-row justify-center items-stretch gap-6 px-4 py-10 max-w-6xl mx-auto w-full">
    <!-- Instruksi -->


    <!-- Form Pilihan -->
    <section class="bg-white rounded-xl shadow-md p-6 flex-1">
     <h2 class="text-lg font-semibold text-blue-700 mb-4 border-b pb-2" style="text-align:center">Selesai melaksanakan ujian</h2>
      <form action="../login.php" method="POST" class="space-y-4">
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

        <div class="pt-2">
          <button name="lanjut" type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold">
            Ke Halaman Login
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
</body>
</html>
