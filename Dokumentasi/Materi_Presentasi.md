# Materi Presentasi Lengkap (Terintegrasi Laporan Teknis): My Movie List 🎬

Dokumen ini berisi materi *copy-paste* super lengkap yang diambil dari Laporan Teknis proyek. Anda dapat memasukkan poin-poin ini langsung ke dalam *slide* presentasi Anda (PowerPoint, Canva, Google Slides).

---

## SLIDE 1: Judul
**Teks Utama:** 
My Movie List

**Sub-judul:** 
Aplikasi Eksplorasi dan Manajemen Daftar Tontonan Film Terintegrasi API

**Penyusun:** 
1. Kailla Salsabila (2306064)
2. Aghniya Afiatul Jannah (2306035)

---

## SLIDE 2: Latar Belakang & Tujuan
**Judul Slide:** Pendahuluan & Latar Belakang
**Konten Slide:**
- **Latar Belakang:** Banyaknya film yang dirilis membuat pengguna kesulitan melacak rekomendasi film. Menyimpan judul di catatan lokal rentan hilang dan tidak memiliki informasi visual.
- **Tujuan Proyek:** Mengembangkan aplikasi mobile berbasis *cloud* untuk menjelajahi basis data film secara *real-time*, sekaligus bertindak sebagai "perpustakaan pribadi" untuk menandai film incaran (Wishlist), film selesai ditonton (Watched), dan dokumentasi ulasan pribadi (Review).

---

## SLIDE 3: Arsitektur & Teknologi (Tech Stack)
**Judul Slide:** Lingkungan Teknologi & Arsitektur
**Konten Slide:**
- **Arsitektur:** Mengusung *Monolithic Stateful Architecture* dengan pengelolaan UI berbasis `setState()` murni.
- **Bahasa & Framework:** Dart & Flutter (Mendukung pembuatan antarmuka responsif dan lintas *platform*).
- **Backend-as-a-Service (BaaS):** 
  - *Firebase Authentication*: Otentikasi keamanan akun (Email & Password).
  - *Firebase Cloud Firestore*: Database NoSQL yang berjalan seketika (*real-time*).
- **Penyedia Layanan API Eksternal:**
  - *The Movie Database (TMDB) API V3*: Pusat data utama film global.
  - *ImgBB API*: Konversi foto profil perangkat lokal menjadi tautan URL publik (hemat *storage*).

---

## SLIDE 4: Struktur Basis Data (Firebase NoSQL)
**Judul Slide:** Skema Database & Penyimpanan
**Konten Slide:**
- Desain *Database* difokuskan pada efisiensi. Aplikasi tidak menyimpan ribuan teks film di *cloud*, melainkan hanya menyimpan **ID Film**.
- **Koleksi `users`**: Menyimpan dokumen profil (UID, Nama, Email, URL Foto).
  - Sub-koleksi `wishlist`: Daftar ID film yang akan ditonton.
  - Sub-koleksi `watched`: Daftar ID film yang sudah ditonton.
- **Koleksi `movies`**:
  - Sub-koleksi `reviews`: Menyimpan rating (1-5 bintang) dan riwayat komentar teks setiap pengguna untuk film tersebut.

---

## SLIDE 5: Integrasi Endpoint API
**Judul Slide:** Endpoint API Eksternal (TMDB & ImgBB)
**Konten Slide:**
Aplikasi mengkonsumsi REST API tanpa perlu membangun server internal:
- **TMDB API (`/trending`, `/upcoming`, `/search`, `/genre`)**: Dilengkapi parameter `page` untuk menciptakan fitur *Infinite Scroll* (memuat 20 film per tarikan layar tanpa menghabiskan memori RAM).
- **TMDB Detail (`/movie/{id}/videos`)**: Mencari parameter bertipe *Trailer* dari *YouTube* untuk dieksekusi pemutarannya.
- **ImgBB API (`/upload`)**: Menerima injeksi *multipart/form-data* dari kamera/galeri, mengubah file `.jpg` menjadi *URL Server*.

---

## SLIDE 6: Fitur Utama Aplikasi
**Judul Slide:** Fitur Unggulan (Core Features)
**Konten Slide:**
1. **Keamanan Data Independen:** Profil dan koleksi setiap pengguna terkunci secara aman di UID Firebase masing-masing (tidak akan tercampur).
2. **Jelajah Film Tanpa Batas (*Infinite Scroll*):** Navigasi mulus ribuan film *Trending, Popular*, dan kategori *Genre*.
3. **Detail Tersentralisasi:** Halaman film memuat Sinopsis, *Cast* (Aktor Utama), dan tombol Play Trailer YouTube secara instan.
4. **My List & Interaksi Ulasan:** Modul koleksi (Wishlist/Watched) beserta sistem *Rating & Review* layaknya kritikus film.

---

## SLIDE 7: Solusi & Inovasi Teknis (Sangat Penting)
*(Slide ini memuat nilai jual utama dari kecerdasan algoritma kalian)*

**Judul Slide:** Pemecahan Masalah (Inovasi Sistem)
**Konten Slide:**
1. **Data Fallback Protocol (Anti Layar Rusak):** Jika TMDB gagal memberikan sinopsis dalam Bahasa Indonesia, algoritma aplikasi otomatis beralih memanggil API Bahasa Inggris (`en-US`) agar layar tidak pernah kosong.
2. **Kepatuhan Privasi OS Android 11+:** Penambahan eksplisit *Intent Queries* (`<queries>`) di dalam *AndroidManifest* untuk memastikan URL Trailer YouTube lolos verifikasi blokir keamanan Android versi terbaru.
3. **Retroactive Data Sync (Ulasan Cerdas):** Karena NoSQL bersifat statis, kami menanamkan algoritma di belakang layar: Saat pengguna mengubah Nama/Foto Profil, sistem otomatis menelusuri seluruh riwayat tontonan dan memperbarui data diri pada ulasan-ulasan lama secara seketika (*real-time*).

---

## SLIDE 8: Evaluasi Kekurangan Sistem
**Judul Slide:** Analisis Kekurangan Saat Ini (Cons)
**Konten Slide:**
- **Bottleneck Eksekusi Loop API:** Di halaman *My List*, aplikasi melempar *request* ke server TMDB satu per satu berdasarkan ID Firebase. Jika pengguna menyimpan 500 film, terjadi antrean 500 koneksi yang berpotensi memicu *Time Out* atau blokir jaringan.
- **Manajemen State Terpusat di UI:** Logika Firebase/API masih menempel langsung pada antarmuka (menggunakan `setState`), tidak menggunakan pola desain terpisah (seperti *Clean Architecture/BLoC*).

---

## SLIDE 9: Rencana Pengembangan Lanjutan
**Judul Slide:** Saran Pengembangan Masa Depan
**Konten Slide:**
1. **Implementasi State Management Global:** Beralih ke *Riverpod* atau *BLoC* agar kode logika (*Business Logic*) terpisah dari desain antarmuka (*UI Layer*).
2. **Sistem Offline Caching (Singgahan Lokal):** Memanfaatkan library `Hive` atau `SQflite` untuk menyimpan data film sementara agar fitur *My List* tetap bisa dibuka walaupun koneksi internet mati.
3. **Migrasi Aset Profil:** Beralih dari layanan gratis *ImgBB* ke *Firebase Storage* berbayar demi kendali kepemilikan aset yang lebih stabil dan aman.

---

## SLIDE 10: Pengujian Fungsionalitas (UAT Checklist)
*(Tampilkan tabel checklist atau bacakan dengan cepat bahwa semua lulus uji)*

**Judul Slide:** Skenario Pengujian (UAT Lulus)
**Konten Slide:**
✅ **Autentikasi:** Daftar & Login berfungsi sempurna (ditolak bila *password* salah).
✅ **Infinite Scroll:** 20 film tambahan termuat mulus saat *scroll* turun.
✅ **Pencarian:** Hasil dari mesin pencari sinkron dengan TMDB.
✅ **Pemutaran Trailer:** Berhasil menjebol limitasi Android 11 dan memutar video di YouTube.
✅ **Fallback Sinopsis:** Peralihan bahasa Indonesia ke Inggris otomatis sukses.
✅ **Koleksi (My List):** Tombol interaksi sukses merubah status data ke *Firebase*.
✅ **Ulasan & Profil:** Komentar tersimpan. Perubahan foto dan nama langsung sinkron ke ulasan masa lalu berkat algoritma retroaktif.

---

## SLIDE 11: Demonstrasi Langsung (Live Demo)
**Judul Slide:** Demo Aplikasi
**Teks (Opsional untuk pembicara):**
*(Buka Emulator / Layar HP)* 
"Mari kita mulai dari pembuatan akun baru, menjelajahi *Infinite Scroll* di halaman *Search*, mengeklik Trailer film, memasukkannya ke *Wishlist*, memberikan ulasan Bintang 5, dan terakhir mengubah foto profil untuk melihat sinkronisasi otomatis kami bekerja."

---

## SLIDE 12: Kesimpulan & Penutup
**Teks Utama:** 
Terima Kasih

**Sub-judul:** 
Sesi Tanya Jawab (Q&A) Dipersilakan.

**Informasi Bawah:** 
Source Code Tersedia: Repositori Pribadi [My Movie List].
