<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
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
        #icon_buat_ujian_dari_word {color:white}
        #buat_ujian_dari_word {color:white; font-weight:bold}
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
                        <h1 class="h3 mb-0 text-gray-800">Buat Draft Ujian Dari Docx</h1>
                        <!-- <a href="#" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                                class="fas fa-download fa-sm text-white-50"></i> Generate Report</a> -->
                    </div>
                    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                        <!-- Tombol Tambah -->
                        <a class="btn btn-secondary btn-icon-split" target="_blank" href="download.php?file=format_import_soal_dari_excel.xlsx">
                            <span class="icon text-white-50">
                                <i class="fas fa-copy"></i>
                            </span>
                            <span class="text">Download Format XLSX</span>
                        </a>
                        <a class="btn btn-secondary btn-icon-split" target="_blank" href="https://youtu.be/HAcPI68I9Qw">
                            <span class="icon text-white-50">
                                <i class="fas fa-video"></i>
                            </span>
                            <span class="text">Video Tutorial Upload Soal</span>
                        </a>
                    </div>
                    
                    <!-- Content Row -->
                    <div class="row">
                        <?php
                            require 'config.php';
                            // $kode_guru = $_SESSION['uname'];

                            // $sqlc = "SELECT uuidguru FROM d_guru where kode_guru = '$kode_guru'";
                            // $hasilc = $db->query($sqlc);
                            // $barisc = $hasilc->fetch(PDO::FETCH_ASSOC);
                            // $uuidguru = $barisc['uuidguru'];

                            // $query = $db->prepare("SELECT id_ujian, nama_ujian FROM d_ujian u
                            // where 
                            // EXISTS (SELECT kode_mata_pelajaran FROM d_penempatan_mapel_guru pg where kode_guru = '$kode_guru' and pg.kode_mata_pelajaran = u.kode_mata_pelajaran)");
                            // $query->execute();
                            // $ujianList = $query->fetchAll(PDO::FETCH_ASSOC);
                        ?>
                        <div class="w-full mx-auto p-4 bg-white shadow rounded-lg mt-6" x-data="soalForm()">
                            <form action="buat_ujian_by_admin_dari_word_proses.php" method="POST" enctype="multipart/form-data">
                                <input type='hidden' name='kode_guru' value='<?php echo $kode_guru;?>'/>
                                <input type='hidden' name='uuidguru' value='<?php echo $uuidguru;?>'/>
                                <div class="mb-4">
                                    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                                        <!-- Pilih Ujian -->
                                        <div>
                                            <p><b>Pilih Mata Pelajaran</b></p>
                                            <select required name="kode_mata_pelajaran" id="kode_mata_pelajaran" onchange="loadGuru(); loadUjian()" class="w-full border rounded p-2">
                                                <option value=''>--Pilih--</option>
                                                <?php
                                                    $sql5 = "SELECT kode_mata_pelajaran, nama_mata_pelajaran 
                                                    from d_mata_pelajaran order by nama_mata_pelajaran;";
                                                    $hasil5 = $db->query($sql5);
                                                    while($baris5 = $hasil5->fetch(PDO::FETCH_ASSOC)) {
                                                        echo "<option value='".$baris5['kode_mata_pelajaran']."'>".$baris5['nama_mata_pelajaran']."</option>";
                                                    }
                                                ?>
                                            </select>
                                        </div>

                                        <div>
                                            <p><b>Guru</b></p>    
                                            <select required name="uuidguru" id="uuidguru" onchange="loadUjian()" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                                                <option value="">--Guru--</option>
                                            </select>
                                        </div>

                                        <!-- Pilih Ujian -->
                                        <div>
                                            <p><b>Pilih Ujian</b></p>    
                                            <select required name="id_ujian" id="id_ujian" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                                                <option value="">--Ujian--</option>
                                            </select>
                                        </div>

                                        <div>
                                            <p><b>Untuk Ujian Susulan?</b></p>    
                                            <select required name="st_susulan" id="st_susulan" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                                                <option value=""></option>
                                                <option value="Y">Ya</option>
                                                <option value="N">Tidak</option>
                                            </select>
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
                                    <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mt-3">
                                        <div>
                                            <p><b>Tanggal Ujian</b></p>
                                            <input required type="date" name="tanggal_ujian" class="w-full border rounded p-2">
                                        </div>
                                        <div>
                                            <p><b>Durasi Ujian (Menit)</b></p>
                                            <input required type="number" name="durasi" class="w-full border rounded p-2">
                                        </div>
                                        <div>
                                            <p><b>Nama Materi/Bab</b></p>
                                            <input type="text" name="nama_bab" class="w-full border rounded p-2">
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
                                    </div>


                                <div class="mb-4 mt-4">
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
                                
                                <div class="p-4 border rounded-lg mb-4 bg-gray-50">
                                    <label>Upload Soal (docx, doc) : </label>
                                    <input type="file" name="word_file" accept=".docx,.doc" required><br>
                                </div>
                                <button type="submit" class="bg-purple-400 text-white px-2 py-2 rounded hover:bg-purple-500">Simpan Menjadi Draft</button>
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
        function loadGuru() {
            const MapelId = document.getElementById('kode_mata_pelajaran').value;
            const GuruSelect = document.getElementById('uuidguru');
            GuruSelect.innerHTML = '<option value="">Memuat...</option>';

            if (MapelId !== "") {
                fetch('get_guru_by_mapel.php?kode_mata_pelajaran=' + MapelId)
                    .then(res => res.json())
                    .then(data => {
                        GuruSelect.innerHTML = '<option value="">--Guru--</option>';
                        data.forEach(item => {
                            const opt = document.createElement('option');
                            opt.value = item.uuidguru;
                            opt.textContent = item.nama_guru;
                            GuruSelect.appendChild(opt);
                        });
                    })
                    .catch(err => {
                        GuruSelect.innerHTML = '<option value="">Gagal memuat</option>';
                    });
            } else {
                GuruSelect.innerHTML = '<option value="">--Guru--</option>';
            }
        }

        function loadUjian() {
            const MapelId = document.getElementById('kode_mata_pelajaran').value;
            const UjianSelect = document.getElementById('id_ujian');
            UjianSelect.innerHTML = '<option value="">Memuat...</option>';

            if (MapelId !== "") {
                fetch('get_ujian_by_mapel.php?kode_mata_pelajaran=' + MapelId)
                    .then(res => res.json())
                    .then(data => {
                        UjianSelect.innerHTML = '<option value="">--Ujian--</option>';
                        data.forEach(item => {
                            const opt = document.createElement('option');
                            opt.value = item.id_ujian;
                            opt.textContent = item.nama_ujian;
                            UjianSelect.appendChild(opt);
                        });
                    })
                    .catch(err => {
                        UjianSelect.innerHTML = '<option value="">Gagal memuat</option>';
                    });
            } else {
                UjianSelect.innerHTML = '<option value="">--Ujian--</option>';
            }
        }
    </script>
</body>
</html>