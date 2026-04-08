                <?php
                    include('config.php');
                    if (isset($_POST['buat_rubrik'])) {
                        $level = $_POST['level'];
                        $exid = $_POST['exid'];
                        $kode_assign = $_POST['kode_assign'];

                        $sql = "DELETE FROM rubrik_asesmen where exid = $exid AND kode_assign = '$kode_assign' AND status_rubrik = 'E'";
                        $hasil = mysqli_query($koneksi, $sql);
                        
                        for ($i=1; $i<=$level; $i++) {
                            $sqlc = "INSERT INTO rubrik_asesmen(exid, kode_assign, level, status_rubrik) VALUES($exid, '$kode_assign', $i, 'E')";
                            $hasilc = mysqli_query($koneksi, $sqlc);
                        }

                        $loc = "rubrik_asesmen_diagnostik.php?exid=". $exid. "&kode_assign=". $kode_assign. "&level=". $level;
                        header('location:'. $loc);
                    }
                ?>