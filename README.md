# Mobile Kantin

Aplikasi Flutter demo untuk pengelolaan menu kantin dan transaksi kasir.

## Fitur
- Login demo untuk admin, kasir, dan customer.
- Dashboard ringkasan produk, transaksi, pendapatan, dan grafik pendapatan 7 hari.
- Admin dapat menambah/menghapus produk dan melihat transaksi.
- Kasir dapat membuat transaksi dari keranjang.
- Customer dapat mencari menu, memilih kategori, dan membuat pesanan.
- Data produk dan transaksi disimpan lokal menggunakan SharedPreferences.

## Menjalankan aplikasi
```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Akun demo:
- Admin: `admin` / `admin`
- Kasir: `kasir` / `kasir`
- Customer: `customer` / `customer`

## Catatan
Ini masih aplikasi demo. Akun disimpan langsung di source code, dan SharedPreferences hanya menyimpan data pada perangkat yang sama. Jangan gunakan untuk data sensitif atau transaksi produksi sebelum menambahkan autentikasi dan backend server.
