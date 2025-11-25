# COLOR

## Color Palette Utama
- #774C26  
- #A37B58  
- #FFE4BF  
- #FDF6F1  
- #FFFCF9  

## Background Color (All Page)
- #FDF6F1

## Warna Aksen (Dipakai Sangat Jarang)
Dipakai hanya pada elemen tertentu seperti small_card_level:
- #FFC300 (kuning emas)
- #FF495A (merah cerah)
- #8EE3EB (biru cerah)
- #73EF6A (hijau neon lembut)


# FONT

- **a. Maven Pro** → Heading utama / Logo text  
- **b. Quicksand** → Highlight, label kecil, nama fitur anak-anak  
- **c. Nunito** → Body text  


# GRID

## Mobile Grid System Guidelines

### Grid Structure
- **Columns:** 4  
- **Margin (Left/Right):** 16dp  
- **Gutter (Between Columns):** 16dp  
- **Safe Area:** Ikuti default safe area perangkat (iOS & Android)  
- **Platform:** Universal (Flutter, Android, iOS)

### Rationale
- Grid 4 kolom memberikan layout besar dan mudah dipahami anak-anak.  
- Margin dan gutter 16dp memastikan keseragaman dan readability.  
- Sangat kompatibel dengan layout Flutter.  

### Usage Rules
- Gunakan **2-column card layout** untuk halaman beranda dan daftar materi.  
- Semua interactive element harus memiliki **minimum touch target: 48dp**.  
- Seluruh UI harus align ke 4 kolom grid kecuali ilustrasi/dekorasi.  
- Jangan mengurangi margin atau gutter di bawah 16dp.  
- Untuk tablet, margin dapat ditingkatkan menjadi 20–24dp jika diperlukan.  

### Visual Example
