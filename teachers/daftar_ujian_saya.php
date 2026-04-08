<?php
    ob_start();
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '1') {
        header('location:../login.php');
    }

    if (isset($_GET['e'])) {
        echo "<script>window.alert('Berhasil melakukan edit')</script>";
    }
    else if (isset($_GET['h'])) {
        echo "<script>window.alert('Berhasil melakukan hapus')</script>";
    }
    else if (isset($_GET['dct'])) {
        echo "<script>window.alert('Guru dengan NIP ini sudah ada')</script>";
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
    <title>E-Exam | Daftar Ujian Saya</title>

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
        #icon_daftar_ujian_saya {color:white}
        #daftar_ujian_saya {color:white; font-weight:bold}
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
                    <a href="#" style="color:white; margin-left:0.8%; font-size:90%">Daftar Ujian Saya</a>
                </nav>
                <div class="container-fluid">


<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800">Daftar Ujian Saya</h1><br>
<?php
    $kode_guru = $_SESSION['uname'];
    //$kode_guru = $_SESSION['uname'];
    $nama_kelas_filter = '';
    $nama_subkelas_filter = '';
    $kode_mata_pelajaran_filter = '';
    $jenis_ujian_filter = '';
    $st_posting_filter = '';

    if (isset($_GET['kls'])) {
        $nama_kelas_filter = $_GET['kls'];
    }
    if (isset($_GET['mp'])) {
        $kode_mata_pelajaran_filter = $_GET['mp'];
    }
    if (isset($_GET['ju'])) {
        $jenis_ujian_filter = $_GET['ju'];
    }

    // if (isset($_GET['sk'])) {
    //     $nama_subkelas_filter = $_GET['sk'];
    // }

    if (isset($_POST['refresh_filter'])) {
        $nama_kelas_filter = $_POST['nama_kelas_filter'];
        $kode_mata_pelajaran_filter = $_POST['kode_mata_pelajaran_filter'];
        $jenis_ujian_filter = $_POST['jenis_ujian_filter'];
        $nama_subkelas_filter = $_POST['nama_subkelas_filter'];
        $st_posting_filter = $_POST['st_posting_filter'];
    }
?>

<div class="dis-none panel-filter w-full p-t-10">
    <form method="POST" action="daftar_ujian_saya.php" style="width: 100%; margin: 0 auto; background-color: #f0f0f0; padding: 12px; border-radius: 8px;">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 7px;">
            <div class="w-full space-y-3 mb-4">

                <!-- Baris Kelas -->
                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-kelas" class="w-32 text-base text-gray-700">Kelas</label>
                    <select name="nama_kelas_filter" id="nama_kelas_filter" onchange="loadSubkelas2()" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value="">Semua</option>
                        <?php
                            $sql2 = "SELECT id, nama_kelas FROM d_kelas ORDER BY nama_kelas";
                            $hasil2 = $db->query($sql2);
                            while ($baris2 = $hasil2->fetch(PDO::FETCH_ASSOC)) {
                                $nama_kelas = $baris2['nama_kelas'];
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

                <!-- Baris Mata Pelajaran -->
                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Mata Pelajaran</label>
                    <select name="kode_mata_pelajaran_filter" id="jenis-sewa-mapel" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value="">Semua</option>
                        <?php
                            $sql2b = "SELECT mp.kode_mata_pelajaran, mp.nama_mata_pelajaran 
                                    FROM d_mata_pelajaran mp
                                    WHERE EXISTS (
                                        SELECT 1 FROM d_penempatan_mapel_guru pg 
                                        WHERE kode_guru = '$kode_guru' 
                                        AND mp.kode_mata_pelajaran = pg.kode_mata_pelajaran
                                    )
                                    ORDER BY mp.nama_mata_pelajaran";
                            $hasil2b = $db->query($sql2b);
                            while ($baris2b = $hasil2b->fetch(PDO::FETCH_ASSOC)) {
                                $kode = $baris2b['kode_mata_pelajaran'];
                                $nama = $baris2b['nama_mata_pelajaran'];
                        ?>
                        <option value="<?= $kode; ?>" <?= ($kode_mata_pelajaran_filter == $kode) ? 'selected' : '' ?>><?= $nama; ?></option>
                        <?php } ?>
                    </select>
                </div>

                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Jenis Ujian</label>
                    <select name="jenis_ujian_filter" id="jenis-sewa-mapel" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                       <option value="">Semua</option>
                       <?php
                            $sqld = "SELECT kode_jenis_ujian, nama_jenis_ujian from d_jenis_ujian where kode_jenis_ujian <> 'OSIS' order by nama_jenis_ujian";
                            $hasild = $db->query($sqld);

                            while ($barisd = $hasild->fetch(PDO::FETCH_ASSOC)) {
                                $kode_jenis_ujian = $barisd['kode_jenis_ujian'];
                                $nama_jenis_ujian = $barisd['nama_jenis_ujian'];
                        ?>
                            <option value="<?= $kode_jenis_ujian; ?>" <?= ($jenis_ujian_filter == $kode_jenis_ujian) ? 'selected' : '' ?>><?= $nama_jenis_ujian; ?></option>
                        <?php
                            }
                        ?>
                    </select>
                </div>

                <div class="flex flex-wrap items-center gap-2">
                    <label for="jenis-sewa-mapel" class="w-32 text-base text-gray-700">Status</label>
                    <select name="st_posting_filter" id="jenis-sewa-mapel" class="flex-1 min-w-[150px] px-3 py-2 text-sm border border-gray-300 rounded-md">
                        <option value="">Semua</option>
                        <option value="<?= 'Y'; ?>" <?= ($st_posting_filter == 'Y') ? 'selected' : '' ?>><?= 'Sudah Diposting'; ?></option>
                        <option value="<?= 'N'; ?>" <?= ($st_posting_filter == 'N') ? 'selected' : '' ?>><?= 'Draft'; ?></option>
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
                        <th style='text-align:center'>Mata Pelajaran</th>
                        <th style='text-align:center'>Nama Ujian</th>
                        <th style='text-align:center'>Nama Bab/Materi</th>
                        <th style='text-align:center'>Subkelas</th>
                        <th style='text-align:center'>Jumlah Soal</th>
                        <th style='text-align:center'>Durasi</th>
                        <th style='text-align:center'>Token</th>
                        <th style='text-align:center'>Tanggal Ujian</th>
                        <th style='text-align:center'>Status Posting</th>
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

                        if ($st_posting_filter == 'Y') {
                            $st_posting_filter = "h.st_posting = 'Y'";
                        }
                        else if ($st_posting_filter == 'N') {
                            $st_posting_filter = "h.st_posting is null";
                        }
                        else {
                            $st_posting_filter = "h.st_posting is not null or h.st_posting is null";
                        }

                        $sql = "SELECT h.st_susulan, to_char(tanggal_ujian, 'DD-MON-YYYY') tanggal_ujian, case when (st_posting is null) then 'Draft' when (st_posting = 'Y') then 'Sudah diposting' end st_posting, id_ujian_hdr, h.id_ujian, h.kode_ujian, k.nama_kelas, sk.nama_subkelas, uuidguru,
                        waktu_mulai, waktu_berakhir, u.nama_ujian, h.nama_bab, mp.nama_mata_pelajaran, h.durasi, h.token,
                        (select count(id_ujian_hdr) from f_soal_dtl d where d.id_ujian_hdr = h.id_ujian_hdr) jumlah_soal
                        FROM F_SOAL_HDR h
                        left join d_ujian u on u.kode_ujian = h.kode_ujian
                        left join d_kelas k on k.id = h.id_kelas
                        left join d_subkelas sk on sk.id = h.id_subkelas
                        left join d_mata_pelajaran mp on mp.kode_mata_Pelajaran = h.kode_mata_pelajaran
                        where (h.kode_guru = '$kode_guru')
                        and ('$nama_kelas_filter' = '' or k.nama_kelas = '$nama_kelas_filter')
                        and ('$nama_subkelas_filter' = '' or sk.nama_subkelas = '$nama_subkelas_filter')
                        and ('$jenis_ujian_filter' = '' or u.jenis_ujian = '$jenis_ujian_filter')
                        and ('$kode_mata_pelajaran_filter' = '' or h.kode_mata_Pelajaran = '$kode_mata_pelajaran_filter')
                        and ($st_posting_filter)
                        order by sk.nama_subkelas";                       
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            if ($baris['st_susulan'] == 'Y') {
                                $caption_tbh = 'Susulan';
                            }
                            else {
                                $caption_tbh = '';
                            }
                            echo "<tr>";
                                echo "<td>".$baris['nama_mata_pelajaran']."</td>";
                                echo "<td>".$caption_tbh. " ". $baris['nama_ujian']."</td>";
                                echo "<td>".$baris['nama_bab']."</td>";
                                echo "<td>".$baris['nama_subkelas']."</td>";
                                echo "<td>".$baris['jumlah_soal']."</td>";
                                echo "<td>".$baris['durasi']." menit</td>";
                                echo "<td>".$baris['token']."</td>";
                                echo "<td>".$baris['tanggal_ujian']."</td>";
                                 echo "<td>".$baris['st_posting']."</td>";
                                echo "<td class='align-middle text-center'>
                                <div class='flex justify-center items-center space-x-2'>
                                    <form method='post' action='daftar_ujian_saya_edit.php' class='inline-block'>
                                        <input type='hidden' name='mp' value='" . $kode_mata_pelajaran_filter . "' />
                                        <input type='hidden' name='kls' value='" . $nama_kelas_filter . "' />
                                        <input type='hidden' name='ju' value='" . $jenis_ujian_filter . "' />
                                        <input type='hidden' name='sk' value='" . $nama_subkelas_filter . "' />
                                        <input type='hidden' name='id_ujian_hdr' value='" . $baris['id_ujian_hdr'] . "' />
                                        <button name='btn_edit' class='flex items-center bg-blue-500 hover:bg-blue-600 text-white text-sm font-medium py-1 px-3 rounded shadow'>
                                            <i class='fas fa-edit mr-1'></i>
                                            Edit
                                        </button>
                                    </form>

                                    <form method='post' action='daftar_ujian_saya_hapus.php' class='inline-block' onsubmit='return confirm(\"Yakin ingin menghapus data ini?\");'>
                                        <input type='hidden' name='mp' value='" . $kode_mata_pelajaran_filter . "' />
                                        <input type='hidden' name='kls' value='" . $nama_kelas_filter . "' />
                                        <input type='hidden' name='ju' value='" . $jenis_ujian_filter . "' />
                                        <input type='hidden' name='id_ujian_hdr' value='" . $baris['id_ujian_hdr'] . "' />
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
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Ujian</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="buat_data_master_guru.php" method="post" style="padding:1% 3% 0 3%" id="form_tambah">
                    <div style="flex: 1; margin-right: 10px; margin-bottom: 10px;">
                    <p><b>NIP</b></p>
                    <div class="form-group">
                        <input required name="nip" type="text" class="form-control" id="exampleInputPassword">
                    </div>
                    <p><b>Nama</b></p>
                    <div class="form-group">
                        <input required name="nama_guru" type="text" class="form-control" id="exampleInputPassword">
                    </div>
                    <!-- <p><b>Tanggal Lahir</b></p>
                    <div class="form-group">
                        <input required name="tanggal_lahir" type="date" class="form-control">
                    </div> -->
                    <p><b>Gender</b></p>    
                    <select required name="gender" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <option value="">--Gender--</option>
                        <option value="L">Laki-laki</option>
                        <option value="P">Perempuan</option>
                    </select><br><br>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="submit" data-dismiss="modal">Cancel</button>
                        <button class="btn btn-primary" type="submit" name="buat_akun" id="btn_tambah">Tambah</button>
                    </div>
                </form>
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
        function togglePassword() {
            const input = document.getElementById("inputPassword");
            input.type = input.type === "password" ? "text" : "password";
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
    </script>
</body>

</html>