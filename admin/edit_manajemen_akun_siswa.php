<?php
    ob_start();
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

    <title>E-Exam | Reset Akun Siswa</title>

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
        ?>

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

<!-- Topbar -->
                <?php include ('topbar.php');?> 
                <nav style="margin-top:-2.5%; background:#3d4857; height:35px" class="navbar navbar-expand navbar-light topbar mb-2 static-top shadow">
                    <a href="manajemen_akun_siswa.php" style="color:white; margin-left:1.3%; font-size:90%">Manjemen Akun Siswa ></a>
                    <a href="#" style="color:white; margin-left:0.5%; font-size:90%">Reset Akun Siswa</a>
                </nav>

                <div class="container-fluid">

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800">Reset Akun Siswa</h1>
        <a href="manajemen_akun_siswa.php" class="btn btn-secondary btn-icon-split">
                    <span class="icon text-white-50">
                        <i class="fas fa-arrow-left"></i>
                    </span>
                    <span class="text">Kembali</span>
        </a><br><br>
<!-- DataTales Example -->
<div class="card shadow mb-4">
<?php
    include('config.php');
    if (isset($_POST['btn_edit'])) {
        $nis = $_POST['nis'];

        $sql = "SELECT s.nama_siswa, case when (gender = 'L') then 'Laki-laki' else 'Perempuan' end gender, 
        s.nis, s.tanggal_lahir, k.nama_kelas, sk.nama_subkelas, ta.nama_tahun_ajaran, u.uname, k.id id_kelas, sk.id id_subkelas
        from users u
        left join d_siswa s on s.nis = u.uname
        left join d_tahun_ajaran ta on ta.kode_tahun_ajaran = s.kode_tahun_ajaran
        left join d_kelas k on k.id = s.id_kelas
        left join d_subkelas sk on sk.id = s.id_subkelas
        where s.nis = '$nis'";
        $hasil = $db->query($sql);
        $baris = $hasil->fetch(PDO::FETCH_ASSOC);
    }

?>
<form class="user" action="proses_edit_manajemen_akun_siswa.php" method="post" style="padding:2% 2% 0 2%">
  <div style="display: flex; flex-wrap: wrap; gap: 20px;">
    
    <!-- Kolom Kiri -->
    <div style="flex: 1; min-width: 300px;">
        <input type='hidden' name='nis' value='<?php echo $nis;?>'/>
        <!-- Pilihan Kelas -->
        <p><b>Kelas</b></p>    
        <select required disabled name="id_kelas" id="id_kelas" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
            <option value="<?php echo $baris['id_kelas'];?>"><?php echo $baris['nama_kelas'];?></option>
        </select>
        
        <!-- Pilihan Siswa -->
        <br><br><p><b>Nama Siswa</b></p>    
        <select required disabled name="nis" id="nis" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
            <option value="<?php echo $baris['nis'];?>"><?php echo $baris['nama_siswa'];?></option>
        </select><br><br>
    </div>

    <!-- Kolom Kanan -->
    <div style="flex: 1; min-width: 300px;">
        <!-- Pilihan Subkelas -->
        <p><b>Subkelas</b></p>    
        <select required disabled name="id_subkelas" id="id_subkelas" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
            <option value="<?php echo $baris['id_subkelas'];?>"><?php echo $baris['nama_subkelas'];?></option>
        </select>

        <br><br><p><b>Password</b></p>
        <div class="form-group" style="position: relative;">
            <input required name="pword" type="password" class="form-control" id="inputPassword2" placeholder="Masukkan Password">
            
            <!-- Tombol mata -->
            <span onclick="togglePassword2()" 
                style="position:absolute; top:50%; right:10px; transform:translateY(-50%); cursor:pointer;">
                👁️
            </span>
        </div>
    </div>
    
  </div> <!-- penutup flex -->

  <br>
  <div class="modal-footer">
    <a href="manajemen_akun_siswa.php" class="btn btn-primary" style="border:none; background:red">Cancel</a>
    <button class="btn btn-primary" type="submit" name="edit_akun">Save</button>
  </div>
</form>

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

    <!-- Delete Modal-->
    <div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Konfirmasi</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <div class="modal-body">Hapus data ini?</div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                    <a class="btn btn-primary" href="../admin/hapus_data_master_subkelas.php?id=<?php echo $kelasid; ?>">Hapus</a>
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
    <script src="vendor/datatables/jquery.dataTables.min.js"></script>
    <script src="vendor/datatables/dataTables.bootstrap4.min.js"></script>

    <!-- Page level custom scripts -->
    <script src="js/demo/datatables-demo.js"></script>

    <script>
        function togglePassword2() {
            const input = document.getElementById("inputPassword2");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>

</body>

</html>