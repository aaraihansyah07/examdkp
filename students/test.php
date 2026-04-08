<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>E-Tanda Tangan</title>
<style>
canvas {
  border: 1px solid #000;
}
</style>
</head>

<body>

<h3>Silakan tanda tangan:</h3>

<canvas id="signature" width="500" height="200"></canvas>
<br><br>

<button onclick="clearCanvas()">Clear</button>
<button onclick="saveSignature()">Simpan</button>

<script>
const canvas = document.getElementById("signature");
const ctx = canvas.getContext("2d");

let drawing = false;

canvas.addEventListener("mousedown", () => drawing = true);
canvas.addEventListener("mouseup", () => drawing = false);
canvas.addEventListener("mousemove", draw);

function draw(e) {
  if (!drawing) return;
  ctx.lineWidth = 2;
  ctx.lineCap = "round";

  ctx.lineTo(e.offsetX, e.offsetY);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(e.offsetX, e.offsetY);
}

function clearCanvas() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
}

function saveSignature() {
  const dataURL = canvas.toDataURL("image/png");

  fetch("save_signature.php", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ image: dataURL })
  })
  .then(res => res.text())
  .then(alert);
}
</script>

</body>
</html>
