<?php
                    include('config.php');
                    if (isset($_POST['buat_feedback'])) {
                        $isi_feedback = $_POST['isi_feedback'];
                        $exid = $_POST['exid'];
                        $id_siswa = $_POST['id_siswa'];
                        $id_mapel = $_POST['id_mapel'];
                        $id_kelas = $_POST['id_kelas'];

                        $sqlc = "UPDATE pengerjaan_asesmen_diagnostik set feedback_guru = '$isi_feedback'
                        WHERE exid =$exid AND id_siswa = $id_siswa";
                        $hasilc = mysqli_query($koneksi, $sqlc);

                        $loc = "hasil_pengerjaan_asesmen_diagnostik.php?exid=".$exid."&id_kelas=".$id_kelas."&id_mapel=".$id_mapel."&no_soal=1&id_siswa=".$id_siswa."";
                        header('location:'. $loc);
                    }
                ?>