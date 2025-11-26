# *TROPHY THREADS MOBILE*
Tautan APK &rarr; \
Design figma &rarr; https://www.figma.com/design/PEssCNAbaWalAbCoNzPkmj/TrophyThreads?node-id=0-1&t=w2I8nZc6TkE6BZre-1 \
Timeline & Planning &rarr; https://docs.google.com/spreadsheets/d/1Xz-XjHQy6vWqbUHOe2V1ny_dZjjJ8BDWaOCkafkrsaE/edit?usp=sharing

## Nama Anggota Kelompok
- 2406435830 - Samuel Marcelino Tindaon
- 2406415116 - Giselle Julia Reyna
- 2406414076 - Amelia Juliawati
- 2406496214 - Febriyanti
- 2406496403 - Gusti Niera Fitri Alifa
- 2406353250 - Elsa Mayora Sidabutar
  
## Deskripsi Aplikasi
Trophy Threads adalah aplikasi yang dirancang untuk para penggemar sepak bola agar dapat mengikuti informasi pertandingan. Tidak hanya menyajikan jadwal dan hasil pertandingan, aplikasi ini juga memudahkan pengguna untuk membeli merchandise dari tim sepak bola favorit mereka dan penggunanya juga dapat mereview produk. Trophy Threads turut menyediakan ruang interaktif bagi komunitas penggemar sepak bola untuk berdiskusi dan berbagi pandangan seputar pertandingan. Melalui forum diskusi, pengguna dapat terhubung satu sama lain dan ikut berpartisipasi dalam percakapan seputar dunia sepak bola. Kehadiran Trophy Threads membawa pengalaman baru bagi para penggemar untuk mendukung tim favorit mereka dengan cara yang lebih interaktif dan menyenangkan.

## Daftar Modul
1. Modul Informasi Pertandingan (jadwal, hasil, forum diskusi) : Amelia Juliawati
- Tujuannya Menyajikan informasi pertandingan (tempat, jadwal, tim, dan hasil) yang akurat dan realtime untuk penggemar serta menghubungkan konten pertandingan dengan merchandise dan forum diskusi untuk penggemar.
- Fitur Utama:
  a. Create = Admin membuat jadwal pertandingan (tanggal, waktu, tempat, tim tuan/tamu, score akhir, dan jenis turnamen).
  b. Read = Match Detail (klik match): tanggal, waktu, tempat, tim tuan/tamu, score akhir, jenis turnamen, dan link ke forum diskusi.
  c. Update = Admin memperbarui status pertandingan yaitu skor akhir dan koreksi hasil.
  d. Delete = Untuk pertandingan yang dihapus karena duplikasi atau pembatalan, tampilkan alasan.
- Hak akses: Admin dan User
   
2. Modul Penjualan produk (merchandise) : Giselle Julia Reyna
- Tujuannya dimana seller akan membuat produk untuk dijual, menampilkan, dan serta memproses pembelian merchandise.
- Fitur Utama
  a. Create = Seller membuat/memposting suatu produk (merchandise).
  b. Read = menampilkan halaman detail produk (nama, harga, stok, deskripsi, rating) dari produk yang dibuat/dijual seller.
  c. Update = Seller dapat mengupdate detail (nama, harga, stok, deskripsi) dari produk yang dibuat.
  d. Delete = Seller dapat menghapus produk yang sudah dibuat dari halaman.
- Hak akses: Seller 
- Edge cases: Pembatalan & refund akan revert stok dan mengembalikan saldo ke user.
  
3. Modul Review Produk : Elsa Mayora Sidabutar
- Tujuannya memberi ruang bagi pembeli untuk memberi penilaian (rating) dan ulasan (review) terhadap merchandise tim.
- Fitur Utama
  a. Create = Aktif user (hanya yang pernah membeli produk) dapat membuat review: rating (1–5), deskripsi, dan tanggal pembelian (otomatis jika terhubung ke order).
  b. Read = Tampilan ringkasan serta sorting top positive / critical reviews.
  c. Update = Penulis review dapat mengedit review sendiri (tanpa batas waktu).
  d. Delete = User dapat menghapus review sendiri.
- Hak akses: User dan Seller
  
4. Modul forum diskusi : Samuel Marcelino Tindaon
- Tujuannya sebagai forum untuk diskusi umum dengan user lainnya mengenai topik seputar pertandingan, komunitas/fandom/general, thread, dan sebagainya yang dibagi menjadi dua jenis yaitu official forum (yang dibuat Admin) dan personal forum (yang dibuat user general).
- Fitur Utama
  a. Create = membuat forum baru atau berkomentar/reply ke forum diskusi user lain yang sudah ada.
  b. Read = menampilkan halaman forum diskusi suatu topik beserta semua komentar/replies yang ada, title masing-masing forum, nama publisher, isi postingan (foto [optional] dan description).
  c. Update = mengedit postingan ataupun komentar yang telah di posting ke forum.
  d. Delete = menghapus halaman forum diskusi ataupun komentar yang telah di posting.
- Hak akses: User, Admin
  
5. Modul keranjang : Gusti Niera Fitri Alifa
- Menyediakan tempat sementara untuk menampung item (merchandise) sebelum checkout dan untuk memfasilitasi perubahan kuantitas dan perhitungan harga. 
- Fitur Utama
  a. Create = Menambah item ke keranjang dan membuat pesanan
  b. Read = Menampilkan detail produk yang dimasukkan ke keranjang, informasi pengiriman, rincian pembayaran, dan metode pembayaran.
  c. Update = Mengubah kuantitas dari produk yang dipilih.
  d. Delete = Menghapus produk yang ada di keranjang
- Hak akses: User

6. Modul favorit (semacam Wishlist) : Febriyanti
- Tujuannya untuk menyimpan dan membuat halaman khusus yang menampilkan semua produk item yang disukai user.
- Fitur Utama
  a. Create = menambahkan produk item ke favorit.
  b. Read = menampilkan halaman yang isinya semua produk item di favorit.
  c. Update = mengupdate halaman dimana jika terjadi penambahan/penghapusan produk di favorit   
  d. Delete = hapus produk item dari favorit.
- Hak akses: User 
- Edge cases: Jika produk dihapus oleh seller, maka di halaman "Favorit" produk otomatis hilang atau tidak dapat ditemukan.

## Peran Pengguna Aplikasi
*User*
- Melakukan registrasi sebagai user untuk menggunakan Trophy Threads.
- Melihat informasi pertandingan dan merchandise berbagai timnas sepak bola.
- Membeli merchandise timnas sepak bola. 
- Menyimpan merchandise sebagai favorit.
- Menambahkan komentar pada forum ataupun ulasan pada review merchandise.

*Seller Official*
- Melakukan registrasi sebagai official merchandise seller untuk menggunakan Trophy Threads.
- Menambahkan, edit, dan delete merchandise.

*Admin*
- Melakukan registrasi sebagai admin untuk menggunakan Trophy Threads.
- Menambahkan, edit, dan delete informasi pertandingan sepak bola.
- Memantau aktivitas forum.

## Proses Integrasi
*Keperluan Aplikasi*
   - Aplikasi membutuhkan data user, produk, forum, dan informasi pertandingan yang disediakan oleh web. Kami menggunakan format data JSON sebagai bentuk data yang dikomunikasikan antar aplikasi dan server. Aplikasi akan menyesuaikan dengan endpoint yang sudah ada pada web yang sudah dibuat. 

*Menghubungkan Flutter dengan Django*
   - Aplikasi Flutter akan mengirim request ataupun post JSON ke server Django. Django pun akan menjalankan fungsi yang bersesuaian dengan memberikan respons dalam format JSON. 

*Validasi Endpoint & JSON dari Web*
   - Endpoint dan JSON yang diterima dari server akan divalidasi formatnya (bisa melalui aplikasi Postman) dan dievaluasi apakah sudah bisa diintegrasikan dengan aplikasi. Penyesuaian model juga akan dibuat pada aplikasi berdasarkan format JSON yang diterima dari web melalui Quicktype untuk menghasilkan class custom dengan business logic yang sesuai dengan models pada Django.

*Konfigurasi UI*
   - UI akan dibuat sesuai dengan ketentuan dan dimensi aplikasi mobile berdasarkan data JSON yang telah diterima. UI akan bersifat dinamis agar bisa menyesuaikan dengan ukuran mobile berbeda. 

*Deployment*
   - Melakukan Flutter deployment dan konfigurasi CI/CD menggunakan GitHub actions & Bitrise.
