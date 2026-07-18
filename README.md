<div align="center">
  <img src="assets/images/logo.png" width="150" alt="My Movie List Logo">
  <h1>My Movie List 🎬</h1>
  <p><strong>Aplikasi Mobile Flutter Lintas-Platform dengan Integrasi TMDB API & Firebase Cloud Firestore</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-%5E3.11.0-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-AOT_Compiled-0175C2?logo=dart)](https://dart.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-NoSQL-FFCA28?logo=firebase)](https://firebase.google.com/)
  [![TMDB](https://img.shields.io/badge/TMDB-REST_API-01B4E4)](https://www.themoviedb.org/)
</div>

---

**My Movie List** adalah aplikasi *mobile* tingkat lanjut yang dirancang untuk membantu pengguna menjelajahi dunia sinema global secara *real-time*. Mengadopsi arsitektur *Monolithic Stateful* dan pola integrasi data *hybrid* (penggabungan data *cloud* dan *remote API*), aplikasi ini menyajikan pengalaman pengguna yang sangat responsif, hemat *bandwidth*, dan mulus (*seamless*).

Dibuat sebagai **Tugas Akhir Mata Kuliah Pemrograman Mobile (Institut Teknologi Garut - 2026)** oleh:
-  **Kailla Salsabila** (2306064)
-  **Aghniya Alifatul Jannah** (2306035)

---

## 📥 Unduh / Instalasi Cepat (APK)

Anda dapat langsung mencoba aplikasi ini di perangkat Android (Android 5.0+ hingga Android 14) dengan mengunduh berkas instalasi (`.apk`) yang telah dikompilasi secara *Ahead-of-Time* (AOT):

👉 **[Download Aplikasi (Google Drive) - Klik di Sini](https://drive.google.com/drive/folders/1B4GrtKEab-Mu6_MGSdZ_0GsK8ccVw8q9?usp=sharing)**

---

## ✨ Fitur & Rekayasa Perangkat Lunak Utama

Aplikasi ini tidak sekadar menampilkan data, tetapi mengimplementasikan standar rekayasa perangkat lunak modern:

- 🛡️ **Autentikasi Terenkripsi**: Login/Register berbasis Firebase Auth. Melindungi data kredensial dengan validasi lokal tingkat lanjut (`GlobalKey<FormState>`).
- ⚡ **Optimistic UI Rendering**: Penambahan film ke *Wishlist* atau *Watched* bereaksi dalam **0 detik**. *State* UI berubah secara lokal instan sebelum komunikasi jaringan (*Network I/O*) ke Firebase selesai dikonfirmasi.
- 📜 **Infinite Scrolling Engine**: Halaman *Trending, Popular*, dan *Search* menggunakan algoritma pendeteksi proksimitas piksel untuk mengunduh halaman API selanjutnya (`page=N+1`) tanpa perlu tombol muat ulang, lengkap dengan pelindung *state locking* anti-*spam*.
- 🗃️ **Arsitektur Database Anti-Redundan**: Dokumen pengguna di Firestore **tidak menyimpan salinan poster atau sinopsis**. Database murni hanya memegang `movieId` untuk mereduksi biaya *Document Reads*, lalu merakit *Futures Array* paralel (`Future.wait`) untuk menarik aset visual langsung dari server TMDB.
- 💬 **Sistem Ulasan (UGC) Real-Time**: Interaksi pengguna ditangkap melalui sub-koleksi spesifik (`movies/{movieId}/reviews`) dan ditampilkan seketika ke seluruh pengguna menggunakan *listener* `StreamBuilder`.
- 🖼️ **File to URL Piping**: Pengubahan foto profil menggunakan *ImagePicker* untuk membaca *Byte Array* di memori RAM, lalu merakit HTTP *Multipart-Request* ke ImgBB, menjauhkan basis data utama dari beban penyimpanan biner besar (Blob).
- 🎥 **Intent Sekuritas Android 11+**: Mendukung *Package Visibility SDK 30+* dengan manifest kueri khusus, agar *Trailer* YouTube bisa ditembakkan via *Intent Browser/App* tanpa diblokir sistem.

---

## 🛠️ Stack Teknologi

- **Framework Utama**: Flutter (Dart)
- **State Management**: Stateful Lifecycle API (*Prop-Drilling Pattern*)
- **Database Utama**: Firebase Cloud Firestore (NoSQL)
- **Infrastruktur API Eksternal**: 
  - TMDB v3 REST API (Katalog Data Film Luring)
  - ImgBB API v1 (Sistem Berkas Sementara)
- **Kompatibilitas**: Android (Tested SDK 21-34) & iOS

---

## 📸 Antarmuka Aplikasi (Slicing Figma)

> *(Catatan: Ganti teks di bawah ini dengan tautan gambar asli GitHub Repository Anda)*

| Home Dashboard | Search & Genre | Detail Film (Info) | My List (Wishlist) |
|:---:|:---:|:---:|:---:|
| ![Home](link_gambar_1) | ![Search](link_gambar_2) | ![Detail](link_gambar_3) | ![MyList](link_gambar_4) |

---

## 🚀 Panduan Kompilasi Mandiri (Development Build)

Bagi penguji atau kontributor yang ingin merakit aplikasi ini dari sumber aslinya:

### Prasyarat
- **Flutter SDK** versi `3.11.0` atau lebih tinggi terkonfigurasi.
- **Java JDK** dan **Android Build-Tools** (*toolchain* telah tervalidasi via `flutter doctor`).

### Instruksi Terminal
1. Kloning repositori ke mesin lokal:
   ```bash
   git clone https://github.com/aghniyaaj/my_movie_list.git
   cd my_movie_list
   ```
2. Resolusi seluruh *package* pihak ketiga:
   ```bash
   flutter pub get
   ```
3. Lakukan verifikasi statis memori dan logika (SCA):
   ```bash
   flutter analyze
   ```
4. Eksekusi aplikasi pada mode *Debug* JIT (*Just-in-Time*):
   ```bash
   flutter run
   ```

### 📦 Panduan Rilis Produksi (Production APK)

Kompilasi aplikasi ini memanfaatkan algoritma *Tree-Shaking* (penghapusan kelas sampah) dan *R8 Engine* dari Gradle untuk mengaburkan kode (*obfuscate*). Untuk menghasilkan APK:

```bash
flutter build apk --release
```
Hasil kompilasi akan ditelurkan pada lintasan absolut:
`/build/app/outputs/flutter-apk/app-release.apk`

---
*Didesain dan diprogram oleh Kelompok Aghniya & Kailla - ITG 2026.*
