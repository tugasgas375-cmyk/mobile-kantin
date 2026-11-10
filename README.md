# Mobile Kantin

Aplikasi kasir dan pemesanan kantin sederhana berbasis Flutter.

## Fitur
- Login demo dengan peran admin, kasir, dan customer.
- Dashboard ringkasan produk, transaksi, dan pendapatan.
- Admin dapat menambah/menghapus produk dengan validasi dan konfirmasi.
- Kasir dapat membuat transaksi dan melihat transaksi di riwayat admin.
- Customer dapat mencari menu, mengatur jumlah item di keranjang, lalu membuat pesanan.
- Data produk dan transaksi disimpan secara lokal di perangkat menggunakan SharedPreferences.

## Menjalankan aplikasi
Pastikan Flutter SDK terpasang, lalu jalankan:

```bash
flutter pub get
flutter run
```

Akun demo (untuk pengembangan):

| Peran | Username | Password |
|---|---|---|
| Admin | `admin` | `admin` |
| Kasir | `kasir` | `kasir` |
| Customer | `customer` | `customer` |

## Catatan
Aplikasi ini masih berupa demo: akun disimpan di kode dan data tersimpan di perangkat yang sama. Untuk penggunaan nyata, gunakan autentikasi dan backend/database server; SharedPreferences bukan database untuk data sensitif atau sinkronisasi multi-perangkat.
