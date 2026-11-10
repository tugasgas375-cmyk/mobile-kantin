# mobile-kantin

Aplikasi kasir sederhana berbasis Flutter untuk mengelola menu, transaksi, dan dashboard berdasarkan peran pengguna.

## Fitur utama
- Login multi-role: admin, kasir, customer
- Dashboard dengan ringkasan produk, transaksi, dan pendapatan
- Halaman admin untuk mengelola produk dan melihat riwayat transaksi
- Halaman kasir untuk membuat transaksi penjualan
- Halaman customer untuk melihat menu kantin
- Data produk dan transaksi tersimpan di perangkat menggunakan SharedPreferences

## Struktur aplikasi
- `lib/main.dart` - entry point dan login
- `lib/dashboard_page.dart` - dashboard utama setelah login
- `lib/admin_page.dart` - panel admin
- `lib/kasir_page.dart` - fitur kasir
- `lib/customer_page.dart` - menu pelanggan
- `lib/models.dart` - model data utama
- `lib/store.dart` - data global dan penyimpanan lokal

## Cara menjalankan
1. Pastikan Flutter sudah terinstal.
2. Jalankan:
   ```bash
   flutter pub get
   flutter run
   ```
3. Gunakan akun demo berikut:
   - admin / admin
   - kasir / kasir
   - customer / customer

## Catatan
Aplikasi ini masih bersifat demo dan cocok untuk pengembangan lanjutan, misalnya dengan backend API, autentikasi real, dan database yang lebih robust.
