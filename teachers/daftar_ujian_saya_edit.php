<?php
    session_start();
    if ($_SESSION['fname'] == null or $_SESSION['role'] <> '1') {
        header('location:../login.php');
    }

    require 'config.php';
    if (!isset($_GET['hdrujn'])) {
        $id_ujian_hdr = $_POST['id_ujian_hdr'];
    }
    else {
        $id_ujian_hdr = $_GET['hdrujn'];
    }

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

    // if (isset($_GET['sk'])) {
    //     $sk = $_GET['sk'];
    // }
    // else {
    //     $sk = $_POST['sk'];
    // }

    
    $query = $db->prepare("SELECT * FROM f_soal_dtl WHERE id_ujian_hdr = :id_ujian_hdr ORDER BY no_soal ASC");
    $query->execute([':id_ujian_hdr' => $id_ujian_hdr]);
    $soalList = $query->fetchAll(PDO::FETCH_ASSOC);

    $sqlhdr = "SELECT u.jenis_ujian, h.st_susulan, h.st_nonaktif_ujian, soal_acak, option_acak, tanggal_ujian, h.id_ujian, h.uuidguru, durasi, h.kode_guru, h.kode_mata_pelajaran, h.kode_ujian, h.id_kelas, h.id_subkelas, h.st_posting, h.waktu_mulai,
    waktu_berakhir, nama_bab, h.token from f_soal_hdr h
    left join d_ujian u on u.id_ujian = h.id_ujian
    where h.id_ujian_hdr = $id_ujian_hdr";
    $hasilhdr = $db->query($sqlhdr);
    $barishdr = $hasilhdr->fetch(PDO::FETCH_ASSOC);

    if ($barishdr['st_posting'] == 'Y') {
        $st_posting = 'Sudah Diposting';
    }
    else {
        $st_posting = 'Masih Draft';
    }

    $kode_guru = $barishdr['kode_guru'];
    $uuidguru = $barishdr['uuidguru'];

    $soalActiveList = array_filter($soalList, function($s) {
        return empty($s['hapus_soal']) || $s['hapus_soal'] == '0';
    });
?>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>E-Exam | Edit Ujian </title>
    <script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
    <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>

    <!-- Custom fonts for this template-->
    <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link
        href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
        rel="stylesheet">

    <!-- Custom styles for this template-->
    <link href="css/sb-admin-2.min.css" rel="stylesheet">
    <style>
        #icon_daftar_ujian_saya {color:white}
        #daftar_ujian_saya {color:white; font-weight:bold}
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
                    <a href="daftar_ujian_saya.php?mp=<?php echo $mp;?>&kls=<?php echo $kls;?>&ju=<?php echo $ju;?>" style="color:white; margin-left:0.8%; font-size:90%">Daftar Ujian Saya > </a>
                    <a href="#" style="color:white; margin-left:0.5%; font-size:90%">Edit Ujian</a>
                </nav>
                <!-- End of Topbar -->

                <!-- Begin Page Content -->
                <div class="container-fluid">
                    <!-- Page Heading -->
                    <div class="d-sm-flex align-items-center justify-content-between mb-2">
                        <h1 class="h3 mb-0 text-gray-800">Edit Ujian</h1>
                        <!-- <a href="#" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                                class="fas fa-download fa-sm text-white-50"></i> Generate Report</a> -->
                    </div>

                    <div class="d-flex flex-wrap align-items-center gap-2">
                        <!-- Tombol Tambah -->
                        <a class="btn btn-secondary btn-icon-split" href="daftar_ujian_saya.php?mp=<?php echo $mp;?>&kls=<?php echo $kls;?>&ju=<?php echo $ju;?>">
                            <span class="text">Kembali</span>
                        </a>
                        <form method="POST" action="preview_ujian.php" style="margin:0" target="_blank">
                            <input type='hidden' name='token_input' value='<?php echo $barishdr['token'];?>'/>
                            <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                            <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                            <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
                            <button name="posting_ujian" class="btn btn-secondary btn-icon-split">
                                <span class="icon text-white-50">
                                    <i class="fas fa-eye"></i>
                                </span>
                                <span class="text">Preview Ujian</span>
                            </button>
                        </form>

                        <!-- Bungkus tombol kanan dengan ms-auto -->
                        <div class="d-flex gap-2 ms-auto">
                            <!-- Tombol Generate -->
                            <a data-toggle="modal" class="btn btn-secondary btn-icon-split" data-target="#createModal">
                                <span class="icon text-white-50">
                                    <i class="fas fa-copy"></i>
                                </span>
                                <span class="text">Copy Ujian</span>
                            </a>
                            <?php
                                if ($barishdr['st_posting'] == 'Y') {
                             ?>
                            <form method="POST" action="daftar_ujian_saya_redraft_proses.php" onsubmit="return confirm('Kembalikan jadi draft? Jika status menjadi draft ujian ini belum bisa dikerjakan oleh siswa')" style="margin:0">
                                <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/>
                                <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                                <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                                <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
                                <button name="posting_ujian" class="btn btn-secondary btn-icon-split">
                                    <span class="icon text-white-50">
                                        <i class="fas fa-sync"></i>
                                    </span>
                                    <span class="text">Jadikan Draft Kembali</span>
                                </button>
                            </form>
                            <?php
                                }
                            ?>
                             <?php
                                if ($barishdr['st_posting'] == null) {
                             ?>
                            <form method="POST" action="daftar_ujian_saya_posting_proses.php" onsubmit="return confirm('Setelah posting maka ujian ini tidak dapat diedit kembali dan sudah dapat dikerjakan oleh siswa')" style="margin:0">
                                <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/>
                                <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                                <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                                <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
                                <button name="posting_ujian" class="btn btn-secondary btn-icon-split">
                                    <span class="icon text-white-50">
                                        <i class="fas fa-sync"></i>
                                    </span>
                                    <span class="text">Posting</span>
                                </button>
                            </form>
                            <?php
                                }

                                if ($barishdr['st_posting'] == null) {
                            ?>

                            <!-- Tombol Hapus -->
                            <form method="POST" action="daftar_ujian_saya_hapus.php" onsubmit="return confirm('Yakin ingin menghapus draft ujian ini? semua soal di ujian ini juga akan terhapus')" style="margin:0">
                                <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/>
                                <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                                <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                                <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
                                <button name="hapus_ujian" class="btn btn-danger btn-icon-split">
                                    <span class="icon text-white-50">
                                        <i class="fas fa-trash"></i>
                                    </span>
                                    <span class="text">Hapus Draft</span>
                                </button>
                            </form>

                            <?php
                                }
                                if ($barishdr['st_nonaktif_ujian'] == null AND $barishdr['st_posting'] == 'Y' AND $barishdr['jenis_ujian'] == 'PSH') {
                            ?>
                            <form method="POST" action="daftar_ujian_saya_nonaktifkan_ujian.php" onsubmit="return confirm('Yakin ingin menonaktifkan ujian ini? Siswa tidak akan bisa mengerjakan ujian walaupun pada hari yang tepat pelaksanaan ujian')" style="margin:0">
                                <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/>
                                <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                                <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                                <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
                                <button name="hapus_ujian" class="btn btn-danger btn-icon-split">
                                    <span class="icon text-white-50">
                                        <i class="fas fa-stop"></i>
                                    </span>
                                    <span class="text">Nonaktifkan Ujian</span>
                                </button>
                            </form>
                            <?php
                                }

                                if ($barishdr['st_nonaktif_ujian'] == 'Y' AND $barishdr['st_posting'] == 'Y' AND $barishdr['jenis_ujian'] == 'PSH') {
                            ?>
                            <form method="POST" action="daftar_ujian_saya_aktifkan_ujian.php" onsubmit="return confirm('Yakin ingin aktifkan kembali ujian ini? Siswa akan bisa mengerjakan ujian pada hari yang tepat pada pelaksanaan ujian')" style="margin:0">
                                <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/>
                                <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                                <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                                <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
                                <button name="hapus_ujian" class="btn btn-secondary btn-icon-split">
                                    <span class="icon text-white-50">
                                        <i class="fas fa-rocket"></i>
                                    </span>
                                    <span class="text">Aktifkan Kembali Ujian</span>
                                </button>
                            </form>
                            <?php
                                }
                            ?>
                        </div>
                    </div>

                    <!-- Content Row -->
                    <div class="row">
                        <?php
                            $kode_guru = $_SESSION['uname'];

                            $sqlc = "SELECT uuidguru FROM d_guru where kode_guru = '$kode_guru'";
                            $hasilc = $db->query($sqlc);
                            $barisc = $hasilc->fetch(PDO::FETCH_ASSOC);
                            $uuidguru = $barisc['uuidguru'];

                            $query = $db->prepare("SELECT id_ujian, nama_ujian FROM d_ujian u
                            where 
                            EXISTS (SELECT kode_mata_pelajaran FROM d_penempatan_mapel_guru pg where kode_guru = '$kode_guru' and pg.kode_mata_pelajaran = u.kode_mata_pelajaran)");
                            $query->execute();
                            $ujianList = $query->fetchAll(PDO::FETCH_ASSOC);

                            // $sql2 = "SELECT id_kelas, id_subkelas, waktu_mulai, waktu_berakhir, kode_guru, uuidguru, nama_bab 
                            // FROM f_soal_hdr where id_ujian_hdr = '$id_ujian_hdr'";
                            // $hasil2 = $db->query($sql2);
                            // $baris2 = $hasil2->fetch(PDO::FETCH_ASSOC);
                            // $uuidguru = $barisc['uuidguru'];
                        ?>
<div class="w-full mx-auto p-4 bg-white shadow rounded-lg mt-6" x-data="soalForm()">
    <form method="post" action="daftar_ujian_saya_edit_proses.php" enctype="multipart/form-data">
        <input type="hidden" name="kode_guru" value="<?= $barishdr['kode_guru']; ?>">
        <input type="hidden" name="uuidguru" value="<?= $barishdr['uuidguru']; ?>">
        <input type="hidden" name="id_ujian_hdr" value="<?= $id_ujian_hdr; ?>">
        <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
        <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
        <input type='hidden' name='ju' value='<?php echo $ju;?>'/>
        <!-- Header form -->
        <div class="mb-4">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <p><b>Pilih Ujian</b></p>
                    <select required name="id_ujian" class="w-full border rounded p-2">
                        <option value=""></option>
                        <?php
                            $sql2 = "SELECT id_ujian, nama_ujian FROM d_ujian u
                                     WHERE EXISTS (SELECT kode_mata_pelajaran FROM d_penempatan_mapel_guru pg 
                                     WHERE kode_guru = '$kode_guru' AND pg.kode_mata_pelajaran = u.kode_mata_pelajaran)";
                            $hasil2 = $db->query($sql2);
                            while ($baris2 = $hasil2->fetch(PDO::FETCH_ASSOC)) {
                        ?>
                        <option value="<?= $baris2['id_ujian']; ?>" <?= ($barishdr['id_ujian'] == $baris2['id_ujian']) ? 'selected' : '' ?>><?= $baris2['nama_ujian']; ?></option>
                        <?php } ?>
                    </select>
                </div>
                <div>
                    <p><b>Untuk Ujian Susulan?</b></p>
                    <select required name="st_susulan" class="w-full border rounded p-2">
                        <option value=""></option>
                        <option value="Y" <?= ($barishdr['st_susulan'] == 'Y') ? 'selected' : '' ?>>Ya</option>
                        <option value="N" <?= ($barishdr['st_susulan'] == 'N') ? 'selected' : '' ?>>Tidak</option>
                    </select>
                </div>
                <div>
                    <p><b>Tanggal Ujian</b></p>
                    <input required type="date" name="tanggal_ujian" value="<?= $barishdr['tanggal_ujian']; ?>" class="w-full border rounded p-2">
                </div>


                <!-- <div>
                    <p><b>Waktu Mulai</b></p>
                    <input required type="datetime-local" name="waktu_mulai" value="<?= $barishdr['waktu_mulai']; ?>" class="w-full border rounded p-2">
                </div>

                <div>
                    <p><b>Waktu Berakhir</b></p>
                    <input required type="datetime-local" name="waktu_berakhir" value="<?= $barishdr['waktu_berakhir']; ?>" class="w-full border rounded p-2">
                </div> -->
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <p><b>Durasi Ujian (Menit)</b></p>
                <input required type="number" name="durasi" value="<?= $barishdr['durasi']; ?>" class="w-full border rounded p-2">
            </div>
            <div>
                <p><b>Nama Materi/Bab</b></p>
                <input name="nama_bab" type="text" class="form-control w-full border rounded p-2" value="<?= $barishdr['nama_bab']; ?>">
            </div>

            <div>
                <p><b>Subkelas yang Dituju</b></p>
                <select required name="id_subkelas" class="w-full border rounded p-2">
                    <option value=""></option>
                    <?php
                        $sql3 = "SELECT id, nama_subkelas FROM d_subkelas";
                        $hasil3 = $db->query($sql3);
                        while ($baris3 = $hasil3->fetch(PDO::FETCH_ASSOC)) {
                    ?>
                    <option value="<?= $baris3['id']; ?>" <?= ($barishdr['id_subkelas'] == $baris3['id']) ? 'selected' : '' ?>><?= $baris3['nama_subkelas']; ?></option>
                    <?php } ?>
                </select>
            </div>
        </div><br>

        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
                <p><b>Acak Soal?</b></p>
                <select required name="soal_acak" class="w-full border rounded p-2">
                    <option value=""></option>
                    <option value="Y" <?= ($barishdr['soal_acak'] == 'Y') ? 'selected' : '' ?>>Ya</option>
                    <option value="N" <?= ($barishdr['soal_acak'] == 'N') ? 'selected' : '' ?>>Tidak</option>
                </select>
            </div>

            <div>
                <p><b>Acak Option?</b></p>
                <select required name="option_acak" class="w-full border rounded p-2">
                    <option value=""></option>
                    <option value="Y" <?= ($barishdr['option_acak'] == 'Y') ? 'selected' : '' ?>>Ya</option>
                    <option value="N" <?= ($barishdr['option_acak'] == 'N') ? 'selected' : '' ?>>Tidak</option>
                </select>
            </div>

            <div>
                <p><b>Informasi Soal Ujian ini</b></p>
                <?php
                    $sqlsoal = "SELECT count(1) jml_soal, round(nilai::numeric, 1) nilai
                    from f_soal_dtl
                    where id_ujian_hdr = $id_ujian_hdr
                    group by nilai limit 1";
                    $hasilsoal = $db->query($sqlsoal);
                    $barissoal = $hasilsoal->fetch(PDO::FETCH_ASSOC);
                ?>
                <input disabled type="text" class="form-control w-full border rounded p-2" value="<?php echo 'Jumlah Soal : '. $barissoal['jml_soal'].', Skor per Soal : '. $barissoal['nilai'];?>">
            </div>

            <div>
                <p><b>Token Ujian</b></p>
                <input disabled type="text" class="form-control w-full border rounded p-2" value="<?php echo $barishdr['token']. ' ('. $st_posting. ')';?>">
            </div>
        </div><br>

        <!-- Soal -->
        <template x-for="(soal, index) in soalList" :key="index">
            <div x-show="currentSoal === index" class="p-4 border rounded-lg mb-4 bg-gray-50" :class="{'opacity-20': soal.hapus_soal == '1'}">

                <div class="flex justify-between items-center mb-2">
                    <h2 class="text-lg font-semibold">Soal <span x-text="index+1"></span></h2>
                    <?php
                        if ($barishdr['st_posting'] == null) {
                    ?>
                    <button type="button" @click="hapusSoal(index)" class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-sm">
                        <template x-if="soal.hapus_soal == '0'">Hapus Soal</template>
                        <template x-if="soal.hapus_soal == '1'">Batalkan Hapus</template>
                        Tandai Soal untuk Dihapus
                    </button>
                    <?php
                        }
                    ?>
                </div>

                <!-- Hidden input untuk identitas & status -->
                <input type="hidden" :name="'soal['+index+'][seq_soal_dtl]'" :value="soal.seq_soal_dtl">
                <input type="hidden" :name="'soal['+index+'][hapus_soal]'" :value="soal.hapus_soal">

                <!-- <textarea style="height:200px" :name="'soal['+index+'][isi_soal]'" x-model="soal.isi_soal" class="w-full border rounded p-2 mb-2" placeholder="Isi soal"></textarea> -->
                <!-- Hidden textarea untuk submit -->
                <textarea :id="'editor-textarea-'+index"
                        :name="'soal['+index+'][isi_soal]'"
                        x-model="soal.isi_soal"
                        style="display:none"></textarea>

                <!-- Div editor Quill -->
                <div :id="'editor-'+index" class="editor" style="height:200px; background:white"></div><br>   


                <!-- Gambar soal -->
                <div class="mb-4">
                    <label class="block mb-1">Gambar Soal</label>
                    <input type="file" :name="'soal['+index+'][gambar]'" accept="image/*" @change="previewImage($event, index)" class="w-full border rounded p-2">
                    <template x-if="soal.preview">
                        <div class="mt-2 relative">
                            <img :src="soal.preview" class="w-48 rounded shadow">
                            <?php
                                if ($barishdr['st_posting'] == null) {
                             ?>
                            <button type="button" @click="hapusGambar(index)" class="absolute top-0 right-0 bg-red-500 text-white px-2 py-1 text-xs rounded">Hapus Gambar</button>
                            <?php
                                }
                            ?>
                        </div>
                    </template>


                    <input type="hidden" :name="'soal['+index+'][hapus_gambar]'" x-model="soal.hapus_gambar">
                    <input type="hidden" :name="'soal['+index+'][gambar_soal_filename]'" x-model="soal.gambar_soal_filename">
                </div>

                <!-- Options -->
                <!-- <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div><label>Pilihan A</label><textarea :name="'soal['+index+'][option_a]'" x-model="soal.option_a" class="w-full border rounded p-2"></textarea></div>
                    <div><label>Pilihan B</label><textarea :name="'soal['+index+'][option_b]'" x-model="soal.option_b" class="w-full border rounded p-2"></textarea></div>
                    <div><label>Pilihan C</label><textarea :name="'soal['+index+'][option_c]'" x-model="soal.option_c" class="w-full border rounded p-2"></textarea></div>
                    <div><label>Pilihan D</label><textarea :name="'soal['+index+'][option_d]'" x-model="soal.option_d" class="w-full border rounded p-2"></textarea></div>
                    <div class="md:col-span-2"><label>Pilihan E</label><textarea :name="'soal['+index+'][option_e]'" x-model="soal.option_e" class="w-full border rounded p-2"></textarea></div>
                </div> -->

                <!-- Options -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div>
                    <label>Pilihan A</label>
                    <textarea :id="'editor-textarea-'+index+'-option_a'"
                                :name="'soal['+index+'][option_a]'"
                                x-model="soal.option_a"
                                style="display:none"></textarea>
                    <div :id="'editor-'+index+'-option_a'" class="editor" style="height:120px; background:white"></div>
                    </div>

                    <div>
                    <label>Pilihan B</label>
                    <textarea :id="'editor-textarea-'+index+'-option_b'"
                                :name="'soal['+index+'][option_b]'"
                                x-model="soal.option_b"
                                style="display:none"></textarea>
                    <div :id="'editor-'+index+'-option_b'" class="editor" style="height:120px; background:white"></div>
                    </div>              
                    <div>
                    <label>Pilihan C</label>
                    <textarea :id="'editor-textarea-'+index+'-option_c'"
                                :name="'soal['+index+'][option_c]'"
                                x-model="soal.option_c"
                                style="display:none"></textarea>
                    <div :id="'editor-'+index+'-option_c'" class="editor" style="height:120px; background:white"></div>
                    </div>
                    <div>
                    <label>Pilihan D</label>
                    <textarea :id="'editor-textarea-'+index+'-option_d'"
                                :name="'soal['+index+'][option_d]'"
                                x-model="soal.option_d"
                                style="display:none"></textarea>
                    <div :id="'editor-'+index+'-option_d'" class="editor" style="height:120px; background:white"></div>
                    </div>  

                    <div class="md:col-span-2">
                        <label class="block mb-1">Pilihan E</label>
                        
                        <!-- hidden textarea sinkronisasi ke backend -->
                        <textarea 
                            :id="'editor-textarea-'+index+'-option_e'"
                            :name="'soal['+index+'][option_e]'"
                            x-model="soal.option_e"
                            class="hidden"
                        ></textarea>
                        
                        <!-- quill editor tampilan -->
                        <div 
                            :id="'editor-'+index+'-option_e'" 
                            class="editor w-full border rounded p-2 bg-white min-h-[120px]"></div>
                    </div> 
                </div>

                <div class="mt-20">
                    <label>Kunci Jawaban</label>
                    <select :name="'soal['+index+'][kunci_jawaban]'" x-model="soal.kunci_jawaban" class="w-full border rounded p-2">
                        <option value=""></option>
                        <option value="A">A</option>
                        <option value="B">B</option>
                        <option value="C">C</option>
                        <option value="D">D</option>
                        <option value="E">E</option>
                    </select>
                </div><br>
                <h2 class="text-rg font-semibold" style="text-align:right; color:red">Soal <span x-text="index+1"></span></h2>
            </div>

        </template>

        <!-- Navigasi -->
        <div class="flex justify-between mt-4">
            <button type="button" @click="prevSoal()" :disabled="currentSoal === 0" class="bg-gray-300 px-2 py-2 rounded">Sebelumnya</button>
            <button type="button" @click="nextSoal()" :disabled="currentSoal >= soalList.length -1" class="bg-blue-500 text-white px-2 py-2 rounded">Selanjutnya</button>
        </div>
        <?php
        if ($barishdr['st_posting'] == null) {
        ?>
            <button type="button" @click="tambahSoal()" class="mt-4 bg-green-500 text-white px-2 py-2 rounded">Tambah Soal</button>
            <button name="btn_update" type="submit" class="mt-4 bg-purple-500 text-white px-2 py-2 rounded float-right">Simpan Perubahan</button>
        <?php
        }
        ?>
    </form>
</div>

                    </div>
                </div>
                <!-- /.container-fluid -->
            </div><br>
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

    <!-- Create Modal-->
    <div class="modal fade" id="createModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Copy Ujian Ini</h5>
                    <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">×</span>
                    </button>
                </div>
                <form class="user" action="copy_ujian.php" method="post" style="padding:1% 3% 0 3%" id="form_copy">
                    <div style="flex: 1; margin-right: 10px; margin-bottom: 10px;">
                    <!-- <p><b>Tanggal Lahir</b></p>
                    <div class="form-group">
                        <input required name="tanggal_lahir" type="date" class="form-control">
                    </div> -->
                        <input type='hidden' name='id_ujian_hdr' value='<?php echo $id_ujian_hdr;?>'/> 
                        <input type='hidden' name='id_kelas' value='<?php echo $barishdr['id_kelas'];?>'/>
                        <input type='hidden' name='mp' value='<?php echo $mp;?>'/>
                        <input type='hidden' name='kls' value='<?php echo $kls;?>'/>
                        <input type='hidden' name='ju' value='<?php echo $ju;?>'/>   
                        <p><b>Untuk Ujian Susulan?</b></p>
                        <select required name="st_susulan_copy" class="w-full border rounded p-2">
                            <option value=""></option>
                            <option value="Y">Ya</option>
                            <option value="N">Tidak</option>
                        </select><br>

                        <br><p><b>Subkelas Tujuan</b></p>
                        <div class="mb-4 mt-2">
                            <?php
                                $id_kelas_hdr = $barishdr['id_kelas'];
                                $id_subkelas_hdr = $barishdr['id_subkelas'];
                                $nama_bab_hdr = $barishdr['nama_bab'];
                                $id_ujian_hdr_hdr = $barishdr['id_ujian'];
                                $kode_mata_pelajaran_hdr = $barishdr['kode_mata_pelajaran'];
                                
                                $sqlb = "SELECT sk.id, sk.nama_subkelas FROM d_subkelas sk
                                where sk.id_kelas = $id_kelas_hdr
                                --and not exists 
                                    --(select 'x' from f_soal_hdr h where h.id_subkelas = sk.id
                                  --  and h.nama_bab = '$nama_bab_hdr' and h.id_ujian = $id_ujian_hdr_hdr
                                  --  and h.kode_mata_pelajaran = '$kode_mata_pelajaran_hdr'
                                 --   ) 
                                order by sk.nama_subkelas";
                                $hasilb = $db->query($sqlb);

                                echo '<div class="flex flex-wrap">';
                                $counter = 0;
                                while ($barisb = $hasilb->fetch(PDO::FETCH_ASSOC)) {
                                    echo "<label class='flex items-center w-1/4 mb-2 space-x-2'>
                                            <input type='checkbox' name='id_subkelas[]' value='" . $barisb['id'] . "' class='form-checkbox text-blue-600'>
                                            <span>" . htmlspecialchars($barisb['nama_subkelas'], ENT_QUOTES) . "</span>
                                        </label>";
                                    $counter++;
                                }
                                echo '</div>';
                            ?>
                            </div>
                        </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" type="submit" data-dismiss="modal">Cancel</button>
                        <button class="btn btn-primary" type="submit" name="buat_akun" id="btn_copy">Copy</button>
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
    const form = document.getElementById("form_copy");
    const btn = document.getElementById("btn_copy");

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
function initEditors(root = document) {
    // cari semua editor di root (default: document)
    root.querySelectorAll(".editor").forEach(editorEl => {
        // skip jika sudah pernah diinisialisasi
        if (editorEl.dataset.quillReady === "true") return;
        editorEl.dataset.quillReady = "true";

        // ambil index dan field dari id, contoh: editor-0 / editor-0-option_a
        let parts = editorEl.id.split("-");
        let idx = parts[1];
        let field = parts[2] || "isi_soal";

        // cari textarea pasangan
        let textareaId = "editor-textarea-" + idx + (field !== "isi_soal" ? "-" + field : "");
        let textarea = document.getElementById(textareaId);
        if (!textarea) return;

        // buat Quill
        let quill = new Quill(editorEl, {
            theme: "snow",
            modules: {
                toolbar: [
                    ["bold", "italic", "underline"],
                    [{ script: "sub" }, { script: "super" }]
                ]
            }
        });

        // preload isi textarea (saat edit)
        if (textarea.value) quill.root.innerHTML = textarea.value;

        // sinkronisasi saat submit
        editorEl.closest("form")?.addEventListener("submit", function () {
            textarea.value = quill.root.innerHTML;
        });
    });
}
</script>

<script>
function soalForm() {
    return {
        soalList: <?= json_encode(array_map(function($s) {
            return [
                'seq_soal_dtl' => $s['seq_soal_dtl'],
                'isi_soal' => $s['isi_soal_unicode'],
                'option_a' => $s['option_a_unicode'],
                'option_b' => $s['option_b_unicode'],
                'option_c' => $s['option_c_unicode'],
                'option_d' => $s['option_d_unicode'],
                'option_e' => $s['option_e_unicode'],
                'kunci_jawaban' => $s['kunci_jawaban'],
                'gambar_soal_filename' => $s['gambar_soal_filename'],
                'preview' => $s['gambar_soal_filename'] ? '../uploads/'.$s['gambar_soal_filename'] : '',
                'hapus_gambar' => '0',
                'hapus_soal' => '0'
            ];
        }, $soalList)) ?>,
        currentSoal: 0,

        nextSoal() { if(this.currentSoal < this.soalList.length - 1) this.currentSoal++; },
        prevSoal() { if(this.currentSoal > 0) this.currentSoal--; },

        tambahSoal() {
            this.soalList.push({
                seq_soal_dtl: '',
                isi_soal: '',
                option_a: '',
                option_b: '',
                option_c: '',
                option_d: '',
                option_e: '',
                kunci_jawaban: '',
                gambar_soal_filename: '',
                preview: '',
                hapus_gambar: '0',
                hapus_soal: '0'
            });
            this.currentSoal = this.soalList.length - 1;

            // init semua editor baru (soal lama sudah di-skip)
            this.$nextTick(() => {
                initEditors();
            });
        },

        hapusSoal(index) {
            if (this.soalList[index].seq_soal_dtl) {
                this.soalList[index].hapus_soal = this.soalList[index].hapus_soal === '1' ? '0' : '1';
            } else {
                if (confirm('Yakin ingin menghapus soal baru ini?')) {
                    this.soalList.splice(index, 1);
                }
            }
        },

        previewImage(event, index) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = e => {
                    this.soalList[index].preview = e.target.result;
                    this.soalList[index].hapus_gambar = '0';
                }
                reader.readAsDataURL(file);
            }
        },

        hapusGambar(index) {
            this.soalList[index].preview = '';
            this.soalList[index].hapus_gambar = '1';
            this.soalList[index].gambar_soal_filename = '';
        }
    }
}
</script>

<script>
function togglePassword() {
    const input = document.getElementById("inputPassword");
    input.type = input.type === "password" ? "text" : "password";
}

// init editor soal lama saat halaman load
document.addEventListener("DOMContentLoaded", function() {
    initEditors();
});
</script>

</body>
</html>