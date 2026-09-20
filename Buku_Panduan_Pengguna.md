# BUKU PANDUAN PENGGUNA (USER MANUAL)
## FINANCE TRACKER - APLIKASI PERHITUNGAN HPP, BEP, DAN MANAJEMEN KEUANGAN UMKM

Aplikasi **Finance Tracker** dirancang untuk membantu pelaku UMKM (Usaha Mikro, Kecil, dan Menengah) dalam mengelola keuangan bisnis secara mandiri, mulai dari menghitung Harga Pokok Penjualan (HPP), menentukan Break-Even Point (BEP), mensimulasikan harga jual, mencatat rencana tabungan bisnis, hingga menganalisis performa bisnis melalui grafik insight.

Dokumen ini berisi panduan lengkap penggunaan aplikasi dari awal (registrasi/login) hingga fitur analisis akhir.

---

## DAFTAR ISI
1. [Alur Registrasi, Login & Verifikasi Email](#1-alur-registrasi-login--verifikasi-email)
2. [Dashboard / Beranda (Home)](#2-dashboard--beranda-home)
3. [Fitur Kalkulator HPP & BEP](#3-fitur-kalkulator-hpp--bep)
4. [Halaman Hasil Analisis & Simulasi Harga Jual](#4-halaman-hasil-analisis--simulasi-harga-jual)
5. [Fitur Rencana Tabungan (Savings Plan)](#5-fitur-rencana-tabungan-savings-plan)
6. [Fitur Insight & Statistik Bisnis](#6-fitur-insight--statistik-bisnis)
7. [Fitur Riwayat Perhitungan (History)](#7-fitur-riwayat-perhitungan-history)
8. [Pengaturan Profil & Keanggotaan Premium](#8-pengaturan-profil--keanggotaan-premium)

---

## 1. ALUR REGISTRASI, LOGIN & VERIFIKASI EMAIL

Bagian ini menjelaskan langkah awal bagi pengguna baru untuk membuat akun dan masuk ke dalam aplikasi secara aman.

### A. Registrasi Akun Baru
1. Buka aplikasi, Anda akan disambut oleh halaman **Welcome Screen**. Ketuk tombol **Daftar Sekarang**.
2. Di halaman **Register**, isi informasi berikut:
   * **Nama Lengkap**: Nama pemilik atau nama bisnis Anda.
   * **Email**: Alamat email aktif Anda (akan digunakan untuk verifikasi).
   * **Kata Sandi (Password)**: Sandi minimal 6 karakter.
3. Ketuk tombol **Daftar**.

### B. Verifikasi Email
1. Setelah menekan tombol daftar, aplikasi akan mengirimkan link verifikasi ke email Anda secara otomatis.
2. Anda akan diarahkan ke halaman **Verifikasi Email**.
3. Buka kotak masuk email Anda, cari email dari sistem, lalu klik link verifikasi yang dikirimkan.
4. Setelah berhasil memverifikasi di email Anda, ketuk tombol **Saya Sudah Verifikasi** di aplikasi untuk melanjutkan ke halaman utama.

### C. Login / Masuk
Bagi pengguna yang sudah memiliki akun:
1. Di halaman utama Welcome, ketuk **Masuk**.
2. Masukkan **Email** dan **Password** Anda, lalu ketuk **Login**.
3. Anda juga dapat masuk secara instan menggunakan akun Google dengan mengetuk tombol **Masuk dengan Google**.
4. Jika Anda lupa kata sandi, ketuk tulisan **Lupa Kata Sandi?**, masukkan email Anda, dan ikuti instruksi pemulihan yang dikirim ke email.

---

## 2. DASHBOARD / BERANDA (HOME)

Dashboard adalah pusat kendali bisnis Anda. Di sini Anda bisa memantau performa keuangan bulanan secara cepat.

### A. Komponen Utama Dashboard:
1. **Target Profit Bulanan**: Angka keuntungan yang ingin dicapai bulan ini. Anda bisa mengubah target ini kapan saja dengan mengetuk tombol edit (ikon pensil) di samping angka target.
2. **Untung Bersih Bulan Ini**: Akumulasi keuntungan bersih riil yang diperoleh dari penjualan produk yang terdaftar di Riwayat.
3. **Persentase Progress Bar**: Menunjukkan seberapa dekat bisnis Anda dalam mencapai target profit bulanan (misal: "Target Tercapai 65%").
4. **Statistik Cepat**:
   * **Total Produk**: Jumlah produk yang telah Anda hitung HPP/BEP-nya.
   * **Total Tabungan**: Akumulasi dana tabungan bisnis yang berhasil dikumpulkan.
5. **Dukungan Data Awal (Mock Data/Seeder)**: Untuk pengguna baru, aplikasi akan otomatis memuat beberapa data sampel (simulasi) di awal agar Anda langsung dapat melihat visualisasi grafik dan cara kerja dashboard.

---

## 3. FITUR KALKULATOR HPP & BEP

Fitur ini adalah inti dari aplikasi, membantu Anda menghitung biaya produksi riil dan titik impas penjualan.

### Latihan Langkah demi Langkah:

### LANGKAH 1: Menghitung HPP (Harga Pokok Penjualan)
Akses menu ini dengan mengetuk tab pertama (ikon kalkulator `Calculate`) di navigasi bawah.

Masukkan data biaya produksi Anda:
1. **Nama Produk**: Beri nama produk yang ingin dihitung (misal: "Kue Brownies").
2. **Biaya Bahan Baku**: Total biaya bahan-bahan langsung untuk memproduksi barang.
3. **Biaya Tenaga Kerja**: Upah untuk pekerja yang memproduksi produk tersebut.
4. **Biaya Overhead Pabrik**: Biaya pendukung lainnya (seperti listrik, air, gas, kemasan).
5. **Jumlah Unit Diproduksi**: Total unit yang dihasilkan dari total biaya di atas.
6. **Persediaan Awal (Opsional)**: Nilai stok produk yang sudah ada di awal periode.
7. **Pembelian Bersih (Opsional)**: Pembelian barang jadi/bahan tambahan selama periode berjalan.
8. **Persediaan Akhir (Opsional)**: Sisa stok produk di akhir periode yang belum terjual.
9. Ketuk **Lanjut ke BEP**.

### LANGKAH 2: Menghitung BEP (Break-Even Point)
Setelah mengisi data HPP, Anda akan masuk ke formulir perhitungan BEP:
1. **Biaya Per Unit (Otomatis)**: Diambil langsung dari hasil pembagian Total HPP dengan Jumlah Unit pada langkah sebelumnya.
2. **Harga Jual Per Unit**: Tentukan harga yang ingin Anda tawarkan ke konsumen per satu barang. *(Catatan: Harga jual harus lebih tinggi daripada biaya per unit/modal agar tidak rugi).*
3. **Total Biaya Tetap**: Biaya operasional rutin yang jumlahnya tetap dan tidak bergantung pada volume produksi (seperti sewa ruko, gaji bulanan staf administrasi, biaya penyusutan mesin).
4. **Estimasi Unit Terjual (Opsional)**: Masukkan jumlah produk yang Anda targetkan atau perkirakan akan laku untuk mensimulasikan margin keuntungan.
5. Ketuk **Lihat Hasil Analisis**.

---

## 4. HALAMAN HASIL ANALISIS & SIMULASI HARGA JUAL

Halaman ini menyajikan laporan analisis mendalam berdasarkan input kalkulator HPP dan BEP.

### A. Rincian Laporan Keuangan:
1. **HPP Unit & Total**: Menampilkan biaya modal bersih per satu unit barang beserta akumulasi modal keseluruhan produksi.
2. **Margin Keuntungan per Unit**: Nilai rupiah keuntungan bersih per unit beserta persentase marginnya (misalnya: margin 20% menunjukkan keuntungan yang sehat).
3. **Harga Jual Saat Ini**: Harga jual yang Anda masukkan pada formulir sebelumnya.
4. **Analisis BEP (Break-Even Point)**:
   * **BEP (Unit)**: Jumlah minimal produk yang harus terjual agar bisnis Anda tidak rugi dan tidak untung (titik impas).
   * **BEP (Omzet)**: Total pendapatan kotor dalam rupiah yang harus dicapai untuk menyentuh titik impas.

### B. Fitur Simulasi Harga Jual (Slider Interaktif):
Aplikasi menyediakan slider interaktif di bagian bawah hasil analisis untuk memprediksi perubahan keuangan jika Anda mengubah harga jual produk.
* **Batas Kiri (Minimal)**: Adalah harga modal per unit (HPP per unit). Jika Anda menggeser slider ke batas kiri, margin Anda akan mendekati 0. BEP unit akan melonjak sangat tinggi karena keuntungan tipis. Jika mentok di batas minimal (margin = 0), BEP akan otomatis diset ke **0 Unit** oleh sistem untuk mencegah error matematika (division by zero).
* **Batas Kanan (Maksimal)**: Ditetapkan sebesar 3 kali lipat dari harga modal per unit. Menggeser slider ke kanan menaikkan harga jual target, meningkatkan margin keuntungan, dan memperkecil jumlah unit yang perlu dijual untuk balik modal.
* **Badge Kategori Keuntungan**: Di bawah slider, sistem akan memberikan label otomatis berdasarkan persentase margin:
  * **RUGI** (jika harga jual di bawah modal)
  * **KEUNTUNGAN RENDAH** (jika margin < 20%)
  * **KEUNTUNGAN SEDANG** (jika margin 20% - 50%)
  * **KEUNTUNGAN TINGGI** (jika margin > 50%)
* **Menyimpan Hasil**: Jika analisis sudah sesuai, ketuk tombol **Simpan** untuk menyimpan kalkulasi ke riwayat akun Anda.

---

## 5. FITUR RENCANA TABUNGAN (SAVINGS PLAN)

Tabungan bisnis sangat penting untuk ekspansi usaha atau dana darurat. Fitur ini membantu Anda melacak target tabungan.

### A. Membuat Rencana Tabungan Baru:
1. Ketuk tab kedua (ikon dompet `Wallet`) di navigasi bawah.
2. Ketuk tombol **Tambah Rencana** (ikon plus).
3. Isi informasi target tabungan:
   * **Nama Rencana**: Tujuan tabungan (misal: "Beli Oven Listrik Baru", "Sewa Ruko Tambahan").
   * **Target Dana**: Jumlah uang rupiah yang dibutuhkan.
   * **Saldo Awal**: Jumlah uang yang sudah terkumpul saat ini.
   * **Tenggat Waktu**: Tanggal target pencapaian tabungan.
4. Ketuk **Simpan Rencana**.

### B. Mengelola & Menabung:
1. Pada daftar rencana tabungan, ketuk salah satu rencana untuk membuka **Halaman Detail**.
2. Anda akan melihat persentase progress pencapaian (misal: "Dana Terkumpul 40%").
3. Ketuk tombol **Tabung Sekarang** untuk menambahkan nominal simpanan baru.
4. Ketuk tombol **Tarik Dana** jika Anda perlu mengambil dana dari tabungan tersebut untuk keperluan mendesak.
5. Setiap transaksi (simpan/tarik) akan tercatat rapi di riwayat riil tabungan tersebut.

---

## 6. FITUR INSIGHT & STATISTIK BISNIS

Akses statistik melalui tab keempat (ikon grafik naik `Show Chart`) di navigasi bawah untuk melihat performa bisnis jangka panjang.

### Grafik & Metrik yang Tersedia:
1. **Grafik HPP vs BEP**: Memvisualisasikan perbandingan tren HPP total produk dengan titik impas unitnya dari waktu ke waktu.
2. **Grafik Rencana Tabungan**: Menampilkan laju pertumbuhan akumulasi seluruh tabungan bisnis Anda.
3. **Analisis Efisiensi Biaya**: Menghitung skor kinerja efisiensi produksi berdasarkan perbandingan modal produksi dan profit yang dihasilkan.
4. **Analisis Produk Terpopuler**: Menampilkan produk mana yang menyumbang penjualan unit terbanyak berdasarkan data jumlah unit terjual bulanan.

---

## 7. FITUR RIWAYAT PERHITUNGAN (HISTORY)

Semua perhitungan HPP & BEP yang pernah Anda simpan akan masuk ke tab kelima (ikon sejarah `History`) di navigasi bawah.

### Fungsi di Halaman Riwayat:
1. **Daftar Perhitungan Terformat**: Menampilkan nama produk, tanggal perhitungan, total HPP, harga jual, margin, dan BEP Unit.
2. **Badge Peringatan Otomatis**:
   * Jika BEP Unit suatu produk dinilai terlalu tinggi (misal > 100 unit), sistem akan memunculkan badge merah **BEP Tinggi** sebagai sinyal agar Anda berhati-hati.
   * Jika BEP Unit dinilai aman dan margin keuntungan di atas 40%, sistem memunculkan badge hijau **Margin Sehat**.
3. **Hapus Riwayat**: Ketuk ikon tempat sampah di sudut kanan kartu riwayat untuk menghapus riwayat yang sudah tidak diperlukan.
4. **Ekspor Riwayat**: Fitur premium untuk mengunduh laporan keuangan perhitungan HPP & BEP ke perangkat Anda.

---

## 8. PENGATURAN PROFIL & KEANGGOTAAN PREMIUM

Pengaturan profil diakses dengan mengetuk ikon profil Anda di dashboard utama.

### A. Fitur Profil:
1. **Edit Profil**: Mengubah Nama Lengkap dan Foto Profil menggunakan tautan URL gambar.
2. **Informasi Akun**: Menampilkan detail email aktif dan tipe login yang digunakan (Google atau Email & Sandi).
3. **Dukungan (Support)**: Akses ke menu bantuan jika Anda mengalami masalah teknis atau bug pada aplikasi.
4. **Ganti Akun (Logout)**: Keluar dari akun saat ini dengan aman untuk banti ke akun lain.

### B. Keanggotaan Premium (Premium Membership) 👑:
Secara default, pengguna terdaftar sebagai **Pengguna Gratis (Free Member)**.
* **Batasan Free Member**: Pengguna gratis hanya diperbolehkan menyimpan maksimal **3 riwayat perhitungan HPP & BEP** di dalam database.
* **Keuntungan Premium Member**:
  * Penyimpanan riwayat perhitungan HPP & BEP tanpa batas (Unlimited).
  * Bebas dari batasan jumlah simpanan.
  * Fitur tambahan analisis mendalam eksklusif.
* **Cara Upgrade**: Masuk ke menu profil, pilih banner **Upgrade Premium**, lalu lakukan simulasi pembayaran hingga berhasil. Status keanggotaan Anda akan otomatis berubah menjadi **Premium Member 👑** dengan lencana mahkota emas di profil Anda.

---
*Dokumen ini dibuat secara otomatis sebagai panduan resmi aplikasi Finance Tracker Kelompok 4.*
