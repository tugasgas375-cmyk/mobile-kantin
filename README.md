# Mobile Kantin

Aplikasi kantin dan kasir sederhana berbasis Flutter dengan login multi-peran, pemesanan menu, kategori produk, dan ringkasan penjualan.

## Fitur
- Login demo untuk admin, kasir, dan customer.
- Dashboard dengan ringkasan produk/transaksi, grafik pendapatan 7 hari, serta akses sesuai peran.
- Admin dapat menambah produk dengan kategori, validasi input, menghapus produk dengan konfirmasi, dan melihat transaksi.
- Customer dapat mencari menu, memfilter berdasarkan kategori, mengatur keranjang, dan membuat pesanan.
- Kasir dapat membuat transaksi.
- Data produk dan transaksi disimpan secara lokal di perangkat menggunakan SharedPreferences.

## Menjalankan aplikasi
```bash
flutter pub get
flutter run
```

Akun demo (untuk pengembangan): `admin/admin`, `kasir/kasir`, `customer/customer`.

## Catatan
Aplikasi ini masih demo: akun ada di dalam kode dan data tersimpan di perangkat yang sama. Untuk penggunaan nyata, gunakan autentikasi dan backend/database server. Belum ada endpoint backend yang dikonfigurasi, sehingga transaksi tidak disinkronkan antarperangkat.
