<?php
    ob_start();
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
        header('location:../login.php');
    }
    include('config.php');
    if ($_SESSION['fname'] == null) {
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

    $uname = $_SESSION['uname'];
    $fname = $_SESSION['fname'];
    $id_subkelas_siswa = $_POST['id_subkelas'];
    $nama_bab = $_POST['nama_bab'];
    $kode_ujian = $_POST['kode_ujian'];
    $id_ujian_hdr = $_POST['id_ujian_hdr'];
    $tanggal_ujian = $_POST['tanggal_ujian'];
    $nama_ujian = $_POST['nama_ujian'];
    $nama_subkelas = $_POST['nama_subkelas'];
    $nis = $_POST['nis'];
    $nama_siswa = $_POST['nama_siswa'];
    $id_jawaban_siswa = $_POST['id_jawaban_siswa'];
    $nilai = $_POST['nilai'];
    $uuidguru = $_POST['uuidguru'];
    $nama_guru = $_POST['nama_guru'];

    if (isset($_GET['mp'])) {
        $mp = $_GET['mp'];
    }
    else {
        $mp = $_POST['mp'];
    }

    if (isset($_GET['kls'])) {
        $kls = $_GET['kls'];
    }
    else {
        $kls = $_POST['kls'];
    }

    if (isset($_GET['ju'])) {
        $ju = $_GET['ju'];
    }
    else {
        $ju = $_POST['ju'];
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
    <title>E-Exam | Detail Hasil Nilai Siswa</title>

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
        #icon_hasil_nilai_siswa {color:white}
        #hasil_nilai_siswa {color:white; font-weight:bold}
    </style>
      <!-- MathJax untuk render LaTeX -->
    <script>
        window.MathJax = {
        tex: { inlineMath: [['$', '$'], ['\\(', '\\)']] },
        svg: { fontCache: 'global' }
        };
    </script>
    <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
    <script>
    function isLatex(str) {
    // cek apakah ada backslash \ yang menandakan LaTeX
    return /\\[a-zA-Z]+/.test(str);
    }
    </script>

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
                    <a href="#" style="color:white; margin-left:0.8%; font-size:90%">Detail Hasil Nilai Siswa</a>
                </nav>
                <div class="container-fluid">


<!-- Page Heading -->
<h1 class="h3 text-gray-800">Detail Hasil Nilai Siswa</h1><br>
    <div class="d-flex flex-wrap align-items-center gap-2 mb-3" style="margin-top:-2%">
        <!-- Tombol Tambah -->
         <form method="post" action="hasil_nilai_siswa_detail.php">
            <input type='hidden' name='nama_bab' value='<?php echo $nama_bab;?>'/>
            <input type='hidden' name='kode_ujian' value='<?php echo $kode_ujian;?>'/>
            <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/>
            <input type='hidden' name='tanggal_ujian' value='<?php echo $tanggal_ujian;?>'/>
            <input type='hidden' name='nama_ujian' value='<?php echo $nama_ujian;?>'/>
            <input type='hidden' name='nama_subkelas' value='<?php echo $nama_subkelas;?>'/>
            <input type='hidden' name='id_subkelas' value='<?php echo $id_subkelas_siswa;?>'/>
            <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
            <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
            <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
            <input type='hidden' name='uuidguru' value='<?php echo $uuidguru;?>'/>
            <button class="btn btn-secondary btn-icon-split">
                <span class="text">Kembali</span>
            </button>
        </form>

        <!-- Bungkus tombol kanan dengan ms-auto -->
        <div class="d-flex gap-2 ms-auto">
            <!-- Tombol Generate -->
             <!-- <form method="post" action="hasil_nilai_siswa_pdf.php" target="_blank">
                <input type="hidden" name="id_ujian_hdr" value="<?php echo $id_ujian_hdr;?>"/>
                <input type="hidden" name="kode_ujian" value="<?php echo $kode_ujian;?>"/>
                <input type="hidden" name="nama_bab" value="<?php echo $nama_bab;?>"/>
                <input type="hidden" name="tanggal_ujian" value="<?php echo $tanggal_ujian;?>"/>
                <input type="hidden" name="nama_ujian" value="<?php echo $nama_ujian;?>"/>
                <input type="hidden" name="nama_subkelas" value="<?php echo $nama_subkelas;?>"/>
                <input type="hidden" name="id_subkelas_siswa" value="<?php echo $id_subkelas_siswa;?>"/>
                <input type="hidden" name="jml_siswa_ikut_ujian" value="<?php echo $jml_siswa_ikut_ujian;?>"/>
                <input type="hidden" name="jml_siswa_tidak_ikut_ujian" value="<?php echo $jml_siswa_tidak_ikut_ujian;?>"/>
                <button class="btn btn-secondary btn-icon-split" name="download_hasil_ujian" type="submit">
                    <span class="icon text-white-50">
                        <i class="fas fa-print"></i>
                    </span>
                    <span class="text">Download PDF</span>
                </button>
            </form>

            <form method="post" action="hasil_nilai_siswa_excel.php" target="_blank">
                <input type="hidden" name="id_ujian_hdr" value="<?php echo $id_ujian_hdr;?>"/>
                <input type="hidden" name="nama_ujian" value="<?php echo $nama_ujian;?>"/>
                <input type="hidden" name="nama_subkelas" value="<?php echo $nama_subkelas;?>"/>
                <button class="btn btn-secondary btn-icon-split" name="download_hasil_ujian" type="submit">
                    <span class="icon text-white-50">
                        <i class="fas fa-print"></i>
                    </span>
                    <span class="text">Download Excel</span>
                </button>
            </form> -->
                
        </div>
    </div>
    <div class="dis-none panel-filter w-full p-t-10">
        <div style="padding: 12px; border-radius: 8px; display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 7px; background-color: #f0f0f0">
            <div class="flex flex-wrap justify-between gap-4">
                <!-- Kolom Kiri -->
                <div class="flex flex-col gap-1">
                    <p><b>Nama Ujian</b> &nbsp&nbsp&nbsp&nbsp: <?php echo $nama_ujian; ?></p>
                    <p><b>Nama Bab</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $nama_bab; ?></p>
                    <p><b>Kelas</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $nama_subkelas; ?></p>
                    <p><b>Tanggal Ujian</b> : <?php echo $tanggal_ujian; ?></p>
                </div>

                <!-- Kolom Kanan -->
                <div class="flex flex-col gap-1 text-left">
                    <p><b>Nama Siswa</b> &nbsp&nbsp: <?php echo $nama_siswa; ?></p>
                    <p><b>Guru Mapel &nbsp&nbsp</b> : <?php echo $nama_guru; ?></p>
                    <p><b>Nilai &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</b> : <?php echo $nilai; ?></p>
                </div>
            </div>
        </div>
    </div>

<?php
    $kode_guru = $_SESSION['uname'];
    //$kode_guru = $_SESSION['uname'];
    $nama_kelas_filter = '';
    $kode_mata_pelajaran_filter = '';
    $jenis_ujian_filter = '';
    if (isset($_GET['kls'])) {
        $nama_kelas_filter = $_GET['kls'];
    }
    if (isset($_GET['mp'])) {
        $kode_mata_pelajaran_filter = $_GET['mp'];
    }
    if (isset($_GET['ju'])) {
        $jenis_ujian_filter = $_GET['ju'];
    }

    if (isset($_POST['refresh_filter'])) {
        $nama_kelas_filter = $_POST['nama_kelas_filter'];
        $kode_mata_pelajaran_filter = $_POST['kode_mata_pelajaran_filter'];
        $jenis_ujian_filter = $_POST['jenis_ujian_filter'];
    }
?>


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
                        <th style='text-align:center'>No</th>
                        <th style='text-align:center'>Soal</th>
                        <th style='text-align:center'>Option A</th>
                        <th style='text-align:center'>Option B</th>
                        <th style='text-align:center'>Option C</th>
                        <th style='text-align:center'>Option D</th>
                        <th style='text-align:center'>Option E</th>
                        <th style='text-align:center'>Kunci Jawaban</th>
                        <th style='text-align:center'>Jawaban Siswa</th>
                        <th style='text-align:center'>Nilai Per Soal</th>
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

                        $sql = "SELECT 
                        no_soal,
                        (select isi_soal from f_soal_dtl sd where sd.id_ujian_hdr = $id_ujian_hdr and sd.no_soal = jd.no_soal) soal,
                        (select option_a from f_soal_dtl sd where sd.id_ujian_hdr = $id_ujian_hdr and sd.no_soal = jd.no_soal) option_a,
                        (select option_b from f_soal_dtl sd where sd.id_ujian_hdr = $id_ujian_hdr and sd.no_soal = jd.no_soal) option_b,
                        (select option_c from f_soal_dtl sd where sd.id_ujian_hdr = $id_ujian_hdr and sd.no_soal = jd.no_soal) option_c,
                        (select option_d from f_soal_dtl sd where sd.id_ujian_hdr = $id_ujian_hdr and sd.no_soal = jd.no_soal) option_d,
                        (select option_e from f_soal_dtl sd where sd.id_ujian_hdr = $id_ujian_hdr and sd.no_soal = jd.no_soal) option_e,
                        kunci_jawaban,
                        jawaban_siswa,
                        --nilai nilai_per_soal
                        round(nilai::numeric, 1) nilai_per_soal
                        from f_jawaban_siswa_dtl jd where id_jawaban_siswa = $id_jawaban_siswa
                        order by no_soal";                       
                        $hasil = $db->query($sql);

                        function formatLatexInP($str) {
                            // Cek ada <p>...</p>
                            if (preg_match('/<p>(.*?)<\/p>/is', $str, $matches)) {
                                $content = $matches[1];
                                // Jika ada LaTeX di dalam content, bungkus dengan \( ... \)
                                if (preg_match('/\\\\[a-zA-Z]+/', $content)) {
                                    $content = "\\(" . $content . "\\)";
                                }
                                // Kembalikan dengan <p>...</p> lagi
                                return "<p>$content</p>";
                            } else {
                                // Tidak ada <p>, cek langsung latex
                                if (preg_match('/\\\\[a-zA-Z]+/', $str)) {
                                    return "\\(" . $str . "\\)";
                                }
                                return $str;
                            }
                        }


                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            $soal = html_entity_decode($baris['soal'], ENT_QUOTES, 'UTF-8');
                            $option_a = html_entity_decode($baris['option_a'], ENT_QUOTES, 'UTF-8');
                            $option_b = html_entity_decode($baris['option_b'], ENT_QUOTES, 'UTF-8');
                            $option_c = html_entity_decode($baris['option_c'], ENT_QUOTES, 'UTF-8');
                            $option_d = html_entity_decode($baris['option_d'], ENT_QUOTES, 'UTF-8');
                            $option_e = html_entity_decode($baris['option_e'], ENT_QUOTES, 'UTF-8');
                            echo "<tr>";
                                echo "<td>".$baris['no_soal']."</td>";
                                echo "<td>" . formatLatexInP($soal) . "</td>";
                                echo "<td>" . formatLatexInP($option_a) . "</td>";
                                echo "<td>" . formatLatexInP($option_b) . "</td>";
                                echo "<td>" . formatLatexInP($option_c) . "</td>";
                                echo "<td>" . formatLatexInP($option_d) . "</td>";
                                echo "<td>" . formatLatexInP($option_e) . "</td>";
                                echo "<td>".$baris['kunci_jawaban']."</td>";
                                echo "<td>".$baris['jawaban_siswa']."</td>";
                                echo "<td>".$baris['nilai_per_soal']."</td>";
                            echo "</tr>";

                        }
                    ?>
                </tbody>
            </table>
        </div>
        <script>
        document.addEventListener("DOMContentLoaded", () => {
            MathJax.typesetPromise();
        });
        </script>
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
                    <h5 class="modal-title" id="exampleModalLabel">Tambah Ujian</h5>
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
    
    <script>
        function togglePassword() {
            const input = document.getElementById("inputPassword");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
</body>

</html>