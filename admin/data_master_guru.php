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
    <title>E-Exam | Data Guru</title>

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
        #icon_dm_guru {color:white}
        #dm_guru {color:white; font-weight:bold}
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
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">Data Guru</a>
                </nav>
                <div class="container-fluid">

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800">Data Guru</h1>
<a data-toggle="modal" class="btn btn-secondary btn-icon-split" data-target="#createModal">
            <span class="icon text-white-50">
                <i class="fas fa-plus"></i>
            </span>
            <span class="text">Tambah</span>
</a><br><br>

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
                        <th style='text-align:center'>NIP</th>
                        <th style='text-align:center'>Kode Guru</th>
                        <th style='text-align:center'>Nama Guru</th>
                        <th style='text-align:center'>Gender</th>
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

                        $sql = "SELECT kode_guru, nip, nama_guru, uuidguru, tanggal_lahir, mapel.nama_mata_pelajaran, g.kode_mata_pelajaran,
                        case when (gender = 'L') then 'Laki-laki' when (gender = 'P') then 'Perempuan' else '' end gender 
                        from d_guru g
                        left join d_mata_pelajaran mapel on mapel.kode_mata_pelajaran = g.kode_mata_pelajaran
                        order by nama_guru asc";
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            echo "<tr>";
                                echo "<td>".$baris['nip']."</td>";
                                echo "<td>".$baris['kode_guru']."</td>";
                                echo "<td>".$baris['nama_guru']."</td>";
                                 echo "<td>".$baris['gender']."</td>";
                                echo "<td class='align-middle text-center'>
                                <div class='flex justify-center items-center space-x-2'>
                                    <form method='post' action='edit_data_master_guru.php' class='inline-block'>
                                        <input type='hidden' name='uuidguru' value='" . $baris['uuidguru'] . "' />
                                        <button name='btn_edit' class='flex items-center bg-blue-500 hover:bg-blue-600 text-white text-sm font-medium py-1 px-3 rounded shadow'>
                                            <i class='fas fa-edit mr-1'></i>
                                            Edit
                                        </button>
                                    </form>

                                    <form method='post' action='hapus_data_master_guru.php' class='inline-block' onsubmit='return confirm(\"Yakin ingin menghapus data ini?\");'>
                                        <input type='hidden' name='uuidguru' value='" . $baris['uuidguru'] . "' />
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
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Guru</h5>
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
</body>

</html>