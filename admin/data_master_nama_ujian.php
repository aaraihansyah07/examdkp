<?php
    ob_start();
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    
    if (isset($_GET['e'])) {
        echo "<script>window.alert('Berhasil melakukan edit')</script>";
    }
    else if (isset($_GET['h'])) {
        echo "<script>window.alert('Berhasil melakukan hapus')</script>";
    }
    else if (isset($_GET['dct'])) {
        echo "<script>window.alert('User ini sudah ada')</script>";
    }
    
?>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <script src="https://cdn.tailwindcss.com"></script>
    <title>E-Exam | Data Nama Ujian</title>

    <!-- Custom fonts for this template -->
    <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link
        href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
        rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/sb-admin-2.min.css" rel="stylesheet">

    <!-- Custom styles for this page -->
    <link href="vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
    <style>
        #icon_dm_nama_ujian {color:white}
        #dm_nama_ujian {color:white; font-weight:bold}
    </style>

</head>

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">
        <?php
            include('sidebar.php');
            include('config.php');
        ?>

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

                <!-- Topbar -->
                <?php include ('topbar.php');?> 
                <nav style="margin-top:-2.5%; background:#3d4857; height:35px" class="navbar navbar-expand navbar-light topbar mb-2 static-top shadow">
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">Data Nama Ujian</a>
                </nav>
                <div class="container-fluid">

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800">Data Nama Ujian</h1>

<div class="d-flex flex-wrap align-items-center gap-2 mb-4">
    <!-- Tombol Tambah -->
    <button type="button" class="btn btn-secondary btn-icon-split" data-toggle="modal" data-target="#createModal">
        <span class="icon text-white-50">
            <i class="fas fa-plus"></i>
        </span>
        <span class="text">Tambah</span>
    </button>
</div>

<?php
    $jenis_ujian_filter = '';
    $mapel_filter = '';
    $semester_filter = '';
    if (isset($_POST['refresh_filter'])) {
        $jenis_ujian_filter = $_POST['jenis_ujian_filter'];
        $mapel_filter = $_POST['mapel_filter'];
        $semester_filter = $_POST['semester_filter'];
    }
?>

<div class="dis-none panel-filter w-full p-t-10">
    <form method="POST" action="data_master_nama_ujian.php" style="width: 100%; margin: 0 auto; background-color: #f0f0f0; padding: 20px; border-radius: 8px;">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 7px;">
            <div class="w-full space-y-3 mb-4">
                <!-- Baris Kelas -->
                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-kelas" class="w-32 text-base text-gray-700">Jenis Ujian</label>
                    <select name="jenis_ujian_filter" id="jenis-sewa" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value=''>Semua</option>
                        <?php
                            $sqlw = "SELECT kode_jenis_ujian, nama_jenis_ujian from d_jenis_ujian order by nama_jenis_ujian";
                            $hasilw = $db->query($sqlw);

                            while ($barisw = $hasilw->fetch(PDO::FETCH_ASSOC)) {                        
                        ?>
                            <option value="<?= $barisw['kode_jenis_ujian']; ?>" <?= ($jenis_ujian_filter == $barisw['kode_jenis_ujian']) ? 'selected' : '' ?>><?= $barisw['nama_jenis_ujian']; ?></option>
                        <?php
                            }
                        ?>
                    </select>
                </div>

                <!-- Baris Mata Pelajaran -->
                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Semester</label>
                    <select name="semester_filter" id="jenis-sewa-mapel" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value="">Semua</option>
                        <option value="<?= '1'; ?>" <?= ($semester_filter == '1') ? 'selected' : '' ?>><?= '1'?></option>
                        <option value="<?= '2'; ?>" <?= ($semester_filter == '2') ? 'selected' : '' ?>><?= '2'?></option>
                    </select>
                </div>

                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Mata Pelajaran</label>
                    <select name="mapel_filter" id="jenis-sewa-mapel" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                       <option value="">Semua</option>
                       <?php
                            $sqld = "SELECT kode_mata_pelajaran, nama_mata_pelajaran from d_mata_pelajaran order by nama_mata_pelajaran";
                            $hasild = $db->query($sqld);

                            while ($barisd = $hasild->fetch(PDO::FETCH_ASSOC)) {
                                $kode_mata_pelajaran = $barisd['kode_mata_pelajaran'];
                                $nama_mata_pelajaran = $barisd['nama_mata_pelajaran'];
                        ?>
                            <option value="<?= $kode_mata_pelajaran; ?>" <?= ($mapel_filter == $kode_mata_pelajaran) ? 'selected' : '' ?>><?= $nama_mata_pelajaran; ?></option>
                        <?php
                            }
                        ?>
                    </select>
                </div>

                <!-- Tombol -->
                <div>
                    <button name="refresh_filter" type="submit" class="px-4 py-2 text-white bg-blue-600 hover:bg-blue-700 text-sm rounded-md shadow">
                        Refresh
                    </button>
                </div>
            </div>

            <!-- Tombol Refresh -->
            <!-- <div style="margin-top: 10px;">
                <button name="refresh_filter" type="submit" style="padding: 8px 12px; font-size: 16px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer;">
                    Refresh
                </button>
            </div> -->
        </div>
    
    </form>
</div><br>

<!-- DataTales Example -->
<div class="card shadow mb-4">
    <!-- <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary">DataTables Example</h6>
    </div> -->
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                <thead>
                    <tr>
                        <th style='text-align:center'>Kode Ujian</th>
                        <th style='text-align:center'>Jenis Ujian</th>
                        <th style='text-align:center'>Nama Ujian</th>
                        <th style='text-align:center'>Mata Pelajaran</th>
                        <th style='text-align:center'>Semester</th>
                        <th style='text-align:center'>Tahun Ajaran</th>
                        <th></th>
                    </tr>
                </thead>
                <!-- <tfoot>
                    <tr>
                        <th>No</th>
                        <th>Nama</th>
                        <th>Username</th>
                        <th></th>
                    </tr>
                </tfoot> -->
                <tbody>
                    <?php
                        $no = 1;

                        $sql = "SELECT id_ujian, jenis_ujian, nama_jenis_ujian, nama_ujian, kode_ujian, nama_mata_pelajaran, semester, nama_tahun_ajaran
                        from d_ujian u
                        left join d_mata_pelajaran mp on mp.kode_mata_pelajaran = u.kode_mata_pelajaran
                        left join d_tahun_ajaran ta on ta.kode_tahun_ajaran = u.kode_tahun_ajaran
                        left join d_jenis_ujian ju on ju.kode_jenis_ujian = u.jenis_ujian
                        where ('$jenis_ujian_filter' = '' or u.jenis_ujian = '$jenis_ujian_filter')
                        AND ('$semester_filter' = '' or u.semester = '$semester_filter')
                        AND ('$mapel_filter' = '' or u.kode_mata_pelajaran = '$mapel_filter')";
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            $jenis_ujian = $baris['nama_jenis_ujian'];
                            $nama_jenis_ujian = $baris['nama_jenis_ujian'];
                            // if ($jenis_ujian == 'UH') {
                            //     $nama_jenis_ujian = 'Ulangan Harian';
                            // }
                            // else if ($jenis_ujian == 'UTS') {
                            //     $nama_jenis_ujian = 'Ulangan Tengah Semester';
                            // }
                            // else if ($jenis_ujian == 'UAS') {
                            //     $nama_jenis_ujian = 'Ulangan Akhir Semester';
                            // }
                            echo "<tr>";
                                echo "<td>".$baris['kode_ujian']."</td>";
                                echo "<td>".$nama_jenis_ujian."</td>";
                                echo "<td>".$baris['nama_ujian']."</td>";
                                echo "<td>".$baris['nama_mata_pelajaran']."</td>";
                                echo "<td>".$baris['semester']."</td>";
                                echo "<td>".$baris['nama_tahun_ajaran']."</td>";
                                echo "<td class='align-middle text-center'>
                                <div class='flex justify-center items-center space-x-2'>
                                    <form method='post' action='hapus_data_master_nama_ujian.php' class='inline-block' onsubmit='return confirm(\"Yakin ingin menghapus data ini?\");'>
                                        <input type='hidden' name='id_ujian' value='" . $baris['id_ujian'] . "' />
                                        <button name='btn_edit' class='flex items-center bg-red-500 hover:bg-red-600 text-white text-sm font-medium py-1 px-3 rounded shadow'>
                                            <i class='fas fa-trash mr-1'></i>
                                            Hapus
                                        </button>
                                    </form>
                                </div>
                                </td>";
                            echo "</tr>";
                        }
                    ?>
                </tbody>
            </table>
        </div>
        <script type="text/javascript">
            function reply_click(clicked_id)
                {
                    let text = clicked_id;
                    $("#idmodal").html(text);
                }
        </script>
    </div>
</div>
</div>
            </div>
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

        <!-- Create Modal-->
        <div class="modal fade" id="createModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Nama Ujian</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="buat_data_master_nama_ujian.php" method="post" style="padding:1% 3% 0 3%" id="form_tambah">
                    <!-- Pilihan Kelas -->
                    <p><b>Jenis Ujian</b></p>    
                     <select required name="jenis_ujian" id="jenis_ujian" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                       <option value="">--Jenis Ujian--</option>
                       <?php
                            $sqld = "SELECT kode_jenis_ujian, nama_jenis_ujian from d_jenis_ujian order by nama_jenis_ujian";
                            $hasild = $db->query($sqld);

                            while ($barisd = $hasild->fetch(PDO::FETCH_ASSOC)) {
                                echo "<option value='".$barisd['kode_jenis_ujian']."'>".$barisd['nama_jenis_ujian']."</option>";
                            }
                        ?>
                    </select>

                    <!-- Pilihan Siswa -->
                    <br><br><p><b>Tahun Ajaran</b></p>    
                     <select required name="kode_tahun_ajaran" id="kode_tahun_ajaran" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                       <option value="">--Jenis Ujian--</option>
                       <?php
                            $sqle = "SELECT kode_tahun_ajaran, nama_tahun_ajaran from d_tahun_ajaran order by nama_tahun_ajaran";
                            $hasile = $db->query($sqle);

                            while ($barise = $hasile->fetch(PDO::FETCH_ASSOC)) {
                                echo "<option value='".$barise['kode_tahun_ajaran']."'>".$barise['nama_tahun_ajaran']."</option>";
                            }
                        ?>
                    </select>

                    <!-- Pilihan Subkelas -->
                    <br><br><p><b>Semester</b></p>    
                    <select required name="semester" id="semester" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <option value="">--Semester--</option>
                        <option value="1">Semester 1</option>
                        <option value="2">Semester 2</option>
                    </select>

                    <!-- Pilihan Siswa -->
                    <br><br><p><b>Mata Pelajaran</b></p>    
                    <?php
                        $sqlb = "SELECT kode_mata_pelajaran, nama_mata_pelajaran FROM d_mata_pelajaran order by nama_mata_pelajaran";
                        $hasilb = $db->query($sqlb);

                        echo '<div class="grid grid-cols-1 sm:grid-cols-2 gap-1">';
                            while ($barisb = $hasilb->fetch(PDO::FETCH_ASSOC)) {
                                echo "<label class='flex items-center space-x-1'>
                                        <input type='checkbox' name='kode_mata_pelajaran[]' value='" . $barisb['kode_mata_pelajaran'] . "' class='form-checkbox text-blue-600'>
                                        <span>" . htmlspecialchars($barisb['nama_mata_pelajaran'], ENT_QUOTES) . "</span>
                                    </label>";
                            }
                        echo '</div>';
                    ?>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="submit" data-dismiss="modal">Cancel</button>
                        <button class="btn btn-primary" type="submit" name="buat_akun" id="btn_tambah">Tambah</button>
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
    <script src="vendor/datatables/jquery.dataTables.min.js"></script>
    <script src="vendor/datatables/dataTables.bootstrap4.min.js"></script>

    <!-- Page level custom scripts -->
    <script src="js/demo/datatables-demo.js"></script>

    <script>
        const form = document.getElementById("form_tambah");
        const btn = document.getElementById("btn_tambah");

        form.addEventListener("submit", function (e) {
            // Cek validasi native browser
            if (form.checkValidity()) {
            btn.disabled = true;
            btn.innerText = "Memproses..."; // Opsional, ubah teks tombol
            }
            // Jika invalid, biarkan browser menampilkan pesan
        });
    </script>
    <script>
        function loadSubkelas() {
            const kelasId = document.getElementById('id_kelas').value;
            const subkelasSelect = document.getElementById('id_subkelas');
            subkelasSelect.innerHTML = '<option value="">Memuat...</option>';

            if (kelasId !== "") {
                fetch('get_subkelas.php?id_kelas=' + kelasId)
                    .then(res => res.json())
                    .then(data => {
                        subkelasSelect.innerHTML = '<option value="">--Subkelas--</option>';
                        data.forEach(item => {
                            const opt = document.createElement('option');
                            opt.value = item.id;
                            opt.textContent = item.nama_subkelas;
                            subkelasSelect.appendChild(opt);
                        });
                    })
                    .catch(err => {
                        subkelasSelect.innerHTML = '<option value="">Gagal memuat</option>';
                    });
            } else {
                subkelasSelect.innerHTML = '<option value="">--Subkelas--</option>';
            }
        }

        function loadSiswa() {
            const subkelasId = document.getElementById('id_subkelas').value;
            const siswaSelect = document.getElementById('nis');
            siswaSelect.innerHTML = '<option value="">Memuat...</option>';

            if (subkelasId !== "") {
                fetch('get_siswa.php?id_subkelas=' + subkelasId)
                    .then(res => res.json())
                    .then(data => {
                        siswaSelect.innerHTML = '<option value="">--Siswa--</option>';
                        data.forEach(item => {
                            const opt = document.createElement('option');
                            opt.value = item.nis;
                            opt.textContent = item.nama_siswa;
                            siswaSelect.appendChild(opt);
                        });
                    })
                    .catch(err => {
                        siswaSelect.innerHTML = '<option value="">Gagal memuat</option>';
                    });
            } else {
                siswaSelect.innerHTML = '<option value="">--Subkelas--</option>';
            }
        }
    </script>
    <script>
        function togglePassword() {
            const input = document.getElementById("inputPassword");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
</body>

</html>