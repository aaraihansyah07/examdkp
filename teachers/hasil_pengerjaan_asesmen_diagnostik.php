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
                <?php
                    $exid = $_GET['exid'];
                    $no_soal = $_GET['no_soal'];
                    $id_mapel = $_GET['id_mapel'];
                    $id_kelas = $_GET['id_kelas'];
                    $id_guru = $_SESSION['user_id'];
                    $id_siswa = $_GET['id_siswa'];
                ?>
                <nav style="margin-top:-2.5%; background:#3d4857; height:35px" class="navbar navbar-expand navbar-light topbar mb-2 static-top shadow">
                <a href="hasil_asesmen_diagnostik.php" style="color:white; margin-left:1.3%; font-size:90%">Hasil Asesmen Diagnostik ></a>    
                <a href="exid_hasil_asesmen_diagnostik?id_kelas=<?php echo $id_kelas;?>" style="color:white; margin-left:1%; font-size:90%">Daftar Hasil Asesmen Diagnostik ></a>
                <a href="kelas_hasil_asesmen_diagnostik?exid=<?php echo $exid;?>&id_kelas=<?php echo $id_kelas;?>&id_mapel=<?php echo $id_mapel;?>" style="color:white; margin-left:1%; font-size:90%">Detail ></a>
                <a href="#" style="color:white; margin-left:1%; font-size:90%">Hasil Pengerjaan</a>
                </nav>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <!-- Page Heading -->
                    <?php
                        include('config.php');
                        $no_soal_sebelumnya = $no_soal-1;
                        $no_soal_selanjutnya = $no_soal+1;

                        $fname = $_SESSION['fname'];
                        $sql = "SELECT h.exid, h.exname, d.NO_SOAL, d.ISI_SOAL, d.KUNCI_JAWABAN, d.FILENAME
                        from exm_list h
                        left join tmp_detail_soal_diagnostik d on d.exid = h.exid
                        where h.exid = $exid";
                        $hasil = mysqli_query($koneksi, $sql);
                        $no = 0;

                        $sqlb = "SELECT h.exid, h.exname, h.kode_assign, d.OPTION_A, d.OPTION_B, d.OPTION_C,
                        d.OPTION_D, d.OPTION_E, 
                        d.NO_SOAL, d.ISI_SOAL, d.KUNCI_JAWABAN, d.FILENAME
                        from exm_list h
                        left join tmp_detail_soal_diagnostik d on d.exid = h.exid
                        where h.exid = $exid and d.NO_SOAL = $no_soal";
                        $hasilb = mysqli_query($koneksi, $sqlb);
                        $barisb = mysqli_fetch_array($hasilb);
                        $filename = $barisb['FILENAME'];
                        $kode_assign = $barisb['kode_assign'];

                        $sqlf = "SELECT fname, (SELECT nama_kelas from master_kelas where master_kelas.id = $id_kelas) nama_kelas from users where id = $id_siswa";
                        $hasilf = mysqli_query($koneksi, $sqlf);
                        $barisf = mysqli_fetch_array($hasilf);
                        
                        $sqlg = "SELECT hasil_nilai, feedback_guru from pengerjaan_asesmen_diagnostik where id_siswa = $id_siswa AND exid = $exid";
                        $hasilg = mysqli_query($koneksi, $sqlg);
                        $barisg = mysqli_fetch_array($hasilg);
                        
                    ?>
                    <h1 class="h3 mb-2 text-gray-800 ml-1"><?php echo $barisb['exname']; ?></h1>
                    <p style="background:#dbe1eb">Nama  : <?php echo $barisf['fname'];?></p>
                    <p style="margin-top:-2%; background:#dbe1eb">Kelas : <?php echo $barisf['nama_kelas'];?></p>
                    <p style="margin-top:-2%; background:#dbe1eb">Nilai : <?php echo $barisg['hasil_nilai'];?></p>
                    <p style="background:#dbe1eb">Feedback : <?php echo $barisg['feedback_guru'];?></p>
                    <a href="kelas_hasil_asesmen_diagnostik.php?id_mapel=<?php echo $id_mapel?>&id_kelas=<?php echo $id_kelas;?>&exid=<?php echo $exid;?>" class="btn btn-secondary btn-icon-split">
                         <span class="icon text-white-50">
                         <i class="fas fa-arrow-left"></i>
                         </span>
                        <span class="text">Kembali</span>
                    </a>
                    <?php
                        if (empty($barisg['feedback_guru'])) {

                        
                    ?>
                    <a data-toggle="modal" data-target="#createModal" href="kelas_hasil_asesmen_diagnostik.php?id_mapel=<?php echo $id_mapel?>&id_kelas=<?php echo $id_kelas;?>&exid=<?php echo $exid;?>" class="btn btn-secondary btn-icon-split">
                         <span class="icon text-white-50">
                         <i class="fas fa-plus"></i>
                         </span>
                        <span class="text">Tambah Feedback</span>
                    </a>
                    <?php
                        }
                    ?>  
                    <form style="float:right" method="post" action="#">
                    <button id="btn_selesai" name="selesai" style="background:#f62814; border:none" class="btn btn-secondary btn-icon-split">
                        <span class="text">Selesai</span>
                    </button>
                    </form><br><br>
                    <!-- DataTales Example -->
                    <?php

                    ?>
                   <div class="row">
        

                    <div class="col-xl-3 col-lg-4">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div
                                    class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">Butir Soal</h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                    <?php
                                        while ($baris = mysqli_fetch_array($hasil)) {
                                            $no++;
                                            $no_soals = $baris['NO_SOAL'];

                                            $sqlc = "SELECT h.id, d.jawaban_siswa from pengerjaan_asesmen_diagnostik h
                                            left join pengerjaan_asesmen_diagnostik_dtl d on  d.id_pengerjaan = h.id where h.exid = $exid AND d.no_soal = $no_soals AND h.id_siswa = $id_siswa";
                                            $hasilc = mysqli_query($koneksi, $sqlc);
                                            $barisc = mysqli_fetch_array($hasilc);
                                                echo "<div style='display:inline-block; margin:1% 1% 3% 1%; width:20%'>";
                                                    echo "<a href='hasil_pengerjaan_asesmen_diagnostik.php?exid=".$exid."&no_soal=".$no_soals."&id_mapel=".$id_mapel."&id_kelas=".$id_kelas."&id_siswa=".$id_siswa."' style='border:none' class='btn btn-success btn-circle btn-md'>";
                                                        echo $no;
                                                    echo "</a><br>";
                                                echo "</div>";
                                            
                                        }
                                    ?>
                                </div>
                            </div>
                     </div>

                     <div class="col-xl-9 col-lg-10">
                            <div class="card shadow mb-4">
                                <!-- Card Header - Dropdown -->
                                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <?php
                                         $sql7= "SELECT h.status_pengerjaan, h.hasil_nilai, h.id_siswa, d.KUNCI_JAWABAN from pengerjaan_asesmen_diagnostik h
                                         left join tmp_detail_soal_diagnostik d on d.EXID = h.exid where h.exid = $exid AND h.id_siswa = $id_siswa AND d.no_soal = $no_soal";
                                         $hasil7 = mysqli_query($koneksi, $sql7);
                                         $baris7 = mysqli_fetch_array($hasil7);

  
                                         if (empty($baris7['status_pengerjaan']) or $baris7['status_pengerjaan'] == 'P') {
                                            $kunjaw = "";
                                         }
                                         else {
                                            $kunjaw = "Jawaban Benar : ". $baris7['KUNCI_JAWABAN'];
                                            echo "<style>#btn_simpan, #btn_selesai {display:none}</style>";
                                         }

                                    ?>
                                    <h6 class="m-0 font-weight-bold text-primary">Soal <?php echo $no_soal;?></h6>
                                    <h6 class="m-0 font-weight-bold text-primary"><?php echo $kunjaw;?></h6>
                                </div>
                                <!-- Card Body -->
                                <div class="card-body">
                                    <?php
                                        if ($filename == null) {
                                            echo "<p>".$barisb['ISI_SOAL']."</p>";
                                            echo "<b><a>Jawab :</a></b>";
                                            $sql5 = "SELECT d.jawaban_siswa from pengerjaan_asesmen_diagnostik h left join pengerjaan_asesmen_diagnostik_dtl d on d.id_pengerjaan = h.id where h.exid = $exid AND h.id_siswa = $id_siswa AND d.no_soal = $no_soal";
                                            $hasil5 = mysqli_query($koneksi, $sql5);
                                            $baris5 = mysqli_fetch_array($hasil5);
                                            
                                            if (empty($baris5['jawaban_siswa'])) {
                                                $jawaban_dipilih = "";
                                            }
                                            else {
                                                $jawaban_dipilih = $baris5['jawaban_siswa'];
                                            }
                                    ?>
                                        <form method='post' action="hasil_pengerjaan_asesmen_diagnostik.php?exid=<?php echo $exid;?>&no_soal=<?php echo $no_soal;?>&id_mapel=<?php echo $id_mapel;?>&id_kelas=<?php echo $id_kelas;?>" style='font-size:18px'>
                                        <input required type='radio' name='jawaban_siswa' value='A' <?php echo ($jawaban_dipilih == 'A') ?  "checked" : "" ;  ?>/> A. <?php echo $barisb['OPTION_A']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='B' <?php echo ($jawaban_dipilih == 'B') ?  "checked" : "" ;  ?>/> B. <?php echo $barisb['OPTION_B']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='C' <?php echo ($jawaban_dipilih == 'C') ?  "checked" : "" ;  ?>/> C. <?php echo $barisb['OPTION_C']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='D' <?php echo ($jawaban_dipilih == 'D') ?  "checked" : "" ;  ?>/> D. <?php echo $barisb['OPTION_D']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='E' <?php echo ($jawaban_dipilih == 'E') ?  "checked" : "" ;  ?>/> E. <?php echo $barisb['OPTION_E']; ?><br><br>
                                            <center><button id="btn_simpan" name="simpan" class="btn btn-secondary btn-icon-split">
                                                <span class="text">Simpan Jawaban</span>
                                            </button></center><br>
                                            
                                            <?php
                                                if ($no_soal != 1) {

                                                
                                            ?>
                                            <a href="hasil_pengerjaan_asesmen_diagnostik.php?exid=<?php echo $exid; ?>&no_soal=<?php echo $no_soal_sebelumnya;?>&id_mapel=<?php echo $id_mapel;?>&id_kelas=<?php echo $id_kelas;?>&id_siswa=<?php echo $id_siswa;?>" class="btn btn-secondary btn-icon-split">
                                                <span class="icon text-white-50">
                                                    <i class="fas fa-arrow-left"></i>
                                                </span>
                                                <span class="text">Soal Sebelumnya</span>
                                            </a>
                                            <?php
                                                }
                                                $sql6 = "SELECT MAX(d.NO_SOAL) no_soal FROM exm_list h
                                                left join tmp_detail_soal_diagnostik d on d.exid = h.exid
                                                where h.exid = $exid";
                                                $hasil6 = mysqli_query($koneksi, $sql6);
                                                $baris6 = mysqli_fetch_array($hasil6);

                                                if ($no_soal != $baris6['no_soal']) {
                                            ?>
                                            <a style="float:right" href="hasil_pengerjaan_asesmen_diagnostik.php?exid=<?php echo $exid; ?>&no_soal=<?php echo $no_soal_selanjutnya;?>&id_mapel=<?php echo $id_mapel;?>&id_kelas=<?php echo $id_kelas;?>&id_siswa=<?php echo $id_siswa;?>" class="btn btn-secondary btn-icon-split">
                                                <span class="text">Soal Selanjutnya</span>
                                                <span class="icon text-white-50">
                                                    <i class="fas fa-arrow-right"></i>
                                                </span>
                                            </a>
                                        </form>
                                    <?php
                                                }

                                        }
                                        else {
                                    ?>

                                    <?php
                                            $sql5 = "SELECT d.jawaban_siswa from pengerjaan_asesmen_diagnostik h left join pengerjaan_asesmen_diagnostik_dtl d on d.id_pengerjaan = h.id where h.id_siswa = $id_siswa AND d.no_soal = $no_soal AND h.exid = $exid";
                                            $hasil5 = mysqli_query($koneksi, $sql5);
                                            $baris5 = mysqli_fetch_array($hasil5);
                                            
                                            if (empty($baris5['jawaban_siswa'])) {
                                                $jawaban_dipilih = "";
                                            }
                                            else {
                                                $jawaban_dipilih = $baris5['jawaban_siswa'];
                                            }
                                            
                                            echo "<img style='width:100%; height:300px' src='../gambar/".$filename."'/>";
                                            echo "<p style='background:#d4dee2; color:black; padding:2%; border-radius:5px'>".$barisb['ISI_SOAL']."</p>";
                                            echo "<b><a>Jawab :</a></b>";
                                    ?>
                                        <form method='post' action="hasil_pengerjaan_asesmen_diagnostik.php?exid=<?php echo $exid;?>&no_soal=<?php echo $no_soal;?>&id_mapel=<?php echo $id_mapel;?>&id_kelas=<?php echo $id_kelas;?>" style='font-size:18px'>
                                            <input required type='radio' name='jawaban_siswa' value='A' <?php echo ($jawaban_dipilih == 'A') ?  "checked" : "" ;  ?>/> A. <?php echo $barisb['OPTION_A']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='B' <?php echo ($jawaban_dipilih == 'B') ?  "checked" : "" ;  ?>/> B. <?php echo $barisb['OPTION_B']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='C' <?php echo ($jawaban_dipilih == 'C') ?  "checked" : "" ;  ?>/> C. <?php echo $barisb['OPTION_C']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='D' <?php echo ($jawaban_dipilih == 'D') ?  "checked" : "" ;  ?>/> D. <?php echo $barisb['OPTION_D']; ?><br>
                                            <input required type='radio' name='jawaban_siswa' value='E' <?php echo ($jawaban_dipilih == 'E') ?  "checked" : "" ;  ?>/> E. <?php echo $barisb['OPTION_E']; ?><br><br>
                                            <center><button id="btn_simpan" name="simpan" class="btn btn-secondary btn-icon-split">
                                                <span class="text">Simpan Jawaban</span>
                                            </button></center><br>
                                            
                                            <?php
                                                if ($no_soal != 1) {

                                                
                                            ?>
                                            <a href="hasil_pengerjaan_asesmen_diagnostik.php?exid=<?php echo $exid; ?>&no_soal=<?php echo $no_soal_sebelumnya;?>&id_mapel=<?php echo $id_mapel;?>&id_kelas=<?php echo $id_kelas;?>&id_siswa=<?php echo $id_siswa;?>" class="btn btn-secondary btn-icon-split">
                                                <span class="icon text-white-50">
                                                    <i class="fas fa-arrow-left"></i>
                                                </span>
                                                <span class="text">Soal Sebelumnya</span>
                                            </a>
                                            <?php
                                                }
                                                $sql6 = "SELECT MAX(d.NO_SOAL) no_soal FROM exm_list h
                                                left join tmp_detail_soal_diagnostik d on d.exid = h.exid
                                                where h.exid = $exid";
                                                $hasil6 = mysqli_query($koneksi, $sql6);
                                                $baris6 = mysqli_fetch_array($hasil6);

                                                if ($no_soal != $baris6['no_soal']) {
                                            ?>
                                            <a style="float:right" href="hasil_pengerjaan_asesmen_diagnostik.php?exid=<?php echo $exid; ?>&no_soal=<?php echo $no_soal_selanjutnya;?>&id_mapel=<?php echo $id_mapel;?>&id_kelas=<?php echo $id_kelas;?>&id_siswa=<?php echo $id_siswa;?>" class="btn btn-secondary btn-icon-split">
                                                <span class="text">Soal Selanjutnya</span>
                                                <span class="icon text-white-50">
                                                    <i class="fas fa-arrow-right"></i>
                                                </span>
                                            </a>
                                        </form>
                                    <?php
                                                }
                                        }

                                        if (isset($_POST['simpan'])) {
                                            echo "<script>alert('Jawaban Berhasil Disimpan')</script>";
                                            $jawaban_siswa = $_POST['jawaban_siswa'];
                                            $sql2 = "SELECT KUNCI_JAWABAN FROM tmp_detail_soal_diagnostik where exid = $exid AND no_soal = $no_soal";
                                            $hasil2 = mysqli_query($koneksi, $sql2);
                                            $baris2 = mysqli_fetch_array($hasil2);
                                            $kunci_jawaban = $baris2['KUNCI_JAWABAN'];

                                            if ($jawaban_siswa == $kunci_jawaban) {
                                                $nilai = 1;
                                            }
                                            else {
                                                $nilai = 0;
                                            }

                                            //echo "$id_siswa, $exid, $kode_assign, $no_soal, $jawaban_siswa, $kunci_jawaban, $nilai";
                                            
                                            $sql3 = "SELECT id from pengerjaan_asesmen_diagnostik where id_siswa = $id_siswa AND exid = $exid AND kode_assign = '$kode_assign'";
                                            $hasil3 = mysqli_query($koneksi, $sql3);
                                            $baris3 = mysqli_fetch_array($hasil3);

                                            // $sql3a = "SELECT id_pengerjaan, nilai from pengerjaan_asesmen_diagnostik_dtl where exid = $exid 
                                            // AND kode_assign = '$kode_assign' AND no_soal = $no_soal";
                                            // $hasil3a = mysqli_query($koneksi, $sql3a);
                                            // $baris3a = mysqli_fetch_array($hasil3a);

                                            if ($baris3['id'] == null) {
                                                // $id_pengerjaan = $baris3['id'];
                                                // $sql3a = "SELECT id_pengerjaan, nilai from pengerjaan_asesmen_diagnostik_dtl where id_pengerjaan = $id_pengerjaan";
                                                // $hasil3a = mysqli_query($koneksi, $sql3a);
                                                // $baris3a = mysqli_fetch_array($hasil3a);

                                                if ($baris3a['nilai'] == null) {
                                                    $sql3b = "INSERT INTO pengerjaan_asesmen_diagnostik(exid, kode_assign, id_siswa, status_pengerjaan)
                                                    VALUES($exid, '$kode_assign', $id_siswa, 'P')";
                                                    $hasil3b = mysqli_query($koneksi, $sql3b);

                                                    $sql3c = "SELECT id from pengerjaan_asesmen_diagnostik where id_siswa = $id_siswa AND exid = $exid";
                                                    $hasil3c = mysqli_query($koneksi, $sql3c);
                                                    $baris3c = mysqli_fetch_array($hasil3c);
                                                    $id_pengerjaan = $baris3c['id'];

                                                    $sql3d = "INSERT INTO pengerjaan_asesmen_diagnostik_dtl(id_pengerjaan, exid, kode_assign, no_soal, jawaban_siswa, kunci_jawaban, nilai)
                                                    VALUES($id_pengerjaan, $exid, '$kode_assign', $no_soal, '$jawaban_siswa', '$kunci_jawaban', $nilai)";
                                                    $hasil3d = mysqli_query($koneksi, $sql3d);
    
                                                    header('refresh:0');
                                                }
                                            }
                                            else {
                                                $id_pengerjaan = $baris3['id'];
                                                $sql3a = "SELECT id_pengerjaan, nilai from pengerjaan_asesmen_diagnostik_dtl where id_pengerjaan = $id_pengerjaan AND no_soal = $no_soal";
                                                $hasil3a = mysqli_query($koneksi, $sql3a);
                                                $baris3a = mysqli_fetch_array($hasil3a);

                                                echo $baris3a['nilai'];
                                                
                                                if ($baris3a['nilai'] != null) {
                                                    //echo "TIDAK NULL";
                                                    echo "$id_pengerjaan, $exid, $kode_assign, $no_soal, $jawaban_siswa, $kunci_jawaban, $nilai, $id_pengerjaans";
                                                    $sql4 = "UPDATE pengerjaan_asesmen_diagnostik_dtl
                                                    set id_pengerjaan = $id_pengerjaan, exid = $exid, kode_assign = '$kode_assign', 
                                                    no_soal = $no_soal, jawaban_siswa = '$jawaban_siswa', kunci_jawaban = '$kunci_jawaban', nilai = $nilai
                                                    WHERE id_pengerjaan = $id_pengerjaan AND no_soal = $no_soal";
                                                    $hasil4 = mysqli_query($koneksi, $sql4);  
                                                    
                                                    header('refresh:0');
                                                }
                                                else {
                                                    //echo "NULL";
                                                    $sql3d = "INSERT INTO pengerjaan_asesmen_diagnostik_dtl(id_pengerjaan, exid, kode_assign, no_soal, jawaban_siswa, kunci_jawaban, nilai)
                                                    VALUES($id_pengerjaan, $exid, '$kode_assign', $no_soal, '$jawaban_siswa', '$kunci_jawaban', $nilai)";
                                                    $hasil3d = mysqli_query($koneksi, $sql3d);
    
                                                    header('refresh:0');
                                                }
                                            }
                                            

                                            // if ((empty($baris3['id']) AND empty($baris3a['nilai']))OR (empty($baris3['id']) AND !empty($baris3a['nilai']))) {
                                            //     $sql3b = "INSERT INTO pengerjaan_asesmen_diagnostik(exid, kode_assign, id_siswa, status_pengerjaan)
                                            //     VALUES($exid, '$kode_assign', $id_siswa, 'P')";
                                            //     $hasil3b = mysqli_query($koneksi, $sql3b);

                                            //     $sql3c = "SELECT id from pengerjaan_asesmen_diagnostik where id_siswa = $id_siswa AND exid = $exid";
                                            //     $hasil3c = mysqli_query($koneksi, $sql3c);
                                            //     $baris3c = mysqli_fetch_array($hasil3c);
                                            //     $id_pengerjaan = $baris3c['id'];

                                                
                                            //     $sql3d = "INSERT INTO pengerjaan_asesmen_diagnostik_dtl(id_pengerjaan, exid, kode_assign, no_soal, jawaban_siswa, kunci_jawaban, nilai)
                                            //     VALUES($id_pengerjaan, $exid, '$kode_assign', $no_soal, '$jawaban_siswa', '$kunci_jawaban', $nilai)";
                                            //     $hasil3d = mysqli_query($koneksi, $sql3d);

                                            //     header('refresh:0');
                                            // }
                                            // else if (!empty($baris3['id']) AND $baris3a['nilai'] != null) {
                                            //     $id_pengerjaans = $baris3['id'];
                                            //     $sql4 = "UPDATE pengerjaan_asesmen_diagnostik_dtl
                                            //     set id_pengerjaan = $id_pengerjaans, exid = $exid, kode_assign = '$kode_assign', 
                                            //     no_soal = $no_soal, jawaban_siswa = '$jawaban_siswa', kunci_jawaban = '$kunci_jawaban', nilai = $nilai
                                            //     WHERE id_pengerjaan = $id_pengerjaans AND no_soal = $no_soal";
                                            //     $hasil4 = mysqli_query($koneksi, $sql4);

                                            //     header('refresh:0');
                                            // }
                                            // else if (!empty($baris3['id']) AND empty($baris3a['nilai'])) {
                                            //     $id_pengerjaans = $baris3['id'];
                                            //     $sql3d = "INSERT INTO pengerjaan_asesmen_diagnostik_dtl(id_pengerjaan, exid, kode_assign, no_soal, jawaban_siswa, kunci_jawaban, nilai)
                                            //     VALUES($id_pengerjaans, $exid, '$kode_assign', $no_soal, '$jawaban_siswa', '$kunci_jawaban', $nilai)";
                                            //     $hasil3d = mysqli_query($koneksi, $sql3d);

                                            //     header('refresh:0');
                                            // }
                                        }

                                        if (isset($_POST['selesai'])) {
                                            $sql10 = "SELECT id from pengerjaan_asesmen_diagnostik where id_siswa = $id_siswa AND exid = $exid";
                                            $hasil10 = mysqli_query($koneksi, $sql10);
                                            $baris10 = mysqli_fetch_array($hasil10);
                                            $id_pengerjaan2 = $baris10['id'];

                                            $sql8 = "SELECT FORMAT(SUM(nilai)/(SELECT count(no_soal) from tmp_detail_soal_diagnostik where exid = $exid)*100, 2) hasil_nilai
                                            FROM pengerjaan_asesmen_diagnostik_dtl where exid = $exid AND id_pengerjaan = $id_pengerjaan2";
                                            $hasil8 = mysqli_query($koneksi, $sql8);
                                            $baris8 = mysqli_fetch_array($hasil8);
                                            $hasil_nilai = $baris8['hasil_nilai'];

                                            //echo "$hasil_nilai, $exid, $id_siswa";
                
                                            $sql8b = "UPDATE pengerjaan_asesmen_diagnostik set hasil_nilai = $hasil_nilai, status_pengerjaan = 'Y'
                                            where exid = $exid AND id_siswa = $id_siswa";
                                            $hasil8b = mysqli_query($koneksi, $sql8b);
                                            
                                            $loc = "detail_penilaian_pra_pembelajaran.php?id_mapel=".$id_mapel."&id_kelas=".$id_kelas."";
                                            header('location:'. $loc);
                                            
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
    
    <!-- Create Modal-->
    <div class="modal fade" id="createModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Feedback</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="buat_feedback.php" method="post" style="padding:1% 3% 0 3%">
                    <p><b>Tulis feedback</b></p>
                    <div class="form-group">
                        <input type="hidden" name="id_siswa" value="<?php echo $id_siswa;?>"/>
                        <input type="hidden" name="exid" value="<?php echo $exid;?>"/>
                        <input type="hidden" name="id_mapel" value="<?php echo $id_mapel;?>"/>
                        <input type="hidden" name="id_kelas" value="<?php echo $id_kelas;?>"/>
                        <input required name="isi_feedback" type="text" class="form-control form-control-user" id="exampleInputPassword" placeholder="Nama Kelas">
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                        <button class="btn btn-primary" name="buat_feedback" href="buat_feedback.php">Tambah</button>
                    </div>
                </form>
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
                        $sql3 = "SELECT COUNT(kelas) jml_siswa from users where kelas = (SELECT kelas FROM users where fname = '$fname')";
                        $hasil3 = mysqli_query($koneksi, $sql3);
                        $baris3 = mysqli_fetch_array($hasil3);

                        $sql4 = "SELECT fname from users where kelas = (SELECT kelas FROM users where fname = '$fname') order by fname asc";
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