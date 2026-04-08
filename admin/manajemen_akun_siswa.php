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
    <title>E-Exam | Manajemen Akun Siswa</title>

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
        #icon_dm_akun_siswa {color:white}
        #dm_akun_siswa {color:white; font-weight:bold}
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
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">Manajemen Akun Siswa</a>
                </nav>
                <div class="container-fluid">

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800">Manajemen Akun Siswa</h1>

<div class="d-flex flex-wrap align-items-center gap-2 mb-4">
    <!-- Tombol Tambah -->
    <button type="button" class="btn btn-secondary btn-icon-split" data-toggle="modal" data-target="#createModal">
        <span class="icon text-white-50">
            <i class="fas fa-plus"></i>
        </span>
        <span class="text">Tambah</span>
    </button>

    <!-- Bungkus tombol kanan dengan ms-auto -->
    <div class="d-flex gap-2 ms-auto">
        <!-- Tombol Generate -->
        <form method="POST" onsubmit="return confirm('Yakin ingin melakukan generate akun otomatis?')" style="margin:0">
            <button name="generate_akun" class="btn btn-secondary btn-icon-split">
                <span class="icon text-white-50">
                    <i class="fas fa-sync"></i>
                </span>
                <span class="text">Generate Akun</span>
            </button>
        </form>

        <!-- Tombol Hapus -->
        <form method="POST" onsubmit="return confirm('Yakin ingin menghapus data generated?')" style="margin:0">
            <button name="hapus_generate" class="btn btn-danger btn-icon-split">
                <span class="icon text-white-50">
                    <i class="fas fa-trash"></i>
                </span>
                <span class="text">Hapus Akun generate</span>
            </button>
        </form>
    </div>
</div>


<?php
    if (isset($_POST['generate_akun'])) {
        $db->exec("CALL sp_generate_akun_siswa_by_nis()");

        echo "<script>window.alert('Generate Akun Siswa Berhasil')</script>";
    }

    if (isset($_POST['hapus_generate'])) {
        $sql2 = "DELETE FROM users WHERE st_generate = 'Y' AND role = '2'";
        $stmt2 = $db->prepare($sql2);
        $stmt2->execute();

        echo "<script>window.alert('Hapus Akun Generate Berhasil')</script>";
    }

    $nama_kelas_filter = '';
    $nama_subkelas_filter = '';
    if (isset($_POST['refresh_filter'])) {
        $nama_kelas_filter = $_POST['nama_kelas_filter'];
        $nama_subkelas_filter = $_POST['nama_subkelas_filter'];
    }
?>

<div class="dis-none panel-filter w-full p-t-10">
    <form method="POST" action="manajemen_akun_siswa.php" style="width: 100%; margin: 0 auto; background-color: #f0f0f0; padding: 20px; border-radius: 8px;">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 7px;">
            <div class="w-full space-y-3 mb-4">
                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Kelas</label>
                    <select name="nama_kelas_filter" id="nama_kelas_filter" onchange="loadSubkelas2()" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value=''>Semua</option>
                        <?php
                            $sql3 = "SELECT id, nama_kelas FROM d_kelas ORDER BY nama_kelas";
                            $hasil3 = $db->query($sql3);
                            while ($baris3 = $hasil3->fetch(PDO::FETCH_ASSOC)) {
                                $nama_kelas = $baris3['nama_kelas'];
                        ?>
                        <option value="<?= $nama_kelas; ?>" <?= ($nama_kelas_filter == $nama_kelas) ? 'selected' : '' ?>><?= $nama_kelas; ?></option>
                        <?php } ?>
                    </select>
                </div>
                
                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Subkelas</label>
                    <select name="nama_subkelas_filter" id="nama_subkelas_filter" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value="" <?= $nama_subkelas_filter ? 'selected' : '' ?>>Semua</option>
                    </select><br>
                </div>
                <div>
                    <button name="refresh_filter" type="submit" class="px-4 py-2 text-white bg-blue-600 hover:bg-blue-700 text-sm rounded-md shadow">
                        Refresh
                    </button>
                </div>
            </div>
        </div>
    </form>
</div><br>
<div class="d-flex flex-wrap align-items-center gap-2 mb-4">
    <div class="d-flex gap-2 ms-auto">
        <form method="POST" style="margin:0" action="manajemen_akun_siswa_print.php">
            <input type='hidden' name='nama_kelas_filter' value='<?php echo $nama_kelas_filter;?>'/>
            <input type='hidden' name='nama_subkelas_filter' value='<?php echo $nama_subkelas_filter;?>'/>
            <button name="download_excel" class="btn btn-secondary btn-icon-split">
                <span class="icon text-white-50">
                    <i class="fas fa-print"></i>
                </span>
                <span class="text">Download Excel</span>
            </button>
        </form>
    </div>
</div>

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
                        <th style='text-align:center'>NIS</th>
                        <th style='text-align:center'>Nama Siswa</th>
                        <th style='text-align:center'>Jenis Kelamin</th>
                        <th style='text-align:center'>Username</th>
                        <th style='text-align:center'>Subkelas</th>
                        <th style='text-align:center'>Tahun Ajaran</th>
                        <th style='text-align:center'>Hasil Generate</th>
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

                        $sql = "SELECT s.nama_siswa, case when (gender = 'L') then 'Laki-laki' else 'Perempuan' end gender, 
                        s.nis, s.tanggal_lahir, k.nama_kelas, sk.nama_subkelas, ta.nama_tahun_ajaran, u.uname, u.st_generate, sk.urutan
                        from users u
                        left join d_siswa s on s.nis = u.uname
                        left join d_tahun_ajaran ta on ta.kode_tahun_ajaran = s.kode_tahun_ajaran
                        left join d_kelas k on k.id = s.id_kelas
                        left join d_subkelas sk on sk.id = s.id_subkelas
                        where ('$nama_kelas_filter' = '' or k.nama_kelas = '$nama_kelas_filter')
                        and ('$nama_subkelas_filter' = '' or sk.nama_subkelas = '$nama_subkelas_filter')
                        and u.role = '2'
                        order by sk.nama_subkelas";
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            $st_generate = $baris['st_generate'];
                            if ($st_generate == 'Y') {
                                $st_generate = 'Yes';
                            }
                            else {
                                $st_generate = 'No';
                            }
                            echo "<tr>";
                                echo "<td>".$baris['nis']."</td>";
                                echo "<td>".$baris['nama_siswa']."</td>";
                                echo "<td>".$baris['gender']."</td>";
                                echo "<td>".$baris['uname']."</td>";
                                echo "<td>".$baris['nama_subkelas']."</td>";
                                echo "<td>".$baris['nama_tahun_ajaran']."</td>";
                                echo "<td>".$st_generate."</td>";
                                echo "<td class='align-middle text-center'>
                                <div class='flex justify-center items-center space-x-2'>
                                    <form method='post' action='edit_manajemen_akun_siswa.php' class='inline-block'>
                                        <input type='hidden' name='nis' value='" . $baris['uname'] . "' />
                                        <button name='btn_edit' class='flex items-center bg-blue-500 hover:bg-blue-600 text-white text-sm font-medium py-1 px-3 rounded shadow'>
                                            <i class='fas fa-edit mr-1'></i>
                                            Reset Sandi
                                        </button>
                                    </form>

                                    <form method='post' action='hapus_akun_siswa.php' class='inline-block' onsubmit='return confirm(\"Yakin ingin menghapus data ini?\");'>
                                        <input type='hidden' name='uname' value='" . $baris['uname'] . "' />
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
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Akun Siswa</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="buat_manajemen_akun_siswa.php" method="post" style="padding:1% 3% 0 3%" id="form_tambah">
                    <!-- Pilihan Kelas -->
                    <p><b>Kelas</b></p>    
                    <select required name="id_kelas" id="id_kelas" onchange="loadSubkelas()" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <option value="">--Kelas--</option>
                        <?php
                            $sql2 = "SELECT id, nama_kelas from d_kelas order by nama_kelas";
                            $hasil2 = $db->query($sql2);
                            while($baris2 = $hasil2->fetch(PDO::FETCH_ASSOC)) {
                                echo "<option value='{$baris2['id']}'>{$baris2['nama_kelas']}</option>";
                            }
                        ?>
                    </select>

                    <!-- Pilihan Subkelas -->
                    <br><br><p><b>Subkelas</b></p>    
                    <select required name="id_subkelas" id="id_subkelas" onchange="loadSiswa()" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <option value="">--Subkelas--</option>
                    </select>

                    <!-- Pilihan Siswa -->
                    <br><br><p><b>Siswa</b></p>    
                    <select required name="nis" id="nis" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <option value="">--Siswa--</option>
                    </select><br><br>

                    <p><b>Password</b></p>
                    <div class="form-group" style="position: relative;">
                        <input required name="pword" type="password" class="form-control" id="inputPasswordz" placeholder="Masukkan Password">
                        
                        <!-- Tombol mata -->
                        <span onclick="togglePasswordz()" 
                            style="position:absolute; top:50%; right:10px; transform:translateY(-50%); cursor:pointer;">
                            👁️
                        </span>
                    </div>
                    
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
                        subkelasSelect.innerHTML = '<option value="">Semua</option>';
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
                subkelasSelect.innerHTML = '<option value="">--Semua--</option>';
            }
        }

        function loadSubkelas2(selectedValue = '') {
            const kelasId = document.getElementById('nama_kelas_filter').value;
            const subkelasSelect = document.getElementById('nama_subkelas_filter');
            subkelasSelect.innerHTML = '<option value="">Memuat...</option>';

            if (kelasId !== "") {
                fetch('get_subkelas_by_nama.php?nama_kelas=' + encodeURIComponent(kelasId))
                    .then(res => res.json())
                    .then(data => {
                        subkelasSelect.innerHTML = '<option value="">Semua</option>';
                        data.forEach(item => {
                            const opt = document.createElement('option');
                            opt.value = item.nama_subkelas;
                            opt.textContent = item.nama_subkelas;
                            if (item.nama_subkelas === selectedValue) {
                                opt.selected = true; // supaya tetap terpilih
                            }
                            subkelasSelect.appendChild(opt);
                        });
                    })
                    .catch(err => {
                        subkelasSelect.innerHTML = '<option value="">Gagal memuat</option>';
                    });
            } else {
                subkelasSelect.innerHTML = '<option value="">Semua</option>';
            }
        }

        // Jalankan otomatis setelah reload halaman
        document.addEventListener('DOMContentLoaded', function () {
            loadSubkelas2("<?= addslashes($nama_subkelas_filter ?? '') ?>");
        });

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
        function togglePasswordz() {
            const input = document.getElementById("inputPasswordz");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
</body>

</html>