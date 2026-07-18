# Naskah Presentasi Teknis Super Detail: My Movie List 🎬
*(Naskah lengkap penjabaran teknis per bab untuk 2 orang)*

*(Catatan: Naskah ini sangat padat dan mendalam. Anda dapat membaca ini sambil menunjuk ke dokumen Laporan Teknis atau Flowchart yang sedang ditampilkan di layar)*

---

### [PEMBUKAAN]
**Kailla:** 
"Selamat pagi Bapak/Ibu Dosen Penguji dan rekan-rekan mahasiswa sekalian. Kami dari tim pengembang yang beranggotakan saya sendiri, Kailla Salsabila, dan rekan saya Aghniya Afiatul Jannah."

**Aghniya:** 
"Pada kesempatan hari ini, kami akan membedah anatomi teknis dari aplikasi yang telah kami kembangkan berjudul **My Movie List**. Aplikasi ini adalah *platform mobile* lintas sistem operasi (Android dan iOS) yang berfungsi sebagai penjelajah basis data film secara *real-time* sekaligus perpustakaan digital pribadi bagi penggunanya."

---

### [BAB 1: PENDAHULUAN & LATAR BELAKANG]
**Kailla:** 
"Mari kita bedah mulai dari **Bab 1**. Latar belakang pembuatan aplikasi ini berangkat dari perilaku pengguna modern yang sering kebingungan melacak rekomendasi tontonan. Kita sering melihat *trailer* di internet, tapi besoknya sudah lupa judulnya. Jika hanya dicatat di aplikasi *Notes* biasa, catatannya tidak punya gambar, tidak punya sinopsis, dan rentan hilang jika HP di-reset."

**Aghniya:** 
"Oleh karena itu, tujuan proyek ini adalah menciptakan solusi *All-in-One*. Aplikasi kami bukan hanya menarik ribuan data film populer dunia ke genggaman tangan, tapi juga memberikan fitur otentikasi di mana pengguna punya ruang *Cloud* pribadi. Mereka bisa menandai film yang ingin ditonton (*Wishlist*), film yang sudah beres ditonton (*Watched*), dan bertindak layaknya kritikus film dengan memberikan bintang dan komentar."

---

### [BAB 2: ARSITEKTUR & TEKNOLOGI (TECH STACK)]
**Kailla:** 
"Pada Bab 2, kami menjelaskan fondasi arsitektur proyek. Aplikasi ini dikembangkan menggunakan kerangka kerja Flutter dengan pendekatan **Monolithic Stateful Architecture**. Pembaruan antarmuka (UI) dikendalikan secara langsung melalui siklus hidup *StatefulWidget* menggunakan fungsi `setState()`. Kami tidak mengimplementasikan *state management* eksternal seperti BLoC atau Provider. Oleh karena itu, aliran data dikelola secara murni melalui *prop-drilling* dari widget parent ke child."

**Aghniya:** 
"Untuk menjaga struktur kode tetap rapi (*Clean Code*), kami memisahkan direktori di dalam folder `lib/` menjadi empat modul utama:
1. **Folder `core/`**: Menyimpan konfigurasi statis seperti palet warna (`AppColors`) dan kredensial API (`AppConstants`).
2. **Folder `models/`**: Berisi kelas representasi data (*Data Class*) untuk menerjemahkan respons JSON dari API menjadi objek Dart.
3. **Folder `screens/`**: Menyimpan seluruh kodingan visual antarmuka untuk 12 halaman aplikasi.
4. **Folder `services/`**: Menyimpan logika komunikasi eksternal. Terdapat `api_service` untuk koneksi REST API TMDB, `firebase_service` untuk CRUD Firestore, dan `imgbb_service` untuk proses *upload* gambar."

**Kailla:** 
"Sedangkan pada file konfigurasi `pubspec.yaml`, manajemen dependensi diatur seefisien mungkin. Selain komponen inti Firebase (*firebase_core, firebase_auth, cloud_firestore*), kami hanya menggunakan tiga pustaka tambahan utama:
- `http` untuk mengirim *HTTP request* ke API eksternal.
- `image_picker` untuk mengambil *input* foto dari galeri lokal pengguna.
- `url_launcher` untuk menembus *intent* sistem operasi Android, sehingga aplikasi dapat membuka eksekusi URL eksternal, seperti memutar video *trailer* melalui YouTube."

---

### [BAB 3: DESAIN STRUKTUR DATA DAN BASIS DATA]

**Kailla:** 
"Pada Bab 3, kami mendemonstrasikan rancangan struktur data yang terbagi menjadi tiga sub-bab utama. Dimulai dari **Sub-bab 3.1: Skema Entity-Relationship**."

"Firebase Cloud Firestore beroperasi sebagai basis data NoSQL. Oleh karena itu, kami merancang skema relasional menggunakan hierarki *Collection, Document*, dan *Sub-Collection*. Skema utama aplikasi ini terdiri dari entitas `USERS` yang memiliki relasi *one-to-many* dengan `WISHLIST` dan `WATCHED`. Di sisi lain, entitas `MOVIES` memiliki relasi *one-to-many* dengan entitas `REVIEWS`."

**Aghniya:** 
"Selanjutnya pada **Sub-bab 3.2: Penjelasan Entitas Database**, kami membagi struktur penyimpanan menjadi dua koleksi akar (*root collections*)."

"Koleksi pertama adalah `users`. ID Dokumen pada koleksi ini disinkronkan murni dengan *UID Autentikasi Firebase*. Koleksi ini menampung variabel *String* nama, email, dan URL foto profil. Di dalamnya terdapat dua sub-koleksi, yaitu `wishlist` dan `watched`. Untuk optimalisasi ruang *Firestore*, sub-koleksi ini murni hanya merekam parameter `movieId` bertipe *String* dan `addedAt` bertipe *Timestamp*. Metadata tekstual film tidak disimpan secara lokal."

**Kailla:** 
"Koleksi akar kedua adalah `movies`, yang dirancang spesifik sebagai kontainer interaksi ulasan. Setiap film yang diulas akan memicu pembuatan dokumen berdasarkan ID film tersebut. Dokumen ini membawahi sub-koleksi `reviews`, yang berisi atribut `userId` (sebagai penanda *Foreign Key*), parameter foto profil, angka `rating` berskala 1-5, teks `review`, dan waktu publikasi."

**Aghniya:** 
"Beralih ke **Sub-bab 3.3: Dokumentasi Endpoint API Eksternal**, aplikasi bergantung pada dua penyedia layanan REST API utama untuk menutupi kebutuhan data visual."

"Layanan pertama adalah **TMDB API (versi 3)**. Kami mengeksekusi *HTTP GET request* ke beberapa endpoint vital:
- `/trending`, `/movie/popular`, dan `/movie/upcoming` untuk merender daftar objek film secara dinamis menggunakan parameter `page` guna mendukung fungsionalitas *infinite scroll*.
- `/search/movie` untuk kueri *full-text search*.
- `/movie/{id}` untuk membedah rincian spesifikasi durasi dan genre.
- Serta `/movie/{id}/videos` yang algoritmanya dirancang untuk menyeleksi objek bertipe 'Trailer' dan mengekstrak kunci video YouTube."

**Kailla:** 
"Layanan API kedua adalah **ImgBB API**. Kami menggunakan rute `/upload` dengan protokol *HTTP POST*. Algoritma menangkap *file* gambar dari galeri perangkat lalu membungkusnya ke dalam *payload multipart/form-data*. Begitu berhasil diunggah, server mengembalikan respon JSON berisi *Display URL* publik. URL teks inilah yang kami simpan ke *Firestore*, sehingga membebaskan aplikasi dari manajemen kapasitas *bandwidth cloud* bawaan."

---

### [BAB 4: ALUR KERJA SISTEM (FLOWCHART LOGIKA)]

**Kailla:** 
"Pada Bab 4, kami mendokumentasikan enam alur logika sistem yang mengatur seluruh manajemen data antarmuka dan *backend*. Kita mulai dari **Sub-bab 4.1: Flowchart Autentikasi**."

"Sistem autentikasi mengimplementasikan logika *session bypass*. Pada modul inisialisasi awal (*Splash Screen*), eksekusi `FirebaseAuth.instance.currentUser` dijalankan. Jika mengembalikan nilai *null*, sistem merutekan navigasi pengguna secara absolut ke `LoginScreen`. Sebaliknya, jika terdeteksi *token* sesi yang valid, *routing* akan melompati alur masuk manual dan melempar *state* langsung ke `MainNavigation`."

**Aghniya:** 
"Pada **Sub-bab 4.2: Alur Interaksi Klien & API Eksternal**, kami membatasi risiko luapan memori (Memory Overflow) melalui algoritma *Infinite Scroll*. Pemanggilan inisialisasi tahap awal dibatasi secara ketat pada parameter `page=1`. TMDB membalas muatan dengan kuota mutlak 20 *item* objek JSON."

"Pada lapisan antarmuka, objek `ScrollController` bertugas mendeteksi sisa ruang matriks di layar. Saat ambang batas terlampaui—yakni pada titik 200 piksel sebelum limit bawah batas rendering gawai tercapai—siklus asinkron `_fetchMoreMovies()` dieksekusi. Parameter indeks `page` berinkrementasi +1, menembakkan *HTTP GET Request* baru, lalu merender (*push*) 20 elemen objek *Movie* baru ke lapisan data visual tanpa melakukan muat ulang *state* global."

**Kailla:** 
"Memasuki **Sub-bab 4.3: Flowchart Interaksi Film (Wishlist & Watched)**. Manipulasi penambahan daftar diformulasikan menggunakan pola operasi asinkron yang terikat dengan pembaruan layar optimis (*optimistic UI rendering*)."

"Begitu antarmuka Detail Film memuat ulang nilainya, *StreamBuilder* melakukan interogasi status ke sub-koleksi spesifik pengguna di Firestore. Jika ditemukan parameter dokumen ID yang identik, variabel direpresentasikan menjadi *True* (berwujud *Checked*). Event penekanan layar akan memicu salah satu operasi referensi dokumen Firebase secara langsung: eksekusi referensi `delete()` untuk pembatalan penandaan daftar, atau referensi `set()` yang membawakan *payload* objek waktu (Timestamp) spesifik."

**Aghniya:** 
"Berlanjut ke **Sub-bab 4.4: Flowchart Fitur Pembuatan Ulasan**. Fungsionalitas manajemen *User Generated Content* ini memiliki lapisan filter kondisional (*conditional rendering*) di sisi tampilan (*front-end*)."

"Bilah *Slider RatingBar* berskala 1-5 beserta form masukan teks dilarang merender visual ke kanvas layar kecuali jika properti validasi bawaan halaman `_isWatched` bernilai *True*. Hal ini memastikan sistem memblokir tindakan ulasan *spam* dari entitas ghaib di mana hanya subjek yang telah memiliki jejak rekaman di Firebase yang berhak meluncurkan delegasi eksekusi kepada *API Service*, tepatnya memicu konstruksi *payload Map String-Dynamic* disalurkan ke rute referensial: `movies/{movieId}/reviews`."

**Kailla:** 
"Selanjutnya pada **Sub-bab 4.5: Diagram Pengubahan Foto Profil**, kami mengkoreografikan serah terima antar tiga layanan: sistem operasi Android lokal, server API pihak ketiga ImgBB, dan pembaruan kolom *database* Firestore."

"Perintah tombol mengeksekusi kelas internal `ImagePicker` dari peramban OS lokal guna menculik spesifik memori letak gambar (*File Bytes*). Berkas utuh ini dilayangkan via modul komunikasi protokol HTTP *POST multipart/form-data* langsung menuju gerbang batas jaringan server ImgBB. Respon balasan diekstrak ke ranah URL string publik saja (*display_url*), dimana rujukan karakter string inilah yang ditambalkan masuk (*patch overwrite*) menumpuk ke entitas akun di Firestore agar profil terhindar dari kelesuan sinkronisasi silang perangkat di waktu yang bersamaan."

**Aghniya:** 
"Terakhir pada **Sub-bab 4.6: Flowchart Sinkronisasi Data 'My List'**, kerangka pemrosesan sistem disimulasikan menggunakan interogasi pembacaan memori data campuran."

"Saat tumpukan antarmuka menerima panah sinyal aliran (*event stream*) dari rujukan Firebase berupa deretan teks statis sub-koleksi `wishlist`, klien layar otomatis mengalami kelumpuhan data poster film. Solusi sistem kami ialah mendaulat logika loop asinkron (*for-looping request*) atas seluruh parameter ID dokumen tadi, merangkapkannya ke dalam matriks asinkron paralel `Future.wait()`, kemudian mengorkestrasi tembakan tembakan ganda `getMovieDetails(id)` ke pangkalan server TMDB hanya dalam per sekian milidetik, demi menginjeksikan properti poster visual baru tanpa sedikitpun harus mencuri jatah limitasi kuota ukuran memori asli Firebase."

---

### [BAB 5: DOKUMENTASI TERPERINCI BERDASARKAN HALAMAN (UI/UX)]

**Kailla:** 
"Beralih ke Bab 5, kami akan membedah anatomi teknis dari tujuh modul halaman utama aplikasi. Dimulai dengan **Sub-bab 5.1: Splash Screen**. Halaman ini berfungsi sebagai jembatan visual sekaligus penahan *state* asinkron. Kami menggunakan fungsi `Future.delayed` dengan injeksi kondisional `if (!mounted) return;` pasca eksekusi agar aplikasi kebal dari kebocoran memori apabila pengguna mengecilkan layar secara tiba-tiba."

"Pada **Sub-bab 5.2: Modul Autentikasi**, antarmuka disematkan kumpulan `TextFormField` dengan validasi bawaan. Logika kontroler berujung pada pemanggilan asinkron `signInWithEmailAndPassword` dan `createUserWithEmailAndPassword`. Khusus pada jalur pendaftaran, sistem otomatis mengeksekusi instruksi primitif `doc(uid).set()` agar penampung profil JSON mentah langsung terbentuk di Firestore."

**Aghniya:** 
"Pada **Sub-bab 5.3: Home Screen**, halaman diikat dengan kontroler *rendering* asinkron `FutureBuilder`. Apabila `connectionState` sedang `waiting`, UI terkunci pada instansiasi siklikal `CircularProgressIndicator`. Pencetakan visual terbagi dua entitas besar: *Banner Carousel* berbasis matriks `ClipRRect` yang disiram modifikasi gradien `ShaderMask` transparan, serta *ListView horizontal* murni yang menyandikan tata letak memanjang sumbu X."

"Pada **Sub-bab 5.4: Fitur Ekosistem Pencarian**, antarmuka bersikap pasif hingga nilai masuk. Saat kueri kosong, UI memaparkan *Grid Wrap* tag genre. Saat blok kueri ditekan via detektor `onSubmitted`, parameter antrean halaman di-reset ke nilai 1 dan modul delegasi fungsi `searchMovies` dioperasikan ke hulu TMDB."

**Kailla:** 
"Pada **Sub-bab 5.5: Halaman Detail Film**, arsitektur sistem memproses relasi ganda dan penyaringan status (*optimistic UI rendering*). Status Boolean `_isWatched` dan `_isWishlist` ditransmisikan secara kontinu. Ekstraksi visual kunci `YouTube Video Key` disuntikkan secara dinamis ke string URL terenkripsi dan dipicu ke protokol penjelajah eksternal gawai menggunakan kelas jembatan *url_launcher*. Sistem UI juga menyiagakan instruksi perlindungan (*Fallback errorBuilder*) apabila muatan string posterPath mengalami anomali *null* dari API TMDB."

"Untuk **Sub-bab 5.6: Halaman Koleksi Saya**, *piping* (saluran perpindahan) data diatur murni secara paralel via perakitan `StreamBuilder` ke `Future.wait`. Karena Firestore dikonfigurasi anti-redundan dan hanya mengembalikan array referensi ID, aplikasi mengkonversinya seketika menjadi gelombang permohonan *HTTP GET* multi-koneksi ke pangkalan data TMDB demi memanifestasikan lapisan poster penuh pada wilayah tab (*TabBarView*)."

**Aghniya:** 
"Terakhir pada **Sub-bab 5.7: Manajemen Akun**, kerangka manipulasi interaksi lokal direpresentasikan. Eksekusi `ImagePicker` membongkar subsistem kamera/galeri lalu memulangkan nilai lintasan ruang simpan (*File Bytes*). Objek *Binary* dilesatkan via POST ke server *ImgBB*. Setelah pengembalian URL string final disahkan, fungsi `update({'profilePic'})` mengkoreksi kolom Firestore lama secara ditimpa penuh (*overwrite*)."

---

### [BAB 6: PROSEDUR INSTALASI, BUILD, DAN DEPLOYMENT]

**Kailla:** 
"Memasuki Bab 6. Prosedur rilis dan pengembangan mematuhi standar validasi kerangka kerja Android/iOS hibrida. Berdasarkan **Sub-bab 6.1 dan 6.2**, kesiapan lingkungan membutuhkan pengesahan `flutter doctor -v` nir-galat, disusul pemompaan modul dependensi sekunder melalui komando CLI `flutter pub get`. Standar stabilitas dikontrol statis via `flutter analyze` hingga titik temuan galat *Zero Issue* tercapai."

**Aghniya:** 
"Pada **Sub-bab 6.3: Kompilasi Sistem Produksi**, paket distribusi peranti lunak dikompilasi ke wujud akhir biner melewati perintah mutlak `flutter build apk --release`. Parameter kompresi ini memaksa kompiler Dart beralih total ke mode *Ahead-of-Time* (AOT). Algoritma pengikisan kode mati (*Tree-Shaking*) diaktifkan penuh, dan memori pelacakan jejak instruksi `debugPrint` dimusnahkan. Hasil keluarannya adalah file berformat *Android Package* (APK) terkompresi rapat siap pasang."

---

### [BAB 7: SKENARIO PENGUJIAN KUALITAS (UAT)]

**Kailla:** 
"Di Bab 7, kami menyerahkan serangkaian batas operasional modul program ke dalam matriks *User Acceptance Testing*. Keseluruhan uji kasus pengetesan parameter sukses disahkan tanpa interupsi kegagalan memori (*Zero Crash*)."

"Evaluasi berfokus kepada unjuk keandalan detektor autentikasi saat diprovokasi input kosong, persistensi rendering *Infinite Scroll*, sensitivitas hasil penelusuran leksikal TMDB API, adaptabilitas *url_launcher* untuk menjebol regulasi restriksi perlindungan intent *OS Android 11+*, kehandalan *defensive programming* saat menginjeksi bahasa Inggris pengganti pada sinopsis Indonesia bernilai *null*, hingga kesinkronan radikal penggantian foto profil akun induk merambah ke sulur-sulur komponen riwayat komentar tempo lampau."

---

### [BAB 8: ANALISIS DAN KESIMPULAN TEKNIS]

**Aghniya:** 
"Sebagai penutup di Bab 8, perkenankan kami membawakan kesimpulan dan analisis evaluasi operasional menyeluruh. Berdasarkan indikator **Sub-bab 8.1 (Kelebihan Sistem)**, instrumen *Data Fallback Protocol* untuk mitigasi respon anomali string TMDB, manipulasi injeksi XML *`<queries>` Android Manifest*, dan pencegahan limitasi *CPU Memory* melalui kalkulasi titik *scroll listener* adalah penanda kualitas utama arsitektur ini."

"Kendati demikian, dalam observasi **Sub-bab 8.2 (Kekurangan Arsitektur)**, rancangan sirkulasi *state* mendapati defisit struktural laten. Iterasi *for-loop* rekursif pada halaman Koleksi (My List) adalah beban bawaan berisiko tinggi (*Bottleneck Network*) apabila beban kuota entitas *bookmark* menumpuk. Ditambah lagi, sentralisasi rantai interaksi layanan *(Firebase Service)* yang terlalu lekat tertanam pada kanvas tampilan *(StatefulWidget GUI)* memotong prinsip skalabilitas *Clean Architecture*."

**Kailla:** 
"Oleh karena masalah tersebut, di dalam kerangka kerja **Sub-bab 8.3 (Saran Pengembangan Berkelanjutan)**, kami merekomendasikan transisi modifikasi kode yang mendasar:
Pertama, refaktorisasi hierarki manajemen data menuju kaidah murni penyedia absolut lintas komponen layaknya kerangka *BLoC* (*Business Logic Component*). 
Kedua, menginjeksi sistem *Offline Layer Caching Database* biner luring sekelas pustaka *Hive* demi mengatasi interogasi data eksternal berkepanjangan pada daftar panjang.
Ketiga, penganuliran layanan pihak ketiga *ImgBB* menuju integrasi totalitas ruang *Firebase Storage Cloud* demi keutuhan kontrol lalu lintas paket secara internal."

"Demikian perincian utuh arsitektur peranti lunak aplikasi *My Movie List*. Kami persilakan seluruh jajaran penilai untuk mengarahkan pandangannya menuju visual perangkat *Live Demo* untuk validasi silang fungsionalitas sistem. Sesi penjelasan teknis dengan ini kami nyatakan selesai."
