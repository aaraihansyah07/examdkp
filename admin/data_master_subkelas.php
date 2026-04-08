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
        echo "<script>window.alert('Nama subkelas ini sudah ada')</script>";
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
    <title>E-Exam | Data Subkelas</title>

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
        #icon_dm_subkelas {color:white}
        #dm_subkelas {color:white; font-weight:bold}
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
                    <a href="#" style="color:white; margin-left:1.3%; font-size:90%">Data Subkelas</a>
                </nav>
                <div class="container-fluid">

<!-- Page Heading -->
<h1 class="h3 mb-2 text-gray-800">Data Subkelas</h1>
<a data-toggle="modal" class="btn btn-secondary btn-icon-split" data-target="#createModal">
            <span class="icon text-white-50">
                <i class="fas fa-plus"></i>
            </span>
            <span class="text">Tambah</span>
</a><br><br>

<?php
    $nama_kelas_filter = '';
    if (isset($_POST['refresh_filter'])) {
        $nama_kelas_filter = $_POST['nama_kelas_filter'];
    }
?>

<div class="dis-none panel-filter w-full p-t-10">
    <form method="POST" action="data_master_subkelas.php" style="width: 100%; margin: 0 auto; background-color: #f0f0f0; padding: 20px; border-radius: 8px;">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 7px;">
            <div style="flex: 1; margin-right: 10px; margin-bottom: 10px;">
                <label for="jenis-sewa" style="font-size: 16px; color: #333; display: block; margin-bottom: 5px;">Kelas</label>
                <select name="nama_kelas_filter" id="jenis-sewa" style="width: 65%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                    <option value=''>Semua</option>
                    <?php
                        $sql2 = "SELECT id, nama_kelas FROM d_kelas order by nama_kelas";
                        $hasil2 = $db->query($sql2);
                        while ($baris2 = $hasil2->fetch(PDO::FETCH_ASSOC)) {
                            $id_kelas = $baris2['id'];
                            $nama_kelas = $baris2['nama_kelas'];
                    ?>	
                        <option value=<?php echo $nama_kelas;?> <?= ($nama_kelas_filter == $nama_kelas) ? 'selected' : '' ?>><?php echo $nama_kelas;?></option>                    
                    <?php
                        }
                    ?>
                </select>
                <button name="refresh_filter" type="submit" style="padding: 7px; font-size: 16px; background-color: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer;">Refresh</button>
            </div>
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
                        <th style='text-align:center'>Kelas</th>
                        <th style='text-align:center'>Nama Subkelas</th>
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

                        $sql = "SELECT k.nama_kelas, sk.nama_subkelas, sk.id from d_subkelas sk
                        left join d_kelas k on k.id = sk.id_kelas
                        where ('$nama_kelas_filter' = '' or k.nama_kelas = '$nama_kelas_filter')
                        order by nama_subkelas asc";
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            echo "<tr>";
                                echo "<td>".$baris['nama_kelas']."</td>";
                                echo "<td>".$baris['nama_subkelas']."</td>";
                                echo "<td class='align-middle text-center'>
                                <div class='flex justify-center items-center space-x-2'>
                                    <form method='post' action='edit_data_master_subkelas.php' class='inline-block'>
                                        <input type='hidden' name='id_subkelas' value='" . $baris['id'] . "' />
                                        <input type='hidden' name='nama_subkelas' value='" . $baris['nama_subkelas'] . "' />
                                        <button name='btn_edit' class='flex items-center bg-blue-500 hover:bg-blue-600 text-white text-sm font-medium py-1 px-3 rounded shadow'>
                                            <i class='fas fa-edit mr-1'></i>
                                            Edit
                                        </button>
                                    </form>

                                    <form method='post' action='hapus_data_master_subkelas.php' class='inline-block' onsubmit='return confirm(\"Yakin ingin menghapus data ini?\");'>
                                        <input type='hidden' name='id_subkelas' value='" . $baris['id'] . "' />
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
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Subkelas</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="buat_data_master_subkelas.php" method="post" style="padding:1% 3% 0 3%" id="form_tambah">
                    <div style="flex: 1; margin-right: 10px; margin-bottom: 10px;">
                        <p><b>Kelas</b></p>    
                        <select required name="id_kelas" style="width: 100%; padding: 8px; font-size: 14px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <option value="">--Pilih Kelas--</option>
                        <?php
                            $sql2 = "SELECT id, kode_kelas, nama_kelas from d_kelas order by nama_kelas";
                            $hasil2 = $db->query($sql2);
                            while($baris2 = $hasil2->fetch(PDO::FETCH_ASSOC)) {
                        ?>
                            <option value='<?php echo $baris2['id'];?>'><?php echo $baris2['nama_kelas'];?></option>
                        <?php
                            }
                        ?>
                        </select>
                    </div>
                    <p><b>Nama Subkelas</b></p>
                    <div class="form-group">
                        <input required name="nama_subkelas" type="text" class="form-control" id="exampleInputPassword" placeholder="Cth : 11-MIPA-1">
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