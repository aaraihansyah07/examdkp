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
                        <a class="collapse-item" href="#">Assesment Sumatif</a>
                    </div>
                </div>
                <hr class="sidebar-divider">
                <a class="nav-link collapsed" href="#">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Materi</span>
                </a>
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
                        <a class="collapse-item" href="#">Assesment Diagnostik</a>
                        <a class="collapse-item" href="asesmen_formatif.php">Assesment Formatif</a>
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
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">Asesmen Diagnostik</a>
                </nav>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <!-- Page Heading -->
                    <h1 class="h3 mb-2 text-gray-800 ml-1">Asesmen Diagnostik</h1>
                    <!-- DataTales Example -->
                   <div class="row">
                    
                   <div class="col-xl-3 col-lg-4">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div
                                    class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Kerjakan Asesmen</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                    <form class="user" action="asesmen_diagnostik.php" method="post">
                                        <?php
                                            include('config.php');
                             

                                        ?>
                                        <p><b>Kode Asesmen</b></p>
                                        <div class="form-group">
                                            <input required name="exname" type="text" class="form-control form-control-user"
                                                id="exampleInputPassword" placeholder="Nama Asesmen">
                                        </div>
                                        <p><b>Waktu Asesmen</b></p>
                                        <div class="form-group">
                                            <input name="extime" type="datetime-local" class="form-control form-control-user"
                                                id="exampleInputPassword">
                                        </div>
                                        <p><b>Waktu Penyerahan</b></p>
                                        <div class="form-group">
                                            <input name="subt" type="datetime-local" class="form-control form-control-user"
                                                id="exampleInputPassword">
                                        </div>
                                        <p><b>Keterangan</b></p>
                                        <div class="form-group">
                                            <input name="desp" type="text" class="form-control form-control-user"
                                                id="exampleInputPassword" placeholder="Keterangan">
                                        </div>
                                        <button name="add_exam" class="btn btn-primary btn-user btn-block">Buat [+]</button>
                                    </form>
                                    <?php
                                        if (isset($_POST['add_exam'])) {
                                            include('config.php');
                                            $nama_exam = $_POST['exname'];
                                            $waktu_asesmen = $_POST['extime'];
                                            $waktu_penyerahan = $_POST['subt'];
                                            $keterangan = $_POST['desp'];
                                            $kelas = $_POST['kelas'];

                                            $sql2 = "INSERT INTO exm_list(exname, extime, subt, desp, kelas, id_mata_pelajaran, id_guru, status_assign) VALUES('$nama_exam', '$waktu_asesmen', '$waktu_penyerahan', '$keterangan', $kelas, $subject_guru, $id_guru, 'N')";
                                            $hasil2 = mysqli_query($koneksi, $sql2);
                                            
                                            //header('location:asesmen_diagnostik.php');
                                        }
                                    ?>
                                </div>
                            </div>
                        </div>

                    <div class="col-xl-9 col-lg-8">
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Daftar Asesmen Saya</h6>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>No</th>
                                            <th>Nama Asesmen</th>
                                            <th>Keterangan</th>
                                            <th>Waktu Asesmen</th>
                                            <th>Waktu Penyerahan</th>
                                            <th>Status Assign</th>
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
                                            include('config.php');
                                        	$sql = "SELECT*from exm_list where id_guru = $id_guru";
                                            $hasil = mysqli_query($koneksi, $sql);

                                            while ($baris = mysqli_fetch_array($hasil)) {
                                                echo "<tr>";
                                                    echo "<td>".$no++."</td>";
                                                    echo "<td>".$baris['exname']."</td>";
                                                    echo "<td>".$baris['desp']."</td>";
                                                    echo "<td>".$baris['extime']."</td>";
                                                    echo "<td>".$baris['subt']."</td>";
                                                    echo "<td>".$baris['status_assign']."</td>";
                                                    echo "<td><a href='hapus_asesmen_diagnostik.php?exid=".$baris['exid']."' class='btn btn-primary btn-icon-split btn-sm'>
                                                    <span class='icon text-white-50'>
                                                        <i class='fas fa-trash'></i>
                                                    </span>
                                                     </a> | <a href='buatsoal_asesmen_diagnostik?exid=".$baris['exid']."' class='btn btn-primary btn-icon-split btn-sm'>
                                                     <span class='icon text-white-50'>
                                                         <i class='fas fa-edit'></i>
                                                     </span>
                                                      </a></td>";
                                                echo "</tr>";
                                            }
                                        ?>
                                    </tbody>
                                </table>
                            </div>
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