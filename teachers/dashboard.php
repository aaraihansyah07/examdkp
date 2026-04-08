<?php
	session_start();
		if ($_SESSION['fname'] == null or $_SESSION['role'] <> '1') {
			header('location:../login.php');
		}
    $uname = $_SESSION['uname'];
?>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <script src="https://cdn.tailwindcss.com"></script>

    <title>E-Exam | Dashboard</title>

    <!-- Custom fonts for this template-->
    <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link
        href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
        rel="stylesheet">

    <!-- Custom styles for this template-->
    <link href="css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        #icon_dashboard_admin {color:white}
        #dashboard_admin {color:white; font-weight:bold}
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
                    <?php
                        include('config.php');
                        $sql = "SELECT COUNT(1) jml_total_daftar from f_soal_hdr where kode_guru = '$uname'";
                        $hasil = $db->query($sql);
                        $baris = $hasil->fetch(PDO::FETCH_ASSOC);

                        $sql2 = "SELECT COUNT(1) jml_posting from f_soal_hdr where kode_guru = '$uname' AND st_posting = 'Y'";
                        $hasil2 = $db->query($sql2);
                        $baris2 = $hasil2->fetch(PDO::FETCH_ASSOC);

                        $sql3 = "SELECT COUNT(1) jml_draft from f_soal_hdr where kode_guru = '$uname' AND st_posting is null";
                        $hasil3 = $db->query($sql3);
                        $baris3 = $hasil3->fetch(PDO::FETCH_ASSOC);
                    ?>

                    <!-- Page Heading -->
                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">Dashboard</h1>
                        
                        <!-- <a href="#" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                                class="fas fa-download fa-sm text-white-50"></i> Generate Report</a> -->

                        <!-- Content Row -->
                        <div class="row">
                            
                        </div>
                     </div>
                    <section class="bg-gray-100 py-4 px-4">
                        <div class="max-w-7xl mx-auto">
                            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                                <!-- Card 1 -->
                                <a href="daftar_ujian_saya.php" class="block relative rounded-2xl overflow-hidden shadow-lg group transition-transform duration-300 hover:scale-105">
                                    <div class="bg-cover bg-center h-60" style="background-image: url('./img/bg_guru.webp');"></div>
                                    <div class="absolute inset-0 bg-black bg-opacity-50 flex flex-col justify-center items-center text-white text-center p-4 group-hover:bg-opacity-70">
                                    <h3 class="text-4xl font-bold mb-2"><?php echo $baris['jml_total_daftar'];?> Total Ujian</h3>
                                    <!-- <p class="text-sm">Lihat panorama 360</p> -->
                                    </div>
                                </a>

                                <a href="daftar_ujian_saya.php" class="block relative rounded-2xl overflow-hidden shadow-lg group transition-transform duration-300 hover:scale-105">
                                    <div class="bg-cover bg-center h-60" style="background-image: url('./img/akun_guru_img.png');"></div>
                                    <div class="absolute inset-0 bg-black bg-opacity-50 flex flex-col justify-center items-center text-white text-center p-4 group-hover:bg-opacity-70">
                                    <h3 class="text-4xl font-bold mb-2"><?php echo $baris2['jml_posting'];?> Ujian Diposting</h3>
                                    <!-- <p class="text-sm">Lihat panorama 360</p> -->
                                    </div>
                                </a>

                                <a href="daftar_ujian_saya.php" class="block relative rounded-2xl overflow-hidden shadow-lg group transition-transform duration-300 hover:scale-105">
                                    <div class="bg-cover bg-center h-60" style="background-image: url('./img/mapel_img.png');"></div>
                                    <div class="absolute inset-0 bg-black bg-opacity-50 flex flex-col justify-center items-center text-white text-center p-4 group-hover:bg-opacity-70">
                                    <h3 class="text-4xl font-bold mb-2"><?php echo $baris3['jml_draft'];?> Draft Ujian</h3>
                                    <!-- <p class="text-sm">Lihat panorama 360</p> -->
                                    </div>
                                </a>
                            </div>
                        </div>
                    </section>
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
    <script src="vendor/chart.js/Chart.min.js"></script>

    <!-- Page level custom scripts -->
    <script src="js/demo/chart-area-demo.js"></script>
    <script src="js/demo/chart-pie-demo.js"></script>
    <script>
        function togglePassword() {
            const input = document.getElementById("inputPassword");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
</body>

</html>