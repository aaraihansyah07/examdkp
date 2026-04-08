<?php
                        if (isset($_POST['edit_akun'])) {
                            session_start();
                            if ($_SESSION['fname'] == null or $_SESSION['role'] <> '3') {
                                header('location:../login.php');
                            }
                            include('config.php');
                            $id_kelas = $_POST['kelasid'];
                            $nama_kelas = $_POST['nama_kelas'];

                            echo $id_kelas. $nama_kelas;

                            $sql4 = "UPDATE d_kelas set nama_kelas = '$nama_kelas' where id = :id_kelas";
                            $stmt4 = $db->prepare($sql4);
                            $stmt4->execute(['id_kelas' => $id_kelas]);

                            header('location:data_master_kelas.php?e=Y');
                        }
                    ?>