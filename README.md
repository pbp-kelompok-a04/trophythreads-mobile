# *TROPHY THREADS MOBILE*
Tautan APK &rarr; \
Design figma &rarr;
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

## Peran Pengguna Aplikasi

## Proses Integrasi
*Keperluan Aplikasi*
   - Aplikasi membutuhkan data user, produk, forum, dan informasi pertandingan yang disediakan oleh web. Kami menggunakan format data JSON sebagai komunikasi antar aplikasi dan server. Aplikasi akan menyesuaikan dengan endpoint yang sudah ada pada web yang sudah dibuat. 

*Menghubungkan Flutter dengan Django*
   - Aplikasi Flutter akan mengirim request ataupun post JSON ke server Django. Django pun akan memberikan respons dalam format JSON. 

*Validasi Endpoint & JSON dari Web*
   - Endpoint dan JSON yang diterima dari server akan divalidasi formatnya melalui aplikasi Postman dan dievaluasi apakah sudah bisa diintegrasikan dengan aplikasi. Penyesuaian model juga akan dibuat pada aplikasi berdasarkan format JSON yang diterima dari web melalui Quicktype untuk menghasilkan class custom dengan business logic yang sesuai dengan models pada Django.

*Konfigurasi UI*
   - UI akan dibuat sesuai dengan ketentuan dan dimensi aplikasi mobile. UI akan bersifat dinamis agar bisa menyesuaikan dengan ukuran mobile berbeda. M

*Deployment*
   - Melakukan Flutter deployment dan konfigurasi CI/CD menggunakan GitHub actions & Bitrise.