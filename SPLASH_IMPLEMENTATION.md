# 🎨 Splash Screen Implementation - PepakKids

## ✅ Yang Sudah Dikerjakan

### 1. **Splash Screen Baru** (`lib/pages/splash.dart`)
Implementasi splash screen dengan animasi sesuai referensi:

**Animasi Sequence:**
- **0-500ms**: Delay awal dengan background cream solid
- **500-1700ms**: Circle putih zoom in dari tengah (scale 0 → 15x) - efek "memenuhi layar"
- **1500-2300ms**: Text "**Pepak**Kids" fade in
- **3500ms**: Navigate ke Login/Home dengan fade transition

**Fitur:**
- ✅ Background cream (#F5E6D3) solid di awal
- ✅ Circle putih zoom in effect (seperti transition wipe)
- ✅ Text dengan 2 warna: "Pepak" = coklat (#A97142), "Kids" = merah (#E74C3C)
- ✅ Smooth transitions menggunakan AnimationController
- ✅ Auto-check session: navigate ke HomePage jika sudah login, LoginPage jika belum
- ✅ Durasi total: ~3.5 detik (bisa disesuaikan)

### 2. **Main.dart Update**
Entry point aplikasi sekarang dimulai dari SplashScreen:

```dart
home: const SplashScreen(), // Dulu: LoginPage/HomePage
```

### 3. **Konsistensi Visual**
- Warna sesuai theme PepakKids (brown #A97142)
- Typography bold untuk branding
- Animasi smooth dan ramah anak

---

## 🎯 Cara Kerja

```
App Launch
    ↓
SplashScreen (4s animation)
    ↓
Check Supabase Session
    ├─ Session exists → HomePage
    └─ No session → LoginPage
```

---

## ⚙️ Customization

### Mengubah Durasi Splash
Edit di `lib/pages/splash.dart`:

```dart
// Total durasi = 300 + 500 + 400 + 2300 = 3500ms (3.5 detik)
await Future.delayed(const Duration(milliseconds: 2300)); // Ubah angka ini
```

### Mengubah Warna
```dart
// Background cream
color: const Color(0xFFF5E6D3), // Cream

// Text "Pepak"
color: Color(0xFFA97142), // Coklat

// Text "Kids"
color: Color(0xFFE74C3C), // Merah
```

### Mengubah Kecepatan Zoom Circle
```dart
end: 15.0, // Scale besar (15x) - ubah untuk zoom lebih cepat/lambat
```

### Mengubah Font Size
```dart
fontSize: 48, // Ukuran text "PepakKids"
```

---

## 🚀 Testing

Jalankan aplikasi:
```bash
flutter run
```

Kamu akan melihat:
1. Background cream muncul
2. Circle putih scale dari kecil ke besar (bounce)
3. Text "PepakKids" fade in
4. Background berubah ke white
5. Fade transition ke Login/Home

---

## 📝 Notes

- **Tidak ada asset image** - Semua menggunakan widget native Flutter
- **Performa optimal** - Animasi menggunakan AnimationController (hardware accelerated)
- **Responsive** - Otomatis menyesuaikan ukuran layar
- **Session aware** - Cerdas mendeteksi user sudah login atau belum

---

## 🎨 Referensi Visual

Implementasi ini mengikuti sequence animasi dari gambar referensi:
- **Frame 1**: Cream background solid
- **Frame 2-4**: Circle putih muncul dari tengah dan zoom in (scale besar)
- **Frame 5**: Circle memenuhi layar → background jadi putih
- **Frame 6-7**: Text "**Pepak**Kids" fade in (Pepak = coklat, Kids = merah)
- **Frame 8**: Fade transition ke Login/Home

---

## 🔧 Troubleshooting

**Jika splash terlalu cepat/lambat:**
- Sesuaikan delay di `_startAnimationSequence()`

**Jika warna tidak sesuai:**
- Cek `ColorTween` di `_backgroundAnimation`
- Cek `color` di Text widget

**Jika animasi patah-patah:**
- Pastikan device tidak dalam mode debug yang berat
- Test di release mode: `flutter run --release`

---

Selesai! Splash screen sudah terintegrasi dengan aplikasi PepakKids. 🎉
