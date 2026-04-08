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
                <a class="nav-link collapsed" href="#">
                    <i class="fas fa-fw fa-table"></i>
                    <span>Materi</span>
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
                        <a class="collapse-item" href="asesmen_formatif.php">Assesment Formatif</a>
                    </div>
                </div>
            </li> -->
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
                    <a href="asesmen_diagnostik.php" style="color:white; margin-left:1.3%; font-size:90%">Asesmen Diagnostik ></a>
                    <a href="#" style="color:white; margin-left:0.5%; font-size:90%">Buat Asesmen Diagnostik</a>
                </nav>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <!-- Page Heading -->
                    <h1 class="h3 mb-2 text-gray-800 ml-1">Buat Soal Asesmen Diagnostik</h1>
                            <form method="post" name="buatsoal_asesmen_diagnostik.php">
                            <a href="asesmen_diagnostik.php" class="btn btn-secondary btn-icon-split">
                                        <span class="icon text-white-50">
                                            <i class="fas fa-arrow-left"></i>
                                        </span>
                                        <span class="text">Kembali</span>
                            </a>
                                <button id="assign" name="assign" class="btn btn-primary btn-user">Assign</button>
                                <button style="background:red; border:1px solid red" id="batal_assign" name="batal_assign" class="btn btn-primary btn-user">Batal Assign</button><br>
                            </form>
                    <!-- DataTales Example -->
                                <?php
                                    include('config.php');
                                    $exid = $_GET['exid'];
                                    $sql = "SELECT NO_SOAL FROM TMP_DETAIL_SOAL_DIAGNOSTIK WHERE EXID = $exid AND NO_SOAL = 1";
                                    $hasil = mysqli_query($koneksi, $sql);
                                    $baris = mysqli_fetch_array($hasil);

                                    if (empty($baris['NO_SOAL'])) {
                                        $sql2 = "INSERT INTO TMP_DETAIL_SOAL_DIAGNOSTIK(EXID, NO_SOAL) VALUES($exid, 1)";
                                        $hasil2 = mysqli_query($koneksi, $sql2);
                                    }
                                    
                                    $sql3 = "SELECT FILENAME, NO_SOAL, ISI_SOAL, OPTION_A, OPTION_B, OPTION_C, OPTION_D, OPTION_E, KUNCI_JAWABAN FROM TMP_DETAIL_SOAL_DIAGNOSTIK WHERE EXID = $exid";
                                    $hasil3 = mysqli_query($koneksi, $sql3);
                                    
                                    $sql4 = "SELECT MAX(NO_SOAL) MAX_NO_SOAL FROM TMP_DETAIL_SOAL_DIAGNOSTIK WHERE EXID = $exid";
                                    $hasil4 = mysqli_query($koneksi, $sql4);
                                    $baris4 = mysqli_fetch_array($hasil4);

                                    $bobot = round(100/$baris4['MAX_NO_SOAL'], 2);
                                ?>


                                <?php
                                    while ($baris3 = mysqli_fetch_array($hasil3)) {
                                    $nomor_soal = $baris3['NO_SOAL'];
                                    $nomor_soal_2 = $nomor_soal. "a";
                                    $gambar = $baris3['FILENAME'];
                                ?>

                            <div class="card shadow mb-4">
                            <form enctype="multipart/form-data" action="buatsoal_asesmen_diagnostik.php?exid=<?php echo $exid?>" method="post">
                                <!-- Card Header - Dropdown -->
                                <div
                                    class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Soal <?php echo $baris3['NO_SOAL'];?></h6>
                                    <h6 class="m-0 font-weight-bold text-primary"><?php echo 'Bobot :'. $bobot;?></h6>
                                </div>
                                <!-- Card Body --> 
                                <div class="card-body">
                                        <img src="../gambar/<?php echo $baris3['FILENAME']; ?>" width="25%"/>
                                        <div class="form-group" style="border:none">
                                            <input style="border:none" class="form-control" type="file" name="uploadfile" value="<?php echo $gambar;?>" />
                                            <input type="hidden" name="tampung_gambar" value="<?php echo $gambar?>"/>
                                        </div>
                                        <div class="form-group">
                                            <textarea name="isi_soal" class="form-control form-control-user"
                                                id="exampleInputEmail" aria-describedby="emailHelp"
                                                placeholder="Isi Soal"><?php echo $baris3['ISI_SOAL']?></textarea>
                                        </div>
                                        <b>Option A</b>
                                        <textarea style="height:35px" name="option_a" class="form-control form-control-user"
                                                id="exampleInputEmail" aria-describedby="emailHelp"><?php echo $baris3['OPTION_A']?></textarea><br>                                        
                                        <b>Option B</b>
                                        <textarea style="height:35px" name="option_b" class="form-control form-control-user"
                                                id="exampleInputEmail" aria-describedby="emailHelp"><?php echo $baris3['OPTION_B']?></textarea><br>     
                                        <p><b>Option C</b></p>
                                        <textarea style="height:35px" name="option_c" class="form-control form-control-user"
                                                id="exampleInputEmail" aria-describedby="emailHelp"><?php echo $baris3['OPTION_C']?></textarea><br>    
                                        <b>Option D</b>
                                        <textarea style="height:35px" name="option_d" class="form-control form-control-user"
                                                id="exampleInputEmail" aria-describedby="emailHelp"><?php echo $baris3['OPTION_D']?></textarea><br>    
                                        <b>Option E</b>
                                        <textarea style="height:35px" name="option_e" class="form-control form-control-user"
                                                id="exampleInputEmail" aria-describedby="emailHelp"><?php echo $baris3['OPTION_E']?></textarea><br>   
                                        <select style="border-radius:10px" name="kunci_jawaban">
                                            <option value="">--Pilih Jawaban benar--</option>
                                            <option selected="<?php echo $baris3['KUNCI_JAWABAN'];?>"><?php echo $baris3['KUNCI_JAWABAN'];?></option>
                                            <option value="A">A</option>
                                            <option value="B">B</option>
                                            <option value="C">C</option>
                                            <option value="D">D</option>
                                            <option value="E">E</option>
                                        </select><br><br>
                                        <!-- <span style="color:blue"> Jawaban Benar : <?php echo $baris3['KUNCI_JAWABAN'];?></span><br><br> -->
                                        <button id="save" name="<?php echo $nomor_soal?>" class="btn btn-primary btn-user">Save</button>
                                        <button id="hapus" name="<?php echo $nomor_soal_2?>" class="btn btn-primary btn-user">Hapus</button>
                                        
                                        <?php  
                                                $sql9 = "SELECT STATUS_ASSIGN FROM EXM_LIST WHERE EXID = $exid";
                                                $hasil9 = mysqli_query($koneksi, $sql9);
                                                $baris9 = mysqli_fetch_array($hasil9);

                                                if ($baris9['STATUS_ASSIGN'] == 'Y') {
                                                    echo "<style>#assign, #save, #hapus, #tambah_soal {display:none}</style>";
                                                }
                                                if ($baris9['STATUS_ASSIGN'] == 'N') {
                                                    echo "<style>#batal_assign {display:none}</style>";
                                                }

                                                if (isset($_POST['assign'])) {
                                                        $sql8 = "UPDATE EXM_LIST SET STATUS_ASSIGN = 'Y' WHERE EXID = $exid";
                                                        $hasil8 = mysqli_query($koneksi, $sql8);
                                                        header('Refresh:0');
                                                }
                                                elseif (isset($_POST['batal_assign'])) {
                                                        $sql10 = "UPDATE EXM_LIST SET STATUS_ASSIGN = 'N' WHERE EXID = $exid";
                                                        $hasil10 = mysqli_query($koneksi, $sql10);
                                                        header('Refresh:0');
                                                }

                                                if (isset($_POST[$nomor_soal])) {
                                                    $isi_soals = $_POST['isi_soal'];
                                                    $option_as = $_POST['option_a'];
                                                    $option_bs = $_POST['option_b'];
                                                    $option_cs = $_POST['option_c'];
                                                    $option_ds = $_POST['option_d'];
                                                    $option_es = $_POST['option_e'];
                                                    $gb = $_POST['tampung_gambar'];
                                                    $kunci_jawabans = $_POST['kunci_jawaban'];
                                                    $filename = $_FILES['uploadfile']['name'];
                                                    $tempname = $_FILES['uploadfile']['tmp_name'];
                                                    $folder = "../gambar/" . $filename;
                                        
                                                    if ($kunci_jawabans == "") {
                                                        echo "<a style='color:red'>Jawaban Benar harus diisi</a>";
                                                    }
                                                    else {
                                                        if ($gambar == "") {
                                                            $sql5 = "UPDATE TMP_DETAIL_SOAL_DIAGNOSTIK SET FILENAME= '$filename', ISI_SOAL = '$isi_soals', OPTION_A = '$option_as', OPTION_B = '$option_bs', OPTION_C = '$option_cs', OPTION_D = '$option_ds', OPTION_E = '$option_es', kunci_jawaban = '$kunci_jawabans'
                                                            WHERE EXID = $exid AND NO_SOAL = $nomor_soal";
                                                            $hasil5 = mysqli_query($koneksi, $sql5);
        
                                                            if (move_uploaded_file($tempname, $folder)) {
                                                                echo "<h3> Image uploaded successfully!</h3>";
                                                            } else {
                                                                echo "<h3> Failed to upload image!</h3>";
                                                            }
                                                            header('refresh:0');
                                                        }
                                                        if ($gambar !== "" AND $filename !== "") {
                                                            $sql5 = "UPDATE TMP_DETAIL_SOAL_DIAGNOSTIK SET FILENAME= '$filename', ISI_SOAL = '$isi_soals', OPTION_A = '$option_as', OPTION_B = '$option_bs', OPTION_C = '$option_cs', OPTION_D = '$option_ds', OPTION_E = '$option_es', kunci_jawaban = '$kunci_jawabans'
                                                            WHERE EXID = $exid AND NO_SOAL = $nomor_soal";
                                                            $hasil5 = mysqli_query($koneksi, $sql5);
        
                                                            if (move_uploaded_file($tempname, $folder)) {
                                                                echo "<h3> Image uploaded successfully!</h3>";
                                                            } else {
                                                                echo "<h3> Failed to upload image!</h3>";
                                                            }
                                                            header('refresh:0');
                                                        }
                                                        if ($gb !== "") {
                                                            $sql5 = "UPDATE TMP_DETAIL_SOAL_DIAGNOSTIK SET ISI_SOAL = '$isi_soals', OPTION_A = '$option_as', OPTION_B = '$option_bs', OPTION_C = '$option_cs', OPTION_D = '$option_ds', OPTION_E = '$option_es', kunci_jawaban = '$kunci_jawabans'
                                                            WHERE EXID = $exid AND NO_SOAL = $nomor_soal";
                                                            $hasil5 = mysqli_query($koneksi, $sql5);
        
                                                            if (move_uploaded_file($tempname, $folder)) {
                                                                echo "<h3> Image uploaded successfully!</h3>";
                                                            } else {
                                                                echo "<h3> Failed to upload image!</h3>";
                                                            }
                                                            header('refresh:0');
                                                        }
                                                    }                                         
                                                }
                                                if (isset($_POST[$nomor_soal_2])) {
                                                    $sql7 = "DELETE FROM TMP_DETAIL_SOAL_DIAGNOSTIK WHERE EXID = $exid AND NO_SOAL = $nomor_soal";
                                                    $hasil7 = mysqli_query($koneksi, $sql7);
                                                    header('refresh:0');                                  
                                                }
                                        ?>
                                 </div>
                            </div>
                            </form>
                            <?php
                                    }
                            ?>
                        <form action="buatsoal_asesmen_diagnostik.php?exid=<?php echo $exid?>" method="post">
                            <button id="tambah_soal" name="tambah" class="btn btn-primary btn-user">Tambah Soal [+]</button>
                        </form>
                        <?php
                               if (isset($_POST['tambah'])) {
                                $next_soal = $nomor_soal+1;
                                
                                $sql6 = "INSERT INTO TMP_DETAIL_SOAL_DIAGNOSTIK(EXID, NO_SOAL) VALUES($exid, $next_soal)";
                                $hasil6 = mysqli_query($koneksi, $sql6);

                                header('refresh:0');
                               }
                        ?>
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
                    <a class="btn btn-primary" href="logout.php">Logout</a>
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