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

    <title>SISPEMDIF | Asesmen Diagnostik</title>

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
        #nav_content:hover {background:#edf0f7; border-radius:10px}
    </style>

</head>

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">

        <!-- Sidebar -->
        <ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

                        <!-- Sidebar - Brand -->
            <a class="sidebar-brand d-flex align-items-center justify-content-center" href="index.html">
                <div class="sidebar-brand-text mx-3"><img src="../img/trans1.png" width="137%" style="margin-left:-20%"/></div>
            </a>

            <!-- Divider -->
            <hr class="sidebar-divider my-0">
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
                <nav style="margin-top:-2.5%; background:#3d4857; height:35px" class="navbar navbar-expand navbar-light topbar mb-2 static-top shadow">
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">Ruang kelas</a>
                </nav>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <!-- Page Heading -->
                    <?php
                        include('config.php');
                        $fname = $_SESSION['fname'];
                        $id_guru = $_SESSION['user_id'];
                        $id_mapel = $_SESSION['subject'];
                        $id_kelas = $_GET['id'];
                        $sql = "SELECT nama_kelas from master_kelas where id = $id_kelas";
                        $hasil = mysqli_query($koneksi, $sql);
                        $baris = mysqli_fetch_array($hasil);
                        
                        
                    ?>
                    <h1 class="h3 mb-2 text-gray-800 ml-1">Kelas <?php echo $baris['nama_kelas']; ?></h1>
                    <button data-toggle="modal" data-target="#viewModal" class="btn btn-secondary btn-icon-split">
                                        <span class="text">Lihat Daftar Siswa</span>
                    </button><br><br>
                    <!-- DataTales Example -->
                   <div class="row">
                    
                   <div class="col-xl-4 col-lg-5">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div
                                    class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Asesmen Diagnostik Saya</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">                                        
                                    <?php
                                        $sql2 = "SELECT exid, exname FROM exm_list where id_guru = $id_guru AND kelas = $id_kelas AND status_assign = 'Y'";
                                        $hasil2 = mysqli_query($koneksi, $sql2);

                                        while ($baris2 = mysqli_fetch_array($hasil2)) {
                                    ?>
                                        <a class="nav-link collapsed" style="padding:none" href="buatsoal_asesmen_diagnostik.php?exid=<?php echo $baris2['exid'];?>" id="nav_content">
                                            <span style='font-weight:bold; color:green; text-transform:uppercase'><?php echo $baris2['exname']; ?></span><br>
                                        </a>
                                        <hr class="sidebar-divider" style="margin-top:3%">
                                    <?php
                                        }
                                    ?>
                                </div>
                            </div>
                    </div>

                    <div class="col-xl-4 col-lg-5">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div
                                    class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Materi Saya</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                <?php
                                        $sql3 = "SELECT id, nama_materi, kode_materi FROM materi_tugas where id_guru = $id_guru AND id_kelas = $id_kelas";
                                        $hasil3 = mysqli_query($koneksi, $sql3);

                                        while ($baris3 = mysqli_fetch_array($hasil3)) {
                                    ?>
                                        <a class="nav-link collapsed" style="padding:none" href="view_materi_guru.php?id=<?php echo $baris3['id'];?>" id="nav_content">
                                            <span style='font-weight:bold; color:green; text-transform:uppercase'><?php echo $baris3['nama_materi']; ?></span><br>
                                        </a>
                                        <hr class="sidebar-divider" style="margin-top:3%">
                                    <?php
                                        }
                                    ?>
                                </div>
                            </div>
                     </div>

                     <div class="col-xl-4 col-lg-5">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div
                                    class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Asesmen Formatif Saya</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                    <?php
                                        $sql4 = "SELECT id, nama_materi, kode_materi FROM soal_formatif_pbl where id_guru = $id_guru AND id_kelas = $id_kelas";
                                        $hasil4 = mysqli_query($koneksi, $sql4);

                                        while ($baris4 = mysqli_fetch_array($hasil4)) {
                                    ?>
                                        <a class="nav-link collapsed" style="padding:none" href="view_soal_asesmen_formatif.php?id=<?php echo $baris4['id'];?>" id="nav_content">
                                            <span style='font-weight:bold; color:green; text-transform:uppercase'><?php echo $baris4['nama_materi']; ?></span><br>
                                        </a>
                                        <hr class="sidebar-divider" style="margin-top:3%">
                                    <?php
                                        }
                                    ?>
                                </div>
                            </div>
                     </div>
                </div>
                </div>
                <!-- /.container-fluid -->

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

    <!-- View Modal-->
    <div class="modal fade" id="viewModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <?php
                        $sql3 = "SELECT COUNT(kelas) jml_siswa from users where kelas = $id_kelas";
                        $hasil3 = mysqli_query($koneksi, $sql3);
                        $baris3 = mysqli_fetch_array($hasil3);

                        $sql4 = "SELECT fname from users where kelas = $id_kelas";
                        $hasil4 = mysqli_query($koneksi, $sql4);
                        
                    ?>
                    <h5 class="modal-title" id="exampleModalLabel">Jumlah : <?php echo $baris3['jml_siswa']?> Siswa</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <div class="modal-body">
                    <?php
                        while ($baris4 = mysqli_fetch_array($hasil4)) {
                    ?>
                        <div style="display:inline-block; margin:1%; width:30%">
                            <a class="btn btn-success btn-circle btn-lg">
                                <i class="fas fa-user"></i><br>
                            </a><br>
                            <a style="font-size:small"><?php echo $baris4['fname']; ?></a>
                        </div>
                    <?php
                        }
                    ?>

                </div>
                <!-- <div class="modal-footer">
                    <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                    <a class="btn btn-primary" href="../logout.php">Logout</a>
                </div> -->
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