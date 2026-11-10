# Mobile Kantin

Aplikasi demo kasir kantin berbasis Flutter dengan arsitektur yang siap dikembangkan untuk koneksi real-time antar perangkat.

## Fitur utama
- Login demo admin / kasir / customer
- Dashboard statistik produk, transaksi, dan pendapatan
- Admin dapat menambah & melihat produk
- Kasir dapat membuat transaksi dan menerima pesanan dari customer
- Customer dapat memilih produk, menambahkan ke keranjang, dan mengirim pesanan ke kasir
- Data lokal tersimpan dengan SharedPreferences
- Koneksi Firestore sudah disiapkan untuk sinkronisasi multi-perangkat

## Struktur backend siap digunakan
Aplikasi ini sudah mencakup model `Order` dan `FirestoreService` untuk sinkronisasi status pesanan antar kasir dan customer. Untuk aktif digunakan di banyak perangkat, cukup isi file `lib/firebase_options.dart` dengan file konfigurasi Firebase yang benar dari FlutterFire.

## Menjalankan aplikasi
```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

## Akun demo
- Admin: `admin` / `admin`
- Kasir: `kasir` / `kasir`
- Customer: `customer` / `customer`

## Catatan penting
- `SharedPreferences` cocok untuk demo satu perangkat.
- Untuk koneksi real-time antar perangkat, aktifkan Firebase dan konfigurasi yang benar di `lib/firebase_options.dart`.
- Aplikasi tetap bisa dijalankan saat Firebase belum dikonfigurasi karena fallback lokal sudah dibuat.
