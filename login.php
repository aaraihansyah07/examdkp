<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width,initial-scale=1" />
	<title>E-Exam DKP - Login</title>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet" />
	<link rel="icon" type="image/x-icon" href="favicon.ico">
	<style>
		body {
		background: 
			linear-gradient(rgba(0, 84, 135, 0.6), rgba(0, 84, 135, 0.6)),
			url('bg_guru.webp') no-repeat center center;
		background-size: cover;
		min-height: 100vh;
		}


		.card {
			backdrop-filter: blur(10px);
			background: rgba(255, 255, 255, 0.9);
			border-radius: 1rem;
		}
		.btn-primary {
			background-color: #3498db;
			border-color: #3498db;
		}
		.btn-primary:hover {
			background-color: #2980b9;
			border-color: #2980b9;
		}
	</style>
</head>

<body>
	<section class="h-100 d-flex align-items-center">
		<div class="container">
			<div class="row justify-content-center">
				<div class="col-12 col-md-8 col-lg-6 col-xl-5">
					<div class="text-center mb-2">
						<img src="smadkp3.png" alt="Logo" class="img-fluid" style="max-width: 75%; height: auto;" />
					</div>
					<div class="card shadow-lg">
						<div class="card-body px-5 py-4">
							<h1 class="fs-4 card-title text-center fw-bold mb-4">Login</h1>
							<form method="POST" class="needs-validation" novalidate autocomplete="off" action="login.php">
								<div class="mb-3">
									<label class="mb-2 text-muted" for="uname">Username</label>
									<input id="uname" type="text" class="form-control" name="uname" required autofocus />
									<div class="invalid-feedback">Username is required</div>
								</div>

								<div class="mb-3">
									<label class="mb-2 text-muted" for="password">Password</label>
									<div style="position:relative">
										<input id="password" type="password" class="form-control" name="pwd" required />
																	<!-- Tombol mata -->
										<span onclick="togglePassword()" 
											style="position:absolute; top:50%; right:10px; transform:translateY(-50%); cursor:pointer;">
											👁️
										</span>
										<div class="invalid-feedback">Password is required</div>
									</div>
								</div>

								<div class="pt-2 flex justify-center">
									<!-- <div class="form-check">
										<input type="checkbox" name="remember" id="remember" class="form-check-input" />
										<label for="remember" class="form-check-label">Remember Me</label>
									</div> -->
									<center><button name="login" type="submit" class="btn btn-primary ms-auto px-5">
										Login
									</button></center>
								</div>
							</form>

							<?php
							include('config.php');

							if (isset($_POST['login'])) {
								$uname = $_POST['uname'];
								$pwd = $_POST['pwd'];

								// Ambil data user berdasarkan uname
								$sql = "SELECT uname, uuiduser, fname, role, pword FROM users WHERE lower(uname) = lower(:uname) LIMIT 1";
								$stmt = $db->prepare($sql);
								$stmt->bindParam(':uname', $uname);
								$stmt->execute();
								$user = $stmt->fetch(PDO::FETCH_ASSOC);

								// Verifikasi password
								if ($user && crypt($pwd, $user['pword']) === $user['pword']) {
									session_start();
									$_SESSION['uname'] = $user['uname'];
									$_SESSION['uuiduser'] = $user['uuiduser'];
									$_SESSION['fname'] = $user['fname'];
									$_SESSION['role'] = $user['role'];

									// Redirect sesuai role
									if ($user['role'] == '1') {
										header('Location: teachers/dashboard.php');
									} elseif ($user['role'] == '2') {
										header('Location: students/halaman_awal_ujian.php');
									} elseif ($user['role'] == '3') {
										header('Location: admin/dashboard.php');
									}
									exit;
								} else {
									echo "<div class='text-center text-danger mt-3'>Username atau password salah</div>";
								}
							}

							?>
						</div>

						<!-- <div class="card-footer text-center bg-transparent border-0">
							<p class="text-muted mb-2">Belum punya akun? Daftar sebagai</p>
							<div class="d-flex justify-content-center gap-2">
								<a href="register_pencari_kos" class="btn btn-primary">Pencari Kos</a>
								<a href="register" class="btn btn-primary">Pemilik Kos</a>
							</div>
						</div> -->
					</div>

					<p class="text-center text-white mt-4 small" style="font-weight:bold">&copy; <?php echo date('Y');?> E-Exam SMAN 1 Dukupuntang. All rights reserved.</p>
				</div>
			</div>
		</div>
	</section>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js"></script>
	<script>
        function togglePassword() {
            const input = document.getElementById("password");
            input.type = input.type === "password" ? "text" : "password";
        }
    </script>
</body>
</html>
