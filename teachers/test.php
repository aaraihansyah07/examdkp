<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Upload Soal</title>
</head>
<body>
    <h2>Upload Excel Soal</h2>
    <form action="test2.php" method="POST" enctype="multipart/form-data">
        <input type="file" name="excel_file" accept=".xlsx,.xls" required>
        <button type="submit">Upload</button>
    </form>
</body>
</html>
