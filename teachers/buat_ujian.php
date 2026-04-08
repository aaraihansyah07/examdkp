<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '1') {
        header('location:../login.php');
    }
?>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>E-Exam | Buat Draft Ujian</title>
    <script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
    <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>

    <!-- Custom fonts for this template-->
    <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link
        href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
        rel="stylesheet">

    <!-- Custom styles for this template-->
    <link href="css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        #icon_buat_ujian {color:white}
        #buat_ujian {color:white; font-weight:bold}
    </style>
</head>

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">
        <?php
            include('sidebar.php');
        ?>

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

                <!-- Topbar -->
                <?php include ('topbar.php');?>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div class="container-fluid">
                    <!-- Page Heading -->
                    <div class="d-sm-flex align-items-center justify-content-between mb-2">
                        <h1 class="h3 mb-0 text-gray-800">Buat Draft Ujian</h1>
                        <!-- <a href="#" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                                class="fas fa-download fa-sm text-white-50"></i> Generate Report</a> -->
                    </div>
                    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                        <!-- Tombol Tambah -->
                        <a class="btn btn-secondary btn-icon-split" target="_blank" href="https://youtu.be/R3vexBmFcZc">
                            <span class="icon text-white-50">
                                <i class="fas fa-video"></i>
                            </span>
                            <span class="text">Video Tutorial Buat Draft Soal</span>
                        </a>
                    </div>

                    <!-- Content Row -->
                    <div class="row">
                        <?php
                            require 'config.php';
                            $kode_guru = $_SESSION['uname'];

                            $sqlc = "SELECT uuidguru FROM d_guru where kode_guru = '$kode_guru'";
                            $hasilc = $db->query($sqlc);
                            $barisc = $hasilc->fetch(PDO::FETCH_ASSOC);
                            $uuidguru = $barisc['uuidguru'];

                            $query = $db->prepare("SELECT id_ujian, nama_ujian FROM d_ujian u
                            where nama_ujian not like '%OSIS%'
                            AND
                            EXISTS (SELECT kode_mata_pelajaran FROM d_penempatan_mapel_guru pg where kode_guru = '$kode_guru' and pg.kode_mata_pelajaran = u.kode_mata_pelajaran)");
                            $query->execute();
                            $ujianList = $query->fetchAll(PDO::FETCH_ASSOC);
                        ?>
                        <div class="w-full mx-auto p-4 bg-white shadow rounded-lg mt-6" x-data="soalForm()">
                            <form method="post" action="buat_ujian_proses.php" enctype="multipart/form-data">
                                <input type='hidden' name='kode_guru' value='<?php echo $kode_guru;?>'/>
                                <input type='hidden' name='uuidguru' value='<?php echo $uuidguru;?>'/>
                                <div class="mb-4">
                                    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                                        <!-- Pilih Ujian -->
                                        <div>
                                            <p><b>Pilih Ujian</b></p>
                                            <select required name="id_ujian" class="w-full border rounded p-2">
                                                <option value=''>--Pilih--</option>
                                                <?php foreach ($ujianList as $ujian): ?>
                                                    <option value="<?= $ujian['id_ujian'] ?>"><?= htmlspecialchars($ujian['nama_ujian']) ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div>
                                            <p><b>Untuk Ujian Susulan?</b></p>
                                            <select required name="st_susulan" class="w-full border rounded p-2">
                                                <option value=""></option>
                                                <option value="Y">Ya</option>
                                                <option value="N">Tidak</option>
                                            </select>
                                        </div>
                                        <div>
                                            <p><b>Tanggal Ujian</b></p>
                                            <input required type="date" name="tanggal_ujian" class="w-full border rounded p-2">
                                        </div>
                                        <div>
                                            <p><b>Durasi Ujian (Menit)</b></p>
                                            <input required type="number" name="durasi" class="w-full border rounded p-2">
                                        </div>
                                        <!-- <div>
                                            <p><b>Waktu Mulai</b></p>
                                            <input required type="datetime-local" name="waktu_mulai" class="w-full border rounded p-2">
                                        </div>
                                        <div>
                                            <p><b>Waktu Berakhir</b></p>
                                            <input required type="datetime-local" name="waktu_berakhir" class="w-full border rounded p-2">
                                        </div> -->
                                        
                                    </div>
                                </div>
                                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div>
                                        <p><b>Nama Materi/Bab</b></p>
                                        <input name="nama_bab" type="text" class="w-full border rounded p-2" id="exampleInputPassword">
                                    </div>

                                    <div>
                                        <p><b>Acak Soal?</b></p>
                                        <select required name="soal_acak" class="w-full border rounded p-2">
                                            <option value=""></option>
                                            <option value="Y">Ya</option>
                                            <option value="N">Tidak</option>
                                        </select>
                                    </div>

                                    <div>
                                        <p><b>Acak Option?</b></p>
                                        <select required name="option_acak" class="w-full border rounded p-2">
                                            <option value=""></option>
                                            <option value="Y">Ya</option>
                                            <option value="N">Tidak</option>
                                        </select>
                                    </div>
                                </div><br>
                                
                                <div class="mb-4">
                                    <p><b>Subkelas yang Dituju</b></p>
                                    <?php
                                        $sqlb = "SELECT id, nama_subkelas FROM d_subkelas order by nama_subkelas";
                                        $hasilb = $db->query($sqlb);

                                        echo '<div class="flex flex-wrap">';
                                        $counter = 0;
                                        while ($barisb = $hasilb->fetch(PDO::FETCH_ASSOC)) {
                                            echo "<label class='flex items-center w-1/5 mb-2 space-x-2'>
                                                    <input type='checkbox' name='id_subkelas[]' value='" . $barisb['id'] . "' class='form-checkbox text-blue-600'>
                                                    <span>" . htmlspecialchars($barisb['nama_subkelas'], ENT_QUOTES) . "</span>
                                                </label>";
                                            $counter++;
                                        }
                                        echo '</div>';
                                    ?>
                                </div>
                                
                                <template x-for="(soal, index) in soalList" :key="index">
                                    <div x-show="currentSoal === index" class="p-4 border rounded-lg mb-4 bg-gray-50">
                                        <h2 class="text-lg font-semibold mb-2">Soal <span x-text="index+1"></span></h2>
                                        
                                        <!-- Upload gambar -->
                                        <div class="mb-4">
                                            <label class="block mb-1 font-medium">Upload Gambar Soal (optional)</label>
                                            <input type="file" :id="'gambar_'+index" :name="'soal['+index+'][gambar]'" accept="image/*" 
                                                @change="previewImage($event, index)" class="w-full border p-2 rounded">

                                            <template x-if="soal.preview">
                                                <div class="mt-3 flex flex-col sm:flex-row items-start sm:items-center gap-3">
                                                    <img :src="soal.preview" class="w-48 rounded shadow border">
                                                    <button type="button" @click="resetGambar(index)" 
                                                            class="bg-red-500 text-white px-3 py-2 rounded hover:bg-red-600 text-sm">
                                                        Hapus Gambar
                                                    </button>
                                                </div>
                                            </template>
                                        </div>
                                        <textarea :id="'editor-textarea-'+index" 
                                                :name="'soal['+index+'][isi_soal]'" 
                                                style="display:none"></textarea>

                                        <div :id="'editor-'+index" class="editor" style="height:200px; background:white"></div><br>
                                        
                                        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                                            <div>
                                            <label>Pilihan A</label>
                                            <textarea :id="'editor-textarea-'+index+'-option_a'"
                                                        :name="'soal['+index+'][option_a]'"
                                                        x-model="soal.option_a"
                                                        style="display:none"></textarea>
                                            <div :id="'editor-'+index+'-option_a'" class="editor" style="height:120px; background:white"></div>
                                            </div> 

                                            <div>
                                            <label>Pilihan B</label>
                                            <textarea :id="'editor-textarea-'+index+'-option_b'"
                                                        :name="'soal['+index+'][option_b]'"
                                                        x-model="soal.option_b"
                                                        style="display:none"></textarea>
                                            <div :id="'editor-'+index+'-option_b'" class="editor" style="height:120px; background:white"></div>
                                            </div>              
                                            <div>
                                            <label>Pilihan C</label>
                                            <textarea :id="'editor-textarea-'+index+'-option_c'"
                                                        :name="'soal['+index+'][option_c]'"
                                                        x-model="soal.option_c"
                                                        style="display:none"></textarea>
                                            <div :id="'editor-'+index+'-option_c'" class="editor" style="height:120px; background:white"></div>
                                            </div>
                                            <div>
                                            <label>Pilihan D</label>
                                            <textarea :id="'editor-textarea-'+index+'-option_d'"
                                                        :name="'soal['+index+'][option_d]'"
                                                        x-model="soal.option_d"
                                                        style="display:none"></textarea>
                                            <div :id="'editor-'+index+'-option_d'" class="editor" style="height:120px; background:white"></div>
                                            </div>  

                                            <div class="md:col-span-2">
                                                <label class="block mb-1">Pilihan E</label>
                                                
                                                <!-- hidden textarea sinkronisasi ke backend -->
                                                <textarea 
                                                    :id="'editor-textarea-'+index+'-option_e'"
                                                    :name="'soal['+index+'][option_e]'"
                                                    x-model="soal.option_e"
                                                    class="hidden"
                                                ></textarea>
                                                
                                                <!-- quill editor tampilan -->
                                                <div 
                                                    :id="'editor-'+index+'-option_e'" 
                                                    class="editor w-full border rounded p-2 bg-white min-h-[120px]"></div>
                                            </div> 
                                        </div>


                                        <div class="mt-20">
                                            <label class="block mb-1 font-medium">Kunci Jawaban</label>
                                            <select :name="'soal['+index+'][kunci]'" class="w-full border rounded p-2">
                                                <option value=""></option>
                                                <option value="A">A</option>
                                                <option value="B">B</option>
                                                <option value="C">C</option>
                                                <option value="D">D</option>
                                                <option value="E">E</option>
                                            </select>
                                        </div><br>
                                        <h2 class="text-rg font-semibold" style="text-align:right; color:red">Soal <span x-text="index+1"></span></h2>
                                    </div>
                                </template>

                                <div class="flex justify-between mt-4">
                                    <button type="button" @click="prevSoal()" :disabled="currentSoal === 0" 
                                            class="bg-gray-300 px-2 py-2 rounded hover:bg-gray-400 disabled:opacity-50">Sebelumnya</button>
                                    <button type="button" @click="nextSoal()" :disabled="currentSoal === soalList.length -1" 
                                            class="bg-blue-500 text-white px-2 py-2 rounded hover:bg-blue-600 disabled:opacity-50">Selanjutnya</button>
                                </div>

                                <button type="button" @click="tambahSoal()" 
                                        class="mt-4 bg-green-500 text-white px-2 py-2 rounded hover:bg-green-600">Tambah Soal Baru</button>

                                <button type="submit" 
                                        class="mt-4 bg-purple-500 text-white px-2 py-2 rounded hover:bg-purple-600 float-right">Simpan Menjadi Draft</button>
                            </form>
                        </div>
                    </div>
                </div>
                <!-- /.container-fluid -->
            </div><br>
            <!-- End of Main Content -->

            <!-- Footer -->
            <footer class="sticky-footer bg-white">
                <div class="container my-auto">
                    <div class="copyright text-center my-auto">
                        <span><?php echo date('Y');?> E-EXAM SMAN 1 Dukupuntang. All rights reserved</span><br><br>
<span>Proudly made by aa_raihansyah</span>
                    </div>
                </div>
            </footer>
            <!-- End of Footer -->

        </div>
        <!-- End of Content Wrapper -->

    </div>
    <!-- End of Page Wrapper -->

    <!-- Scroll to Top Button-->
    <a class="scroll-to-top rounded" href="#page-top">
        <i class="fas fa-angle-up"></i>
    </a>

    <!-- Logout Modal-->
    <div class="modal fade" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Konfirmasi</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <div class="modal-body">Yakin mau logout?</div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                    <a class="btn btn-primary" href="../logout.php">Logout</a>
                </div>
            </div>
        </div>
    </div>

    <!-- ganti password Modal-->
     <div class="modal fade" id="ganti_password_modal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Ganti Password</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="ganti_password_proses.php" method="post" style="padding:1% 3% 0 3%" id="form_tambah">
                    <div style="flex: 1; margin-right: 10px; margin-bottom: 10px;">
                        <p><b>Password Baru</b></p>
                        <div class="form-group" style="position:relative">
                            <input required name="password_baru" type="password" class="form-control" id="inputPassword" placeholder="Masukkan Password">
                            <!-- Tombol mata -->
                            <span onclick="togglePassword()" 
                                style="position:absolute; top:50%; right:10px; transform:translateY(-50%); cursor:pointer;">
                                👁️
                            </span>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="submit" data-dismiss="modal">Cancel</button>
                        <button class="btn btn-primary" type="submit" name="ganti_password" id="btn_tambah">Ganti Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap core JavaScript-->
    <script src="vendor/jquery/jquery.min.js"></script>
    <script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

    <!-- Core plugin JavaScript-->
    <script src="vendor/jquery-easing/jquery.easing.min.js"></script>

    <!-- Custom scripts for all pages-->
    <script src="js/sb-admin-2.min.js"></script>

    <!-- Page level plugins -->
    <script src="vendor/chart.js/Chart.min.js"></script>

    <!-- Page level custom scripts -->
    <script src="js/demo/chart-area-demo.js"></script>
    <script src="js/demo/chart-pie-demo.js"></script>

    <script>
    function soalForm() {
        return {
            soalList: [
                { isi_soal: '', option_a: '', option_b: '', option_c: '', option_d: '', option_e: '', kunci: '', preview: '' }
            ],
            currentSoal: 0,
            nextSoal() { if(this.currentSoal < this.soalList.length -1) this.currentSoal++ },
            prevSoal() { if(this.currentSoal > 0) this.currentSoal-- },
            // tambahSoal() {
            //     this.soalList.push({ isi_soal: '', option_a: '', option_b: '', option_c: '', option_d: '', option_e: '', kunci: '', preview: '' });
            //     this.currentSoal = this.soalList.length -1;
            // },
                        tambahSoal() {
  this.soalList.push({
    isi_soal: '',
    option_a: '',
    option_b: '',
    option_c: '',
    option_d: '',
    option_e: '',
    kunci: '',
    preview: ''
  });
  this.currentSoal = this.soalList.length - 1;

  this.$nextTick(() => {
    initQuillEditors(document); // re-init untuk elemen baru
  });
},
            previewImage(event, index) {
                const file = event.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = e => {
                        this.soalList[index].preview = e.target.result;
                    }
                    reader.readAsDataURL(file);
                }
            },
            resetGambar(index) {
                this.soalList[index].preview = '';
                document.getElementById('gambar_' + index).value = ''; // Reset file input
            }
        }
    }
    </script>
    <script>
        function togglePassword() {
            const input = document.getElementById("inputPassword");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
    
    <script>
    function initQuillEditors(scope = document) {
    scope.querySelectorAll(".editor").forEach(function(editorEl) {
        // cegah double-init
        if (editorEl.dataset.initialized) return;

        let quill = new Quill(editorEl, {
        theme: 'snow',
        modules: {
            toolbar: [
            ['bold', 'italic', 'underline'],
            [{ 'script': 'sub'}, { 'script': 'super' }]
            ]
        }
        });

        // hidden textarea pasangan
        let textareaId = editorEl.getAttribute("id").replace("editor", "editor-textarea");
        let textarea = document.getElementById(textareaId);

        // preload isi (kalau ada, misalnya mode edit)
        if (textarea && textarea.value) {
        quill.root.innerHTML = textarea.value;
        }

        // sinkronisasi sebelum submit
        editorEl.closest("form").addEventListener("submit", function() {
        if (textarea) textarea.value = quill.root.innerHTML;
        });

        // tandai sudah di-init
        editorEl.dataset.initialized = "true";
    });
    }

    // pertama kali halaman siap
    document.addEventListener("DOMContentLoaded", function() {
    initQuillEditors();
    });

    // kalau pakai Alpine, jalankan ulang setelah render
    document.addEventListener("alpine:init", () => {
    Alpine.effect(() => {
        setTimeout(() => initQuillEditors(), 0);
    });
    });
    </script>
</body>
</html>