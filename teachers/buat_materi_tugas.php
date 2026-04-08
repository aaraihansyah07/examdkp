<?php
                    include('config.php');
                    if (isset($_POST['buat_akun'])) {
                        $kode_materi_tugas = $_POST['kode_materi_tugas'];
                        $status_dif = $_POST['status_dif'];
                        $jenis = $_POST['jenis'];

                        // $sql = "DELETE FROM rubrik_asesmen where kode_materi_tugas = '$kode_materi_tugas' AND status = 'E'";
                        // $hasil = mysqli_query($koneksi, $sql);
                    
                        $sqlc = "INSERT INTO materi_tugas(kode_materi_tugas, status_dif, jenis, status) VALUES('$kode_materi_tugas', 
                        '$status_dif', '$jenis', 'E')";
                        $hasilc = mysqli_query($koneksi, $sqlc);

                        $loc = "buat_materi_tugas_dtl.php?kode_materi_tugas=". $kode_materi_tugas. "&status_dif=". $status_dif;
                        header('location:'. $loc);
                    }
                ?>