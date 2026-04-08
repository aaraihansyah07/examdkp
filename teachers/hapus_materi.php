<?php
                            include('config.php');
                            $id = $_GET['id'];

                            $sql = "DELETE FROM materi_tugas where id = $id";
                            $hasil = mysqli_query($koneksi, $sql);
                            
                            $sql2 = "DELETE FROM detail_materi_tugas where id_materi = $id";
                            $hasil2 = mysqli_query($koneksi, $sql2);

                            header('location:materi_tugas.php');
                    ?>