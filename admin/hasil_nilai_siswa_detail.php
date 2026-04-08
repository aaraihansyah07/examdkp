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
    $id_subkelas_siswa = $_POST['id_subkelas'];
    $nama_bab = $_POST['nama_bab'];
    $kode_ujian = $_POST['kode_ujian'];
    $id_ujian_hdr = $_POST['id_ujian_hdr'];
    $tanggal_ujian = $_POST['tanggal_ujian'];
    $nama_ujian = $_POST['nama_ujian'];
    $nama_subkelas = $_POST['nama_subkelas'];
    $uuidguru = $_POST['uuidguru'];

    $sqlx2 = "select jenis_ujian from d_ujian where kode_ujian = '$kode_ujian'";                       
    $hasilx2 = $db->query($sqlx2);
    $barisx2 = $hasilx2->fetch(PDO::FETCH_ASSOC);
    $jenis_ujian = $barisx2['jenis_ujian'];

    if ($jenis_ujian == 'OSIS') {
        $nama_ujian = 'Pemilihan Ketua & Wakil Ketua OSIS';
        $capt_nama_ujian = 'Nama Event';
        $capt_ikut = 'Siswa Partisipasi';
        $capt_tidak_ikut = 'Siswa Belum Partisipasi';
        $capt_tgl_ujian = 'Tanggal Event';
    }
    else {
        $capt_nama_ujian = 'Nama Ujian';
        $capt_ikut = 'Siswa Ikut Ujian';
        $capt_tidak_ikut = 'Siswa Belum Ujian&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp';
        $capt_tgl_ujian = 'Tanggal Ujian';
    }

    $sqlx = "
    select jml_siswa_ikut_ujian, total_siswa - jml_siswa_ikut_ujian jml_siswa_tidak_ikut_ujian
	from (
        select
        (SELECT count(1) from f_jawaban_siswa_hdr where id_ujian_hdr = $id_ujian_hdr) jml_siswa_ikut_ujian,
        (SELECT count(1) from d_siswa where id_subkelas = $id_subkelas_siswa) total_siswa
	) s";                       
    $hasilx = $db->query($sqlx);
    $barisx = $hasilx->fetch(PDO::FETCH_ASSOC);

    $sqlv = "select nama_guru from d_guru where uuidguru = '$uuidguru'";                       
    $hasilv = $db->query($sqlv);
    $barisv = $hasilv->fetch(PDO::FETCH_ASSOC);

    $jml_siswa_ikut_ujian = $barisx['jml_siswa_ikut_ujian'];
    $jml_siswa_tidak_ikut_ujian = $barisx['jml_siswa_tidak_ikut_ujian'];

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
        <a class="btn btn-secondary btn-icon-split" href="hasil_nilai_siswa.php?mp=<?php echo $mp;?>&kls=<?php echo $kls;?>&ju=<?php echo $ju;?>">
            <span class="text">Kembali</span>
        </a>

        <!-- Bungkus tombol kanan dengan ms-auto -->
        <div class="d-flex gap-2 ms-auto">
            <!-- Tombol Generate -->
             <?php
                if ($jenis_ujian !== 'OSIS') {
             ?>
             <form method="post" action="hasil_nilai_siswa_pdf.php" target="_blank">
                <input type="hidden" name="id_ujian_hdr" value="<?php echo $id_ujian_hdr;?>"/>
                <input type="hidden" name="kode_ujian" value="<?php echo $kode_ujian;?>"/>
                <input type="hidden" name="nama_bab" value="<?php echo $nama_bab;?>"/>
                <input type="hidden" name="tanggal_ujian" value="<?php echo $tanggal_ujian;?>"/>
                <input type="hidden" name="nama_ujian" value="<?php echo $nama_ujian;?>"/>
                <input type="hidden" name="nama_subkelas" value="<?php echo $nama_subkelas;?>"/>
                <input type="hidden" name="id_subkelas_siswa" value="<?php echo $id_subkelas_siswa;?>"/>
                <input type="hidden" name="jml_siswa_ikut_ujian" value="<?php echo $jml_siswa_ikut_ujian;?>"/>
                <input type="hidden" name="jml_siswa_tidak_ikut_ujian" value="<?php echo $jml_siswa_tidak_ikut_ujian;?>"/>
                <input type="hidden" name="nama_guru" value="<?php echo $barisv['nama_guru'];?>"/>
                <button class="btn btn-secondary btn-icon-split" name="download_hasil_ujian" type="submit">
                    <span class="icon text-white-50">
                        <i class="fas fa-print"></i>
                    </span>
                    <span class="text">Download PDF</span>
                </button>
            </form>
            <?php
                }
            ?>

            <?php 
                if ($jenis_ujian !== 'OSIS') {
            ?>
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
            </form>
            <?php
                }
                else {
            ?>
            <form method="post" action="hasil_nilai_siswa_excel_osis.php" target="_blank">
                <input type="hidden" name="id_ujian_hdr" value="<?php echo $id_ujian_hdr;?>"/>
                <input type="hidden" name="nama_ujian" value="<?php echo $nama_ujian;?>"/>
                <input type="hidden" name="nama_subkelas" value="<?php echo $nama_subkelas;?>"/>
                <button class="btn btn-secondary btn-icon-split" name="download_hasil_ujian" type="submit">
                    <span class="icon text-white-50">
                        <i class="fas fa-print"></i>
                    </span>
                    <span class="text">Download Excel</span>
                </button>
            </form>
            <?php
                }
            ?>
                
        </div>
    </div>
    <div class="dis-none panel-filter w-full p-t-10">
        <div style="padding: 12px; border-radius: 8px; display: flex; flex-wrap: wrap; justify-content: space-between; margin-bottom: 7px; background-color: #f0f0f0">
            <div class="flex flex-wrap justify-between gap-4">
                <!-- Kolom Kiri -->
                <div class="flex flex-col gap-1">
                    <p><b><?php echo $capt_nama_ujian;?></b> &nbsp&nbsp&nbsp&nbsp: <?php echo $nama_ujian; ?></p>
                    <p><b>Nama Bab</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $nama_bab; ?></p>
                    <p><b>Kelas</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $nama_subkelas; ?></p>
                    <p><b><?php echo $capt_tgl_ujian;?></b> : <?php echo $tanggal_ujian; ?></p>
                </div>

                <!-- Kolom Kanan -->
                <div class="flex flex-col gap-1 text-left">
                    <p><b><?php echo $capt_ikut;?></b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $jml_siswa_ikut_ujian; ?> siswa</p>
                    <p><b><?php echo $capt_tidak_ikut;?></b> : <?php echo $jml_siswa_tidak_ikut_ujian; ?> siswa</p>
                    <p><b>Guru Mata Pelajaran</b> &nbsp&nbsp&nbsp&nbsp&nbsp: <?php echo $barisv['nama_guru']; ?></p>
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

    if ($jenis_ujian !== 'OSIS') {
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
                        <th style='text-align:center'>NIS</th>
                        <th style='text-align:center'>Nama Siswa</th>
                        <th style='text-align:center'>Nilai</th>
                        <th style='text-align:center'></th>
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
                        s.uuidsiswa,
                        s.nis,
                        s.nama_siswa,
                        --COALESCE(CAST(SUM(d.nilai) AS TEXT), 'Belum Ujian') AS nilai,
                        COALESCE(
                            CAST(ROUND(SUM(d.nilai)::numeric, 1) AS TEXT),
                            'Belum Ujian'
                        ) AS nilai,
                         h.id_jawaban_siswa
                    FROM d_siswa s
                    JOIN (
                        -- ambil id_kelas dari ujian header yg dimaksud
                        SELECT DISTINCT s2.id_subkelas
                        FROM f_jawaban_siswa_hdr h2
                        JOIN d_siswa s2 ON s2.uuidsiswa = h2.uuidsiswa
                        WHERE h2.id_ujian_hdr = $id_ujian_hdr
                    ) kls ON s.id_subkelas = kls.id_subkelas
                    LEFT JOIN f_jawaban_siswa_hdr h 
                        ON h.uuidsiswa = s.uuidsiswa 
                        AND h.id_ujian_hdr = $id_ujian_hdr
                    LEFT JOIN f_jawaban_siswa_dtl d 
                        ON d.id_jawaban_siswa = h.id_jawaban_siswa
                    GROUP BY s.uuidsiswa, s.nis, s.nama_siswa,  h.id_jawaban_siswa
                    ORDER BY s.nama_siswa";

                        // $sql = "SELECT id_jawaban_siswa, h.uuidsiswa, h.nis, nama_siswa,
                        // (select sum(nilai) from f_jawaban_siswa_dtl d where d.id_jawaban_siswa = h.id_jawaban_siswa) nilai
                        // from f_jawaban_siswa_hdr h
                        // left join d_siswa s on s.uuidsiswa = h.uuidsiswa
                        // left join f_soal_hdr so on so.id_ujian_hdr = h.id_ujian_hdr
                        // where h.id_ujian_hdr = $id_ujian_hdr
                        // order by nama_siswa";                       
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            if ($baris['id_jawaban_siswa'] !== null) {
                                $tbl = "<button name='btn_edit' class='flex items-center bg-blue-500 hover:bg-blue-600 text-white text-sm font-medium py-1 px-3 rounded shadow'>
                                            <i class='fas fa-eye mr-1'></i>
                                            Lihat Jawaban Siswa
                                        </button>";
                            }
                            else {
                                $tbl = "";
                            }
                            echo "<tr>";
                                echo "<td>".$baris['nis']."</td>";
                                echo "<td>".$baris['nama_siswa']."</td>";
                                echo "<td>".$baris['nilai']."</td>";
                                 echo "<td class='align-middle text-center'>
                                <div class='flex justify-center items-center space-x-2'>
                                    <form method='post' action='hasil_nilai_siswa_per_siswa.php' class='inline-block'>
                                        <input type='hidden' name='mp' value='" . $mp . "' />
                                        <input type='hidden' name='kls' value='" . $kls . "' />
                                        <input type='hidden' name='ju' value='" . $ju . "' />
                                        <input type='hidden' name='id_subkelas' value='" . $id_subkelas_siswa . "' />
                                        <input type='hidden' name='kode_ujian' value='" . $kode_ujian . "' />
                                        <input type='hidden' name='nama_bab' value='" . $nama_bab . "' />
                                        <input type='hidden' name='id_ujian_hdr' value='" . $id_ujian_hdr . "' />
                                        <input type='hidden' name='tanggal_ujian' value='" . $tanggal_ujian . "' />
                                        <input type='hidden' name='nama_ujian' value='" . $nama_ujian . "' />
                                        <input type='hidden' name='nama_subkelas' value='" . $nama_subkelas . "' />
                                        <input type='hidden' name='nis' value='" . $baris['nis'] . "' />
                                        <input type='hidden' name='nama_siswa' value='" . $baris['nama_siswa'] . "' />
                                        <input type='hidden' name='id_jawaban_siswa' value='" . $baris['id_jawaban_siswa'] . "' />
                                        <input type='hidden' name='nilai' value='" . $baris['nilai'] . "' />
                                        <input type='hidden' name='uuidguru' value='" . $uuidguru . "' />
                                        <input type='hidden' name='nama_guru' value='" . $barisv['nama_guru'] . "' />
                                        ".$tbl."
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
<?php
    }
    else {
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
                        <th style='text-align:center'>NIS</th>
                        <th style='text-align:center'>Nama Siswa</th>
                        <th style='text-align:center'>Soal 1</th>
                        <th style='text-align:center'>Calon 1A</th>
                        <th style='text-align:center'>Calon 1B</th>
                        <th style='text-align:center'>Calon 1C</th>
                        <th style='text-align:center'>Soal 2</th>
                        <th style='text-align:center'>Calon 2A</th>
                        <th style='text-align:center'>Calon 2B</th>
                        <th style='text-align:center'>Calon 2C</th>
                        <th style='text-align:center'>Jawaban Soal 1</th>
                        <th style='text-align:center'>Jawaban Soal 2</th>
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
                        s.nis,
                        s.nama_siswa,
                        -- Soal dan opsi untuk nomor 1 (tanpa tag HTML)
                        regexp_replace(s1.isi_soal, '<[^>]*>', '', 'g') AS soal_1,
                        regexp_replace(s1.option_a, '<[^>]*>', '', 'g') AS option_1a,
                        regexp_replace(s1.option_b, '<[^>]*>', '', 'g') AS option_1b,
                        regexp_replace(s1.option_c, '<[^>]*>', '', 'g') AS option_1c,

                        -- Soal dan opsi untuk nomor 2 (tanpa tag HTML)
                        regexp_replace(s2.isi_soal, '<[^>]*>', '', 'g') AS soal_2,
                        regexp_replace(s2.option_a, '<[^>]*>', '', 'g') AS option_2a,
                        regexp_replace(s2.option_b, '<[^>]*>', '', 'g') AS option_2b,
                        regexp_replace(s2.option_c, '<[^>]*>', '', 'g') AS option_2c,

                        -- Jawaban siswa untuk soal 1
                        CASE d1.jawaban_siswa
                            WHEN 'A' THEN regexp_replace(s1.option_a, '<[^>]*>', '', 'g')
                            WHEN 'B' THEN regexp_replace(s1.option_b, '<[^>]*>', '', 'g')
                            WHEN 'C' THEN regexp_replace(s1.option_c, '<[^>]*>', '', 'g')
                            ELSE null
                        END AS jawaban_soal_1,

                        -- Jawaban siswa untuk soal 2
                        CASE d2.jawaban_siswa
                            WHEN 'A' THEN regexp_replace(s2.option_a, '<[^>]*>', '', 'g')
                            WHEN 'B' THEN regexp_replace(s2.option_b, '<[^>]*>', '', 'g')
                            WHEN 'C' THEN regexp_replace(s2.option_c, '<[^>]*>', '', 'g')
                            ELSE null
                        END AS jawaban_soal_2

                    FROM d_siswa s
                    LEFT JOIN d_kelas k ON k.id = s.id_kelas
                    LEFT JOIN d_subkelas sk ON sk.id = s.id_subkelas

                    -- gabungkan dengan data jawaban header (kalau ada)
                    LEFT JOIN f_jawaban_siswa_hdr h 
                        ON h.uuidsiswa = s.uuidsiswa 
                        AND h.id_ujian_hdr = $id_ujian_hdr

                    -- detail jawaban per nomor
                    LEFT JOIN f_jawaban_siswa_dtl d1 
                        ON d1.id_jawaban_siswa = h.id_jawaban_siswa 
                        AND d1.no_soal = 1
                    LEFT JOIN f_jawaban_siswa_dtl d2 
                        ON d2.id_jawaban_siswa = h.id_jawaban_siswa 
                        AND d2.no_soal = 2

                    -- soal untuk setiap nomor
                    LEFT JOIN f_soal_dtl s1 
                        ON s1.id_ujian_hdr = $id_ujian_hdr 
                        AND s1.no_soal = 1
                    LEFT JOIN f_soal_dtl s2 
                        ON s2.id_ujian_hdr = $id_ujian_hdr 
                        AND s2.no_soal = 2

                    -- hanya siswa di kelas/subkelas yang terkait ujian
                    WHERE s.id_kelas = (
                            SELECT id_kelas FROM f_jawaban_siswa_hdr 
                            WHERE id_ujian_hdr = $id_ujian_hdr LIMIT 1
                        )
                    AND s.id_subkelas = (
                            SELECT id_subkelas FROM f_jawaban_siswa_hdr 
                            WHERE id_ujian_hdr = $id_ujian_hdr LIMIT 1
                        )

                    ORDER BY s.nama_siswa;
                    ";

                        // $sql = "SELECT id_jawaban_siswa, h.uuidsiswa, h.nis, nama_siswa,
                        // (select sum(nilai) from f_jawaban_siswa_dtl d where d.id_jawaban_siswa = h.id_jawaban_siswa) nilai
                        // from f_jawaban_siswa_hdr h
                        // left join d_siswa s on s.uuidsiswa = h.uuidsiswa
                        // left join f_soal_hdr so on so.id_ujian_hdr = h.id_ujian_hdr
                        // where h.id_ujian_hdr = $id_ujian_hdr
                        // order by nama_siswa";                       
                        $hasil = $db->query($sql);

                        while ($baris = $hasil->fetch(PDO::FETCH_ASSOC)) {
                            echo "<tr>";
                                echo "<td>".$baris['nis']."</td>";
                                echo "<td>".$baris['nama_siswa']."</td>";
                                echo "<td>".$baris['soal_1']."</td>";
                                echo "<td>".$baris['option_1a']."</td>";
                                echo "<td>".$baris['option_1b']."</td>";
                                echo "<td>".$baris['option_1c']."</td>";
                                echo "<td>".$baris['soal_2']."</td>";
                                echo "<td>".$baris['option_2a']."</td>";
                                echo "<td>".$baris['option_2b']."</td>";
                                echo "<td>".$baris['option_2c']."</td>";
                                echo "<td>".$baris['jawaban_soal_1']."</td>";
                                echo "<td>".$baris['jawaban_soal_2']."</td>";
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
<?php
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