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
                <a class="nav-link collapsed" href="ruang_kelas.php">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Ruang Kelas</span>
                </a>
            </li>
            <hr class="sidebar-divider">
            
            <!-- Nav Item - Utilities Collapse Menu -->
            <!-- <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseUtilities"
                    aria-expanded="true" aria-controls="collapseUtilities">
                    <i class="fas fa-fw fa-wrench"></i>
                    <span>Hasil</span>
                </a>
                <div id="collapseUtilities" class="collapse" aria-labelledby="headingUtilities"
                    data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <a class="collapse-item" href="#">Assesment Diagnostik</a>
                        <a class="collapse-item" href="hasil_asesmen_formatif.php">Assesment Formatif</a>
                        <a class="collapse-item" href="#">Assesment Sumatif</a>
                    </div>
                </div>
            </li> -->
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
                    <a href="ruang_kelas.php" style="color:white; margin-left:1.3%; font-size:90%">Kelas Siswa ></a>
                    <a href="#" style="color:white; margin-left:0.5%; font-size:90%">Penilaian Pembelajaran</a>
                </nav>
                <div class="container-fluid">
                <?php
                    include('config.php');
                    $id_mapel = $_GET['id_mapel'];
                    $id_kelas = $_GET['id_kelas'];
                    $id_siswa = $_SESSION['user_id'];
                    $sql2 = "SELECT NAMA_MATA_PELAJARAN FROM MASTER_MATA_PELAJARAN WHERE id = $id_mapel";
                    $hasil2 = mysqli_query($koneksi, $sql2);
                    $baris2 = mysqli_fetch_array($hasil2);

                ?>

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800"><?php echo $baris2['NAMA_MATA_PELAJARAN']; ?></h1>
<a href="ruang_kelas.php" class="btn btn-secondary btn-icon-split">
    <span class="icon text-white-50">
        <i class="fas fa-arrow-left"></i>
    </span>
    <span class="text">Kembali</span>
</a><br><br>
<!-- DataTales Example -->
<div class="card shadow mb-4">
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary">DataTables Example</h6>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Materi</th>
                        <th>Status Pengerjaan</th>
                        <th>Nilai</th>
                        <th>Feedback guru</th>
                        <!-- <th>Mulai Pengerjaan</th>
                        <th>Akhir Pengerjaan</th> -->
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
                        $sql = "SELECT id, exid, kode_materi, nama_materi, kode_assign from soal_formatif_pbl where id_kelas = $id_kelas AND id_mata_pelajaran = $id_mapel
                        ";
                        $hasil = mysqli_query($koneksi, $sql);
                        

                        while ($baris = mysqli_fetch_array($hasil)) {
                            $ids = $baris['id'];
                            $exids = $baris['exid'];

                            $sql3 = "SELECT status_pengerjaan, hasil_nilai, feedback_guru FROM pengerjaan_asesmen_formatif where id = $ids AND id_siswa = $id_siswa";
                            $hasil3 = mysqli_query($koneksi, $sql3);
                            $baris3 = mysqli_fetch_array($hasil3);

                            if (empty($baris3['status_pengerjaan']) OR $baris3['status_pengerjaan'] == 'P') {
                                $status_pengerjaan = "<a style='color:red'>Belum selesai</a>";
                                $hasil_nilai = "-";
                                $kategori = "-";
                                $feedback_guru = "-";
                            }
                            else{
                                $status_pengerjaan = "Sudah dikerjakan";
                                $hasil_nilai = $baris3['hasil_nilai'];
                                $feedback_guru = $baris3['feedback_guru'];

                                if(empty($hasil_nilai)) {
                                    $hasil_nilai = "";
                                }
                                else {
                                    $sql4 = "SELECT kategori
                                    FROM rubrik_asesmen
                                    WHERE $hasil_nilai BETWEEN rentang_from AND rentang_to AND exid = $exids";
                                    $hasil4 = mysqli_query($koneksi, $sql4);
                                    $baris4 = mysqli_fetch_array($hasil4);
                                    $kategori = $baris4['kategori'];
                                }
                            }
                            echo "<tr>";
                                echo "<td>".$no++."</td>";
                                echo "<td>".$baris['nama_materi']."</td>";
                                echo "<td>".$status_pengerjaan."</td>";
                                echo "<td>".$hasil_nilai."</td>";
                                echo "<td>".$feedback_guru."</td>";
                                // echo "<td>".$baris['extime']."</td>";
                                // echo "<td>".$baris['subt']."</td>";
                                echo "<td><center><a href='view_penilaian_pembelajaran.php?id=".$baris['id']."&kode_assign=".$baris['kode_assign']."&id_kelas=".$id_kelas."&id_mapel=".$id_mapel."&nama_materi=".$baris['nama_materi']."&kode_materi=".$baris['kode_materi']."' class='btn btn-primary btn-icon-split btn-sm'>
                                            <span class='icon text-white-50'>
                                                <i class='fas fa-edit'></i>
                                            </span>
                                            <span class='text'>Kerjakan</span>
                                             </a> | <a href='view_penilaian_pembelajaran.php?id=".$baris['id']."&kode_assign=".$baris['kode_assign']."&id_kelas=".$id_kelas."&id_mapel=".$id_mapel."&nama_materi=".$baris['nama_materi']."&kode_materi=".$baris['kode_materi']."' class='btn btn-primary btn-icon-split btn-sm'>
                                             <span class='icon text-white-50'>
                                                 <i class='fas fa-edit'></i>
                                             </span>
                                             <span class='text'>Edit</span>
                                              </a></center></td>";
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
                    <h5 class="modal-title" id="exampleModalLabel">Buat Akun Admin</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="buat_manajemen_akun_admin.php" method="post" style="padding:1% 3% 0 3%">
                    <p><b>Nama Lengkap</b></p>
                    <div class="form-group">
                        <input required name="fname" type="text" class="form-control form-control-user" id="exampleInputPassword" placeholder="Nama Lengkap">
                    </div>
                    <p><b>Username</b></p>
                    <div class="form-group">
                        <input required name="uname" type="text" class="form-control form-control-user" id="exampleInputPassword" placeholder="Username">
                    </div>
                    <p><b>Password</b></p>
                    <div class="form-group">
                        <input required name="pword" type="password" class="form-control form-control-user" id="exampleInputPassword" placeholder="Password">
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                        <button class="btn btn-primary" name="buat_akun" href="buat_manajemen_akun_admin.php">Buat</button>
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

</body>

</html>