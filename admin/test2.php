<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Test LaTeX</title>
  <script>
    window.MathJax = {
      tex: { inlineMath: [['$', '$'], ['\\(', '\\)']] },
      svg: { fontCache: 'global' }
    };
  </script>
  <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    .formula { font-size: 1.2rem; margin: 20px 0; }
  </style>
</head>
<body>
  <h1>Test LaTeX ke Formula</h1>

  <?php
    $latex = '\lim_{x \to 4}\frac{\sqrt{x}-2}{x-4}=';
    echo '<div class="formula">$' . $latex . '$</div>';
  ?>

</body>
</html>
