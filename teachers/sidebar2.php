<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sidebar E-Exam</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
</head>
<body class="bg-gray-100">

<div x-data="{ open: true }" class="flex h-screen">

    <!-- Sidebar -->
    <div :class="open ? 'w-64' : 'w-16'" class="bg-gradient-to-b from-blue-500 to-blue-600 text-white flex flex-col transition-all duration-300 fixed h-full">

        <div class="flex items-center justify-between p-4">
            <img src="logo.png" alt="Logo" class="w-12 h-12 rounded-full">
            <span x-show="open" class="ml-2 text-lg font-bold bg-blue-300 text-blue-900 px-3 py-1 rounded-full">E-EXAM</span>
        </div>

        <nav class="flex-1 px-2 mt-4 space-y-2">
            <a href="#" class="flex items-center px-3 py-2 rounded hover:bg-blue-700 transition">
                <i class="fas fa-th mr-2"></i>
                <span x-show="open">Dashboard</span>
            </a>
            <a href="#" class="flex items-center px-3 py-2 rounded bg-blue-700">
                <i class="fas fa-edit mr-2"></i>
                <span x-show="open" class="font-semibold">Buat Ujian</span>
            </a>
            <a href="#" class="flex items-center px-3 py-2 rounded hover:bg-blue-700 transition">
                <i class="fas fa-list mr-2"></i>
                <span x-show="open">Daftar Ujian Saya</span>
            </a>
            <a href="#" class="flex items-center px-3 py-2 rounded hover:bg-blue-700 transition">
                <i class="fas fa-chart-bar mr-2"></i>
                <span x-show="open">Hasil Nilai Siswa</span>
            </a>
        </nav>

        <!-- Toggle Button -->
        <div class="p-3 flex justify-center">
            <button @click="open = !open" class="bg-blue-400 hover:bg-blue-500 text-white p-2 rounded-full focus:outline-none transition">
                <i :class="open ? 'fas fa-chevron-left' : 'fas fa-chevron-right'"></i>
            </button>
        </div>

    </div>

    <!-- Content Area -->
    <div :class="open ? 'ml-64' : 'ml-16'" class="flex-1 transition-all duration-300 p-6">
<div class="max-w-full sm:max-w-4xl mx-auto p-4 bg-white shadow rounded-lg mt-6" x-data="soalForm()">
    <h1 class="text-2xl font-bold mb-4 text-gray-700">Buat Soal CBT (Mode Slide)</h1>

    <form method="post" action="simpan_soal.php" enctype="multipart/form-data">
        <div class="mb-4">
            <label class="block mb-1 font-medium">Pilih Ujian</label>
            <select name="id_ujian" class="w-full border rounded p-2">
                <?php foreach ($ujianList as $ujian): ?>
                    <option value="<?= $ujian['id_ujian'] ?>"><?= htmlspecialchars($ujian['nama_ujian']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <div class="mb-4">
            <label class="block mb-1 font-medium">Pilih Kelas</label>
            <select name="kelas" class="w-full border rounded p-2">
                <?php foreach ($kelasList as $kelas): ?>
                    <option value="<?= $kelas ?>"><?= $kelas ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <template x-for="(soal, index) in soalList" :key="index">
            <div x-show="currentSoal === index" class="p-4 border rounded-lg mb-4 bg-gray-50">
                <h2 class="text-lg font-semibold mb-2">Soal ke-<span x-text="index+1"></span></h2>
                <textarea :name="'soal['+index+'][isi_soal]'" class="w-full border rounded p-2 mb-2" placeholder="Isi soal"></textarea>

                <!-- Upload gambar -->
                <div class="mb-4">
                    <label class="block mb-1 font-medium">Upload Gambar Soal (optional)</label>
                    <input type="file" :id="'gambar_'+index" :name="'soal['+index+'][gambar]'" accept="image/*" 
                           @change="previewImage($event, index)" class="w-full border p-2 rounded">

                    <template x-if="soal.preview">
                        <div class="mt-3 flex flex-col sm:flex-row items-start sm:items-center gap-3">
                            <img :src="soal.preview" class="w-48 rounded shadow border">
                            <button type="button" @click="resetGambar(index)" 
                                    class="bg-red-500 text-white px-3 py-2 rounded hover:bg-red-600 text-sm">
                                Hapus Gambar
                            </button>
                        </div>
                    </template>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <textarea :name="'soal['+index+'][option_a]'" class="w-full border rounded p-2" placeholder="Option A"></textarea>
                    <textarea :name="'soal['+index+'][option_b]'" class="w-full border rounded p-2" placeholder="Option B"></textarea>
                    <textarea :name="'soal['+index+'][option_c]'" class="w-full border rounded p-2" placeholder="Option C"></textarea>
                    <textarea :name="'soal['+index+'][option_d]'" class="w-full border rounded p-2" placeholder="Option D"></textarea>
                    <textarea :name="'soal['+index+'][option_e]'" class="w-full border rounded p-2 md:col-span-2" placeholder="Option E"></textarea>
                </div>

                <div class="mt-3">
                    <label class="block mb-1 font-medium">Kunci Jawaban</label>
                    <select :name="'soal['+index+'][kunci]'" class="w-full border rounded p-2">
                        <option value="A">A</option>
                        <option value="B">B</option>
                        <option value="C">C</option>
                        <option value="D">D</option>
                        <option value="E">E</option>
                    </select>
                </div>
            </div>
        </template>

        <div class="flex justify-between mt-4">
            <button type="button" @click="prevSoal()" :disabled="currentSoal === 0" 
                    class="bg-gray-300 px-4 py-2 rounded hover:bg-gray-400 disabled:opacity-50">Sebelumnya</button>
            <button type="button" @click="nextSoal()" :disabled="currentSoal === soalList.length -1" 
                    class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 disabled:opacity-50">Selanjutnya</button>
        </div>

        <button type="button" @click="tambahSoal()" 
                class="mt-4 bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">Tambah Soal Baru</button>

        <button type="submit" 
                class="mt-4 bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600 float-right">Simpan Semua Soal</button>
    </form>
</div>
    </div>

</div>

<!-- Font Awesome (untuk icon) -->
<script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

</body>
</html>
