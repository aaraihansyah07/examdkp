<nav class="navbar navbar-expand navbar-light topbar mb-4 static-top shadow">

    <!-- Sidebar Toggle (Topbar) -->
    <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
        <i class="fa fa-bars"></i>
    </button>

    <!-- Judul Halaman / Brand -->
    <span class="navbar-brand mb-0 h5 text-primary font-weight-bold d-none d-sm-inline">
        <i class="fas fa-clipboard-list mr-2"></i> Sistem Ujian Online SMAN 1 Dukupuntang
    </span>
    <span class="navbar-brand mb-0 h6 text-primary font-weight-bold d-inline d-sm-none">
        <i class="fas fa-clipboard-list mr-1"></i> Sistem Ujian Online
    </span>

    <!-- Topbar Navbar -->
    <ul class="navbar-nav ml-auto">

        <div class="topbar-divider d-none d-sm-block"></div>

        <!-- Nav Item - User Information -->
        <li class="nav-item dropdown no-arrow">
            <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button"
                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <span class="mr-2 d-none d-lg-inline text-gray-600 small"><?php echo $_SESSION['fname']?></span>
                <img class="img-profile rounded-circle" src="img/undraw_profile.svg">
            </a>
            <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in"
                aria-labelledby="userDropdown">
                <a class="dropdown-item" href="#" data-toggle="modal" data-target="#ganti_password_modal">
                    <i class="fas fa-user fa-sm fa-fw mr-2 text-gray-400"></i>
                    Ganti Password
                </a>
                <div class="dropdown-divider"></div>
                <a class="dropdown-item" href="logout.php" data-toggle="modal" data-target="#logoutModal">
                    <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-400"></i>
                    Logout
                </a>
            </div>
        </li>

    </ul>
</nav>


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

    <script>
        function togglePassword() {
            const input = document.getElementById("inputPassword");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>