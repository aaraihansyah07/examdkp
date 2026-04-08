<?php
  session_start();
  $uname = $_SESSION['uname'];
  $fname = $_SESSION['fname'];

  if (!isset($uname)) {
    header('location:../login.php');
  }
  $uuidsiswa = $_SESSION['uuidsiswa'];
  $token_input = $_SESSION['token'];
  include('config.php');

  $sql2 = "SELECT id_ujian_hdr, kode_ujian, kode_mata_pelajaran, durasi, uuidguru, id_kelas, id_subkelas, soal_acak, option_acak
  from f_soal_hdr where token = '$token_input'";
  $hasil2 = $db->query($sql2);
  $baris2 = $hasil2->fetch(PDO::FETCH_ASSOC);

  $sql3 = "SELECT round(jatah_pelanggaran) jatah_pelanggaran, durasi_toleransi_idle from d_parameter_ujian where id_param = 1";
  $hasil3 = $db->query($sql3);
  $baris3 = $hasil3->fetch(PDO::FETCH_ASSOC);

  if (!isset($baris3['jatah_pelanggaran'])) {
    $jatah_pelanggaran  = 3;
  }
  else {
    $jatah_pelanggaran = $baris3['jatah_pelanggaran'];
  }

  if (!isset($baris3['durasi_toleransi_idle'])) {
    $durasi_toleransi_idle  = 30000;
  }
  else {
    $durasi_toleransi_idle = $baris3['durasi_toleransi_idle'] * 1000;
  }

  $id_ujian_hdr = $baris2['id_ujian_hdr'];
  $kode_ujian = $baris2['kode_ujian'];
  $kode_mata_pelajaran = $baris2['kode_mata_pelajaran'];
  $durasi = $baris2['durasi'];
  $uuidguru = $baris2['uuidguru'];
  $id_kelas = $baris2['id_kelas'];
  $id_subkelas = $baris2['id_subkelas'];
  $soal_acak = $baris2['soal_acak'];
  $option_acak = $baris2['option_acak'];
  
  $durasi = $durasi * 60;

  $_SESSION['signature'] = $_POST['signature_data'];
  $signatureBase64 = $_POST['signature_data'];
  // hapus header base64
  $signatureBase64 = str_replace('data:img/ttd;base64,', '', $signatureBase64);
  // decode jadi binary
  $signatureBinary = base64_decode($signatureBase64);
  // $sql4 = "SELECT count(1) cek_ada from f_jawaban_siswa_hdr where id_ujian_hdr = $id_ujian_hdr AND nis = '$uname' AND st_selesai = 'Y'";
  // $hasil4 = $db->query($sql4);
  // $baris4 = $hasil4->fetch(PDO::FETCH_ASSOC);

  // if ($baris4['cek_ada'] > 0) {
  //     echo "<script>alert('Anda sudah pernah mengikuti ujian ini sebelumnya'); window.location.href='halaman_awal_ujian.php';</script>";
  //     exit;
  // }

  $sql = "SELECT option_a, option_b, option_c, option_d, option_e,
    no_soal AS id_soal,
    isi_soal AS pertanyaan,
    gambar_soal_filename AS gambar
    FROM f_soal_dtl
    WHERE id_ujian_hdr = '$id_ujian_hdr'
    ORDER BY no_soal";
  $hasil = $db->query($sql);
  $datas = $hasil->fetchAll(PDO::FETCH_ASSOC);

  $stmt = $db->prepare("SELECT pelanggaran_count 
                      FROM f_jawaban_siswa_hdr 
                      WHERE uuidsiswa = :uuidsiswa 
                      AND id_ujian_hdr = :id_ujian_hdr");
  $stmt->execute([
      ':uuidsiswa' => $uuidsiswa,
      ':id_ujian_hdr' => $id_ujian_hdr
  ]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  $pelanggaranCount = $row['pelanggaran_count'] ?? 0;

  // 🔹 Acak soal
  if ($soal_acak === 'Y') {
      shuffle($datas);
  }

  $soalList = [];
  foreach ($datas as $row) {
      // mapping opsi ke kode aslinya
      $opsi = [
          ['kode' => 'A', 'text' => $row['option_a']],
          ['kode' => 'B', 'text' => $row['option_b']],
          ['kode' => 'C', 'text' => $row['option_c']],
          ['kode' => 'D', 'text' => $row['option_d']],
          ['kode' => 'E', 'text' => $row['option_e']],
      ];

      // 🔹 Acak opsi jika diaktifkan
      if ($option_acak === 'Y') {
          shuffle($opsi);
      }

      $soalList[] = [
          'id_soal'    => (int)$row['id_soal'],   // tetap simpan ID/No soal asli
          'pertanyaan' => $row['pertanyaan'],
          'gambar'     => !empty($row['gambar']) ? '../uploads/' . $row['gambar'] : null,
          'opsi'       => $opsi
      ];
      

  }
?>
<!DOCTYPE html>
<html lang="id" x-data="cbtApp()" x-init="startTimer()" class="bg-gray-100">
<head>
  <meta charset="UTF-8">
  <title>CBT Siswa</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://unpkg.com/alpinejs" defer></script>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    .ql-editor p { margin: 0; } /* hilangkan margin bawaan */
    .ql-editor p {
        margin: 0 !important;
        padding: 0 !important;
    }

    .soal-content p,
    .opsi-content p {
        margin: 0 !important;
        padding: 0 !important;
    }

    mjx-container {
        margin: 0 !important;
        padding: 0 !important;
    }

    /* ============================= */
    /*    ANTI COPY — CSS ONLY       */
    /* ============================= */
    .nocopy, .nocopy * {
        user-select: none !important;
        -webkit-user-select: none !important;
        -moz-user-select: none !important;
        -ms-user-select: none !important;

        -webkit-touch-callout: none !important; /* blok long press di HP */
    }
  </style>
  <script>
    document.addEventListener("copy", e => e.preventDefault());
    document.addEventListener("cut", e => e.preventDefault());
    document.addEventListener("paste", e => e.preventDefault());
    document.addEventListener("contextmenu", e => e.preventDefault());

    document.addEventListener("keydown", function(e) {
        if (e.ctrlKey && ['c','x','v','a'].includes(e.key.toLowerCase())) {
            e.preventDefault();
        }
    });
  </script>

  <!-- MathJax untuk render LaTeX -->
  <script>
    window.MathJax = {
      tex: { inlineMath: [['$', '$'], ['\\(', '\\)']] },
      svg: { fontCache: 'global' }
    };
  </script>
  <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
</head>
<body class="min-h-screen flex flex-col bg-gray-100 nocopy">
<header class="bg-white border-b px-4 md:px-6 py-3 md:py-4 flex flex-wrap justify-between items-center sticky top-0 z-50 shadow-sm">
  <h1 class="text-lg md:text-xl font-bold text-gray-800">
    E-EXAM <span class="hidden sm:inline">SMAN 1 DUKUPUNTANG</span>
  </h1>

  <div class="mt-2 md:mt-0 text-sm text-gray-600 flex items-center gap-2">
    <span class="font-medium text-blue-600">
      <?php echo $fname .' ('. $uname.')';?>
    </span>
    <!-- <span class="hidden sm:inline">|</span>
    <a href="../logout.php" class="text-red-500 hover:underline">Sign Out</a> -->
  </div>
</header>

<script>
function isLatex(str) {
  // cek apakah ada backslash \ yang menandakan LaTeX
  return /\\[a-zA-Z]+/.test(str);
}
</script>

<!-- TIMER -->
<div class="fixed top-20 left-1/2 transform -translate-x-1/2 z-40">
  <div class="bg-white border border-red-400 text-red-600 px-4 md:px-6 py-2 md:py-3 rounded-lg shadow-md text-base md:text-xl font-semibold">
    Sisa Waktu: <span x-text="formattedTime"></span>
  </div>
</div>

<!-- MAIN CONTAINER -->
<div class="w-full flex flex-col md:flex-row gap-4 mt-20 md:mt-24 flex-grow">
  <!-- SOAL UTAMA -->
  <div class="flex-1 bg-white p-6 rounded-lg shadow-md">
    <template x-if="soalList[soalAktif]">
      <div>
      <template x-if="soalList[soalAktif].gambar">
        <img :src="soalList[soalAktif].gambar" class="mb-4 rounded max-h-64 object-contain w-full" />
      </template>
        
    <div class="text-lg font-medium mb-4">
      <span x-text="(soalAktif+1) + '. '"></span>
      <span x-ref="pertanyaan"
            x-html="sanitizeLatex(soalList[soalAktif].pertanyaan)"
            x-effect="$nextTick(() => MathJax.typesetPromise([$refs.pertanyaan]))">
      </span>
    </div>

    <template x-for="(opsi,index) in soalList[soalAktif].opsi" :key="index">
        <label class="flex items-center gap-3 p-3 border rounded-lg mb-2 cursor-pointer hover:bg-gray-100">
            
            <input type="radio"
                class="w-5 h-5"
                :name="'soal_' + soalList[soalAktif].id_soal"
                :value="opsi.kode"
                @change="jawab(soalAktif, opsi.kode)"
                :checked="jawaban[soalList[soalAktif].id_soal] === opsi.kode">

            <span
            x-ref="opItem"
            x-html="sanitizeLatex(opsi.text)"
            x-effect="$nextTick(() => MathJax.typesetPromise([$refs.opItem]))">
            </span>

        </label>
    </template>

    <!-- Navigasi Tombol Mobile -->
    <div class="block md:hidden mt-6">
      <div class="flex flex-wrap gap-2 justify-center">
        <template x-for="(soal, index) in soalList" :key="index">

        </template>
      </div>
    </div>

    <!-- Navigasi Tombol -->
    <div class="flex justify-between items-center mt-6">
          <button @click="prevSoal" class="px-4 py-2 bg-gray-300 hover:bg-gray-400 rounded disabled:opacity-50" :disabled="soalAktif === 0">← Sebelumnya</button>
          <button @click="showModal = true" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700" :disabled="sudahSimpan">Selesai Ujian</button>
          <button @click="nextSoal" class="px-4 py-2 bg-gray-300 hover:bg-gray-400 rounded disabled:opacity-50" :disabled="soalAktif === soalList.length - 1">Berikutnya →</button>
        </div>
      </div>
    </template>
  </div>

  <!-- Butir Soal Desktop -->
  <div class="w-full md:w-64 lg:w-72 bg-white p-5 rounded-lg shadow-md md:sticky md:top-24">
    <h3 class="text-center font-semibold mb-4">Navigasi Soal</h3>
    <div class="flex flex-wrap justify-center gap-2">
      <template x-for="(soal, index) in soalList" :key="index">
        <button @click="soalAktif = index"
                :class="jawaban[soal.id_soal] ? 'bg-green-500' : 'bg-red-500'"
                class="w-10 h-10 rounded-full text-white font-bold">
          <span x-text="index + 1"></span>
        </button>
      </template>
    </div>
  </div>
</div>

<!-- Modal Konfirmasi -->
<div x-show="showModal" style="background-color: rgba(0,0,0,0.5)" class="fixed inset-0 flex items-center justify-center z-50">
  <div class="bg-white p-6 rounded-lg shadow-lg w-11/12 max-w-sm" @click.away="showModal = false">
    <h2 class="text-lg font-semibold mb-4">Selesaikan ujian?</h2>
    <div class="flex justify-end gap-4">
      <button @click="showModal = false" class="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400">Batal</button>
      <button @click="simpanJawaban" :disabled="sudahSimpan" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">OK</button>
    </div>
  </div>
</div>

<script>
function cbtApp() {
  const keyPrefix = `cbt_${<?= json_encode($uname ?? '') ?>}_${<?= json_encode($id_ujian_hdr ?? 0) ?>}`;
  return {
    waktu: <?= (int)($durasi ?? 0) ?>,
    soalAktif: 0,
    soalList: <?= json_encode($soalList ?? [], JSON_UNESCAPED_UNICODE) ?>,
    jawaban: {},
    jawabanTerkirim: {},
    showModal: false,
    sudahSimpan: false,
    timerInterval: null,
    _antiCheatInitialized: false,
    _sessionId: null,
    isHiddenTriggered: false,
    pendingWarning: false,

    <?php $maxWarnings = $jatah_pelanggaran; ?>

    key(name) { return `${keyPrefix}_${name}`; },

    get formattedTime() {
      const m = String(Math.floor(this.waktu / 60)).padStart(2,'0');
      const s = String(this.waktu % 60).padStart(2,'0');
      return `${m}:${s}`;
    },

    init() {
      // Render LaTeX saat halaman pertama muncul
      this.renderMath();

      // Render ulang LaTeX setiap kali pindah soal
      this.$watch('soalAktif', () => {
        this.renderMath();
      });
    },

    renderMath() {
      this.$nextTick(() => {
        MathJax.typesetPromise([this.$root]);
      });
    },

    _showWarningPopup(msg) {
      const isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);

      if (isMobile) {
        setTimeout(() => alert(msg), 150);
      } else {
        alert(msg);
      }
    },


    startTimer(isNewSession = false) {
      // Restore jawaban
      const savedJawaban = localStorage.getItem(this.key('jawaban'));
      if (savedJawaban) {
        try { this.jawaban = JSON.parse(savedJawaban) || {}; }
        catch { localStorage.removeItem(this.key('jawaban')); }
      }

      // Restore waktu
      const savedWaktu = localStorage.getItem(this.key('waktu'));
      if (savedWaktu && !isNaN(savedWaktu)) this.waktu = parseInt(savedWaktu, 10);

      // Restore warningCount
      if (isNewSession) {
        this.warningCount = <?= (int)($maxWarnings ?? 5) ?>;
        localStorage.setItem(this.key('warningCount'), this.warningCount);
      } else {
        const savedWarning = localStorage.getItem(this.key('warningCount'));
        if (savedWarning !== null && !isNaN(savedWarning)) this.warningCount = parseInt(savedWarning,10);
        else {
          this.warningCount = <?= (int)($maxWarnings ?? 5) ?>;
          localStorage.setItem(this.key('warningCount'), this.warningCount);
        }
      }

      // SessionId per tab
      function generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
          const r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
          return v.toString(16);
        });
      }

      // ganti di script:
      this._sessionId = (crypto.randomUUID) ? crypto.randomUUID() : generateUUID();
      localStorage.setItem(this.key('sessionId'), this._sessionId);

      // Anti-cheat
      this.initAntiCheat();

      // Timer
      if(this.timerInterval) clearInterval(this.timerInterval);
      this.timerInterval = setInterval(()=>{
        if(this.waktu>0){
          this.waktu--;
          localStorage.setItem(this.key('waktu'), this.waktu);
        } else {
          clearInterval(this.timerInterval);
          this.simpanOtomatisSaatWaktuHabis();
        }
      },1000);

      this.init();
    },

    simpanOtomatisSaatWaktuHabis() {
      alert("⏳ Waktu habis! Jawaban akan disimpan otomatis dan ujian selesai.");
      this.submitFinalUjian();
    },

    initAntiCheat() {
      if (this._antiCheatInitialized) return;
      this._antiCheatInitialized = true;

      // Handler untuk tab hidden (beri toleransi 4 detik)
      this._visibilityHandler = () => { 
        if (document.hidden) {
          // simpan flag bahwa user sempat keluar
          this.isHiddenTriggered = true;

          this._hiddenTimeout = setTimeout(() => {
            if (document.hidden) {
              // jangan panggil alert di background → pending dulu
              this.pendingWarning = true;
            }
          }, <?php echo $durasi_toleransi_idle;?>);

        } else {
          // TAB ACTIVE lagi
          clearTimeout(this._hiddenTimeout);

          // jika ada pelanggaran pending → sekarang baru jalankan
          if (this.pendingWarning && this.isHiddenTriggered) {
            this.pendingWarning = false;
            this.isHiddenTriggered = false;

            // jalankan pengurangan warning DAN popup setelah delay
            setTimeout(() => {
              this._kurangiWarning();
            }, 200);
          }
        }
      };

      // Handler untuk back/forward
      // this._popstateHandler = () => {
      //   this._kurangiWarning();
      //   if (this.warningCount > 0) {
      //     window.location.href = window.location.href; // reload halaman ujian
      //   } else {
      //     this.simpanOtomatisSaatWaktuHabis();
      //   }
      // };

      this._popstateHandler = () => {
      this._kurangiWarning();

      if (this.warningCount > 0) {
        if (!sessionStorage.getItem('cbt_reloaded_once')) {
          sessionStorage.setItem('cbt_reloaded_once', '1');
          window.location.reload();
        }
      } else {
        this.simpanOtomatisSaatWaktuHabis();
      }
    };


      document.addEventListener('visibilitychange', this._visibilityHandler);
      window.addEventListener('popstate', this._popstateHandler);

      for(let i=0;i<20;i++) window.history.pushState(null,"",window.location.href);
    },


    _kurangiWarning() {
      // Cek sessionId
      const currentSession = localStorage.getItem(this.key('sessionId'));
      if (currentSession !== this._sessionId) {
        this._showWarningPopup("Deteksi session berbeda! Ujian akan diselesaikan.");
        this.simpanOtomatisSaatWaktuHabis();
        return;
      }

      if (this.warningCount <= 0) return;

      this.warningCount--;
      localStorage.setItem(this.key('warningCount'), this.warningCount);

      this._showWarningPopup(`PERINGATAN! Sisa kesempatan: ${this.warningCount}`);

      if (this.warningCount <= 0) {
        this.simpanOtomatisSaatWaktuHabis();
      }
    },


  jawab(index, value) {
    const idSoal = this.soalList[index].id_soal;

    if (this.jawaban[idSoal] !== value) {
      this.jawaban[idSoal] = value;

      // ✅ Trigger reactivity supaya UI berubah
      this.jawaban = { ...this.jawaban };

      localStorage.setItem(this.key('jawaban'), JSON.stringify(this.jawaban));
      this.periksaAutoSave();
    }
  },

    periksaAutoSave(){
      const total=Object.keys(this.jawaban).length;
      if(total>0 && total%5===0) this.autoSaveJawaban();
    },

    autoSaveJawaban(){
      const delta={};
      for(let k in this.jawaban){
        if(this.jawaban[k]!==this.jawabanTerkirim[k]) delta[k]=this.jawaban[k];
      }
      if(Object.keys(delta).length===0) return;

      fetch('pengerjaan_ujian_proses.php',{
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({
          uuidsiswa:<?= json_encode($uuidsiswa ?? '') ?>,
          id_ujian_hdr:<?= json_encode($id_ujian_hdr ?? 0) ?>,
          kode_mata_pelajaran:<?= json_encode($kode_mata_pelajaran ?? '') ?>,
          uuidguru:<?= json_encode($uuidguru ?? '') ?>,
          id_kelas:<?= json_encode($id_kelas ?? '') ?>,
          id_subkelas:<?= json_encode($id_subkelas ?? '') ?>,
          nis:<?= json_encode($uname ?? '') ?>,
          jawaban:delta
        })
      }).then(res=>res.json()).then(data=>{
        if(data.status==='success') Object.assign(this.jawabanTerkirim,delta);
        else console.warn("Autosave gagal:",data.message);
      }).catch(err=>console.error("Autosave error:",err.message));
    },

    simpanJawaban(){
      if(!confirm("Yakin ingin menyelesaikan ujian? Pastikan semua jawaban sudah benar.")) return;
      this.submitFinalUjian();
    },

sanitizeLatex(str) {
  if (!str) return '';

  // Normalize break antar paragraf
  str = str.replace(/<\/p>\s*<p>/gi, '\n\n');

  // Buang tag p
  str = str.replace(/<\/?p>/gi, '');

  // Deteksi apakah baris mengandung latex
  // Jika iya → jadikan display (blok)
  return str
    .split(/\n\n+/) // pisah paragraf
    .map(block => {
      if (/\\[a-zA-Z]+|\^|_|{|}/.test(block)) {
        // Block math → pakai display $$...$$
        return `$$${block}$$`;
      }
      // Block teks biasa → biarkan saja sebagai HTML
      return `<div>${block}</div>`;
    })
    .join('');
},

    submitFinalUjian(){
      fetch('pengerjaan_ujian_proses.php',{
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({
          uuidsiswa:<?= json_encode($uuidsiswa ?? '') ?>,
          id_ujian_hdr:<?= json_encode($id_ujian_hdr ?? 0) ?>,
          kode_mata_pelajaran:<?= json_encode($kode_mata_pelajaran ?? '') ?>,
          uuidguru:<?= json_encode($uuidguru ?? '') ?>,
          id_kelas:<?= json_encode($id_kelas ?? '') ?>,
          id_subkelas:<?= json_encode($id_subkelas ?? '') ?>,
          nis:<?= json_encode($uname ?? '') ?>,
          jawaban:this.jawaban,
          submit_final:true
        })
      }).then(res=>res.json()).then(data=>{
        if(data.status==='success'){
          if(data.clear_local) this.clearLocalData();
          if(data.redirect) window.location.href=data.redirect;
          else { alert(data.message); window.location.href='halaman_akhir_ujian.php'; }
        } else alert(data.message);
      }).catch(err=>{ console.error(err); alert('Terjadi kesalahan saat mengirim jawaban.'); });
    },

    clearLocalData(){
      localStorage.removeItem(this.key('jawaban'));
      localStorage.removeItem(this.key('waktu'));
      localStorage.removeItem(this.key('warningCount'));
      localStorage.removeItem(this.key('sessionId'));
    },

    prevSoal(){ if(this.soalAktif>0)this.soalAktif--; },
    nextSoal(){ if(this.soalAktif<this.soalList.length-1)this.soalAktif++; }
  }
}
</script>

</body>
</html>
