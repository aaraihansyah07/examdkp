<?php
    ob_start();
	session_start();
		if ($_SESSION['fname'] == null) {
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

    <title>SISPEMDIF</title>

    <!-- Custom fonts for this template -->
    <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link
        href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
        rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/sb-admin-2.min.css" rel="stylesheet">

    <!-- Custom styles for this page -->
    <link href="vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">

</head>

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">

        <!-- Sidebar -->
        <ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

                        <!-- Sidebar - Brand -->
            <a class="sidebar-brand d-flex align-items-center justify-content-center" href="dashboard.php">
                <div class="sidebar-brand-text mx-3"><img src="../img/trans1.png" width="137%" style="margin-left:-20%"/></div>
            </a>

            <!-- Divider -->
            <hr class="sidebar-divider my-0">
            <!-- Nav Item - Pages Collapse Menu -->
            <li class="nav-item">
                 <a class="nav-link collapsed" href="dashboard.php">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Dashboard</span>
                </a>
                <hr class="sidebar-divider">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseTwo"
                    aria-expanded="true" aria-controls="collapseTwo">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Assesment</span>
                </a>
                <div id="collapseTwo" class="collapse" aria-labelledby="headingTwo" data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <a class="collapse-item" href="asesmen_diagnostik.php">Assesment Diagnostik</a>
                        <a class="collapse-item" href="asesmen_formatif.php">Assesment Formatif</a>
                    </div>
                </div>
                <hr class="sidebar-divider">
                <a class="nav-link collapsed" href="rubrik_diferensiasi.php">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Rubrik Diferensiasi</span>
                </a>
                <hr class="sidebar-divider">
                <a class="nav-link collapsed" href="materi_tugas.php">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Materi</span>
                </a>
            </li>
            <hr class="sidebar-divider">
            <!-- Nav Item - Utilities Collapse Menu -->
            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseUtilities2"
                    aria-expanded="true" aria-controls="collapseUtilities">
                    <i class="fas fa-fw fa-book"></i>
                    <span>Ruang Kelas</span>
                </a>
                <div id="collapseUtilities2" class="collapse" aria-labelledby="headingUtilities"
                    data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <?php 
                            include('config.php');
                            $sql = "SELECT*FROM master_kelas";
                            $hasil = mysqli_query($koneksi, $sql);
                            while ($baris = mysqli_fetch_array($hasil)) {
                        ?>
                        
                        <a class="collapse-item" href="ruang_kelas.php?id=<?php echo $baris['id']; ?>"><?php echo $baris['nama_kelas']; ?></a>
                        <?php
                            }
                        ?>
                    </div>
                </div>
            </li>
            <hr class="sidebar-divider">
            
            <!-- Nav Item - Utilities Collapse Menu -->
            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseUtilities"
                    aria-expanded="true" aria-controls="collapseUtilities">
                    <i class="fas fa-fw fa-wrench"></i>
                    <span>Hasil</span>
                </a>
                <div id="collapseUtilities" class="collapse" aria-labelledby="headingUtilities"
                    data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <a class="collapse-item" href="hasil_asesmen_diagnostik.php">Assesment Diagnostik</a>
                        <a class="collapse-item" href="hasil_asesmen_formatif.php">Assesment Formatif</a>
                    </div>
                </div>
            </li>
            <hr class="sidebar-divider">
            <!-- Sidebar Toggler (Sidebar) -->
            <div class="text-center d-none d-md-inline">
                <button class="rounded-circle border-0" id="sidebarToggle"></button>
            </div>

        </ul>
        <!-- End of Sidebar -->

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

<!-- Topbar -->
                <nav style="background:url('../img/mega_atas3.png')no-repeat 60% 50%" class="navbar navbar-expand navbar-light topbar mb-4 static-top shadow">

                    <!-- Sidebar Toggle (Topbar) -->
                    <form class="form-inline">
                        <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
                            <i class="fa fa-bars"></i>
                        </button>
                    </form>

                    <!-- Topbar Search -->
                    <form
                        class="d-none d-sm-inline-block form-inline mr-auto ml-md-3 my-2 my-md-0 mw-100 navbar-search">
                        <div class="input-group">
                            <input type="text" class="form-control bg-light border-0 small" placeholder="Search for..."
                                aria-label="Search" aria-describedby="basic-addon2">
                            <div class="input-group-append">
                                <button class="btn btn-primary" type="button">
                                    <i class="fas fa-search fa-sm"></i>
                                </button>
                            </div>
                        </div>
                    </form>

                    <!-- Topbar Navbar -->
                    <ul class="navbar-nav ml-auto">

                        <!-- Nav Item - Search Dropdown (Visible Only XS) -->
                        <li class="nav-item dropdown no-arrow d-sm-none">
                            <a class="nav-link dropdown-toggle" href="#" id="searchDropdown" role="button"
                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="fas fa-search fa-fw"></i>
                            </a>
                            <!-- Dropdown - Messages -->
                            <div class="dropdown-menu dropdown-menu-right p-3 shadow animated--grow-in"
                                aria-labelledby="searchDropdown">
                                <form class="form-inline mr-auto w-100 navbar-search">
                                    <div class="input-group">
                                        <input type="text" class="form-control bg-light border-0 small"
                                            placeholder="Search for..." aria-label="Search"
                                            aria-describedby="basic-addon2">
                                        <div class="input-group-append">
                                            <button class="btn btn-primary" type="button">
                                                <i class="fas fa-search fa-sm"></i>
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </li>
                        <div class="topbar-divider d-none d-sm-block"></div>

                        <!-- Nav Item - User Information -->
                        <li class="nav-item dropdown no-arrow">
                            <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button"
                                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <span class="mr-2 d-none d-lg-inline text-gray-600 small"><?php echo $_SESSION['fname']?></span>
                                <img class="img-profile rounded-circle"
                                    src="img/undraw_profile.svg">
                            </a>
                            <!-- Dropdown - User Information -->
                            <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in"
                                aria-labelledby="userDropdown">
                                <a class="dropdown-item" href="#">
                                    <i class="fas fa-user fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Profile
                                </a>
                                <a class="dropdown-item" href="#">
                                    <i class="fas fa-cogs fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Settings
                                </a>
                                <a class="dropdown-item" href="#">
                                    <i class="fas fa-list fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Activity Log
                                </a>
                                <div class="dropdown-divider"></div>
                                <a class="dropdown-item" href="#" data-toggle="modal" data-target="#logoutModal">
                                    <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-400"></i>
                                    Logout
                                </a>
                            </div>
                        </li>

                    </ul>

                </nav>
                <nav style="margin-top:-2.5%; background:#3d6092; height:35px" class="navbar navbar-expand navbar-light topbar mb-2 static-top shadow">
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">View Materi</a>
                </nav>

                <div class="container-fluid">
<?php
    $id = $_GET['id'];
    $id_siswa = $_SESSION['user_id'];
    $kode_assign = $_GET['kode_assign'];
    $id_kelas = $_GET['id_kelas'];
    $id_mapel = $_GET['id_mapel'];
    $kode_materi = $_GET['kode_materi'];
    $nama_materi = $_GET['nama_materi'];
    
?>

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800"><?php echo $nama_materi;?></h1>
        <a href="detail_penilaian_pembelajaran.php?id_kelas=<?php echo $id_kelas;?>&id_mapel=<?php echo $id_mapel;?>" class="btn btn-secondary btn-icon-split">
                    <span class="icon text-white-50">
                        <i class="fas fa-arrow-left"></i>
                    </span>
                    <span class="text">Kembali</span>
        </a><br><br>
<!-- DataTales Example -->
<div class="card shadow mb-4" style="padding:2%">
<?php
    include('config.php');
    $sql = "SELECT hasil_nilai from pengerjaan_asesmen_diagnostik where id_siswa = $id_siswa AND kode_assign = '$kode_assign'";
    $hasil = mysqli_query($koneksi, $sql);
    $baris = mysqli_fetch_array($hasil);
    

    if(empty($baris['hasil_nilai'])) {
        echo "HARAP KERJAKAN <a style='color:red'>PENILAIAN SEBELUM PEMBELAJARAN</a> TERLEBIH DAHULU UNTUK MENGAKSES PENILAIAN PEMBELAJARAN INI";
    }
    else {
        $hasil_nilai = $baris['hasil_nilai'];
        $sql4 = "SELECT level
        FROM rubrik_asesmen
        WHERE $hasil_nilai BETWEEN rentang_from AND rentang_to AND kode_assign = '$kode_assign'";
        $hasil4 = mysqli_query($koneksi, $sql4);
        $baris4 = mysqli_fetch_array($hasil4);
        $level = $baris4['level'];

        $sql5 = "SELECT isi_materi from detail_materi_tugas where seq_rubrik_asesmen = $level";
        $hasil5 = mysqli_query($koneksi, $sql5);
        $baris5 = mysqli_fetch_array($hasil5);
        $isi_materi = $baris5['isi_materi'];
        echo "<h6 style='font-weight:bold'>Soal</h6>";
        echo "<p style='text-align:justify'>$isi_materi</p>";
    }
?>
</div>

<div class="card shadow mb-4" style="padding:2%">
<h6 style='font-weight:bold'>Jawab</h6>
<form method='post' action='#' enctype='multipart/form-data'>
    <textarea style="height:300px" name="jawaban" style="border-radius:5px" class="form-control form-control-user" id="exampleInputPassword" placeholder="Tulis jawaban..."></textarea><br>
    Atau upload file&nbsp<input type="file" name="uploadfile"/>
    <div class="modal-footer">
        <button class="btn btn-primary" name="kirim">Kumpulkan</button>
    </div>
</form>
</div>
<?php
    if (isset($_POST['kirim'])) {
        $jawaban = $_POST['jawaban'];

        $sqlb = "INSERT INTO pengerjaan_asesmen_formatif(kode_materi, id_siswa, kode_assign, status_pengerjaan) VALUES
        ('$kode_materi', $id_siswa, '$kode_assign', 'Y')";
        $hasilb = mysqli_query($koneksi, $sqlb);

        $sqlc = "SELECT max(id) maxid from pengerjaan_asesmen_formatif where kode_materi = '$kode_materi'";
        $hasilc = mysqli_query($koneksi, $sqlc);
        $barisc = mysqli_fetch_array($hasilc);
        $maxid = $barisc['maxid'];

        $sqld = "INSERT INTO pengerjaan_asesmen_formatif_dtl(kode_materi, kode_assign, jawaban_panjang, id_pengerjaan)
        VALUES('$kode_materi', '$kode_assign', '$jawaban', $maxid)";
        $hasild = mysqli_query($koneksi, $sqld);
        
    }
?>
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
                    <a class="btn btn-primary" href="../admin/hapus_akun_admin.php?id=<?php echo $adminid; ?>">Hapus</a>
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

</body>

</html>