<?php
// download.php?file=soal_123.xlsx

// Optional: cek login/session
// require 'config.php';

if (!isset($_GET['file']) || empty($_GET['file'])) {
    http_response_code(400);
    exit('No file specified.');
}

$filename = basename($_GET['file']); // mencegah directory traversal
$baseDir = realpath(__DIR__ . '/../for_download'); // folder penyimpanan

if ($baseDir === false) {
    http_response_code(500);
    exit('Storage folder not found.');
}

$filePath = $baseDir . DIRECTORY_SEPARATOR . $filename;

if (!file_exists($filePath)) {
    http_response_code(404);
    exit('File not found.');
}

// Cek ekstensi yang diizinkan
$ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
$allowed = ['xlsx','xls','csv'];
if (!in_array($ext, $allowed)) {
    http_response_code(403);
    exit('Invalid file type.');
}

// Tentukan content-type
$contentTypes = [
    'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'xls'  => 'application/vnd.ms-excel',
    'csv'  => 'text/csv'
];
header('Content-Type: ' . $contentTypes[$ext]);
header('Content-Disposition: attachment; filename="'.rawurlencode($filename).'"');
header('Content-Length: ' . filesize($filePath));
header('Cache-Control: private');

// Output file
readfile($filePath);
exit;
