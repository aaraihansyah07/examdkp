<?php
                        if (isset($_POST['edit_akun'])) {
                            include('config.php');
                            $exid = $_POST['exid'];
                            $nama_exam = $_POST['exname'];
                            $waktu_asesmen = $_POST['extime'];
                            $waktu_penyerahan = $_POST['subt'];
                            $keterangan = $_POST['desp'];
                            $kelas = $_POST['kelas'];
                            $mapel = $_POST['mapel'];

                            echo "$exid, $nama_exam, $waktu_asesmen, $waktu_penyerahan, $keterangan, $kelas, $mapel";

                            $sql2 = "UPDATE exm_list set exname = '$nama_exam', extime = '$waktu_asesmen', 
                            subt = '$waktu_penyerahan', desp = '$keterangan', kelas = '$kelas', id_mata_pelajaran = $mapel
                            WHERE exid = $exid";
                            $hasil2 = mysqli_query($koneksi, $sql2);

                            header('location:asesmen_diagnostik.php');
                        }
                    ?>