# 🏠 Home Page UI Migration - PepakKids

## ✅ Yang Sudah Dikerjakan

### 1. **UI Baru Sesuai Desain Figma**

Implementasi UI baru dengan layout:
- ✅ Header card dengan avatar + level badge
- ✅ Hero card "Bermain Hewan" dengan ilustrasi placeholder
- ✅ Section "Pilih Level Mu Yuk"
- ✅ Level cards horizontal scroll (warna: blue, pink, purple rotation)
- ✅ Bottom navigation (Home, Trophy, History)

### 2. **Backend Logic Tetap Utuh** 🔒

**Tidak ada perubahan pada:**
- ✅ `_fetchLevels()` - Query Supabase tetap sama
- ✅ `_getTotalStars()` - Kalkulasi total bintang
- ✅ `_getCompletedLevels()` - Kalkulasi level selesai
- ✅ `_isLevelUnlocked(index)` - Logic unlock level
- ✅ `buildStars(earned)` - Render bintang
- ✅ `_openLevelDetail(level)` - Navigation ke detail
- ✅ Data structure & state management

### 3. **Color Palette (Temporary)**

```dart
class HomeColors {
  static const background = Color(0xFFF5F0E8);      // Cream background
  static const cardWhite = Colors.white;             // White cards
  static const levelBadge = Color(0xFFD4B896);       // Tan badge
  static const heroYellow = Color(0xFFFFF4D6);       // Yellow hero card
  static const heroText = Color(0xFF5D4E37);         // Brown text
  static const level1 = Color(0xFF5DADE2);           // Blue
  static const level2 = Color(0xFFF48FB1);           // Pink
  static const level3 = Color(0xFFAB7FE8);           // Purple
  static const textDark = Color(0xFF4A4A4A);         // Dark gray
  static const textGray = Color(0xFF9E9E9E);         // Light gray
  static const navBrown = Color(0xFF8B6F47);         // Brown nav
}
```

---

## 🎨 UI Components Baru

### **1. Header Card (`_buildNewHeader`)**
```dart
// Avatar + Name + Level Badge
Container(
  decoration: BoxDecoration(
    color: white,
    borderRadius: circular(50), // Pill shape
    boxShadow: [...]
  ),
  child: Row(
    children: [
      CircleAvatar(...),  // Avatar
      Text(userName),      // Name
      Container(lv.X),     // Level badge
    ],
  ),
)
```

**Data binding:**
- `userName`: Placeholder "Rasya Kunchh" (TODO: ambil dari user profile)
- `userLevel`: `_getCompletedLevels() + 1`

### **2. Hero Card (`_buildHeroCard`)**
```dart
Container(
  color: heroYellow,
  borderRadius: circular(25),
  child: Column(
    children: [
      Text("Bermain Hewan"),        // Title
      Text("Mulai Pelajaran..."),   // Subtitle
      Row(
        children: [
          Container("Mulai"),        // Button
          Container(illustration),   // Placeholder icon
        ],
      ),
    ],
  ),
)
```

**TODO:**
- Replace illustration placeholder dengan asset hewan
- Connect "Mulai" button ke first unlocked level

### **3. Level Section (`_buildLevelSection`)**
```dart
Column(
  children: [
    Text("Pilih Level Mu Yuk"),  // Section title
    ListView.builder(
      scrollDirection: horizontal,
      itemCount: _levels.length,
      itemBuilder: (context, index) {
        return _buildNewLevelCard(...);
      },
    ),
  ],
)
```

**Data binding:**
- `_levels`: Data dari Supabase
- `_isLevelUnlocked(index)`: Lock/unlock logic
- `level['star_earned']`: Bintang per level

### **4. Level Card (`_buildNewLevelCard`)**
```dart
Container(
  width: 160,
  color: colors[index % 3],  // Blue, Pink, Purple rotation
  borderRadius: circular(25),
  child: Column(
    children: [
      Text(level['urutan']),      // Big number
      Text(level['nama_level']),  // Level name
      buildStars(stars),          // Stars (if earned)
    ],
  ),
)
```

**Features:**
- Color rotation: Blue → Pink → Purple → Blue...
- Lock overlay untuk level terkunci
- Tap to open `LevelDetailPage`

### **5. Bottom Navigation (`_buildBottomNav`)**
```dart
Row(
  children: [
    Icon(home),      // Active
    Icon(trophy),    // Coming soon
    Icon(history),   // Coming soon
  ],
)
```

---

## 🔄 Migration Path

### **Old UI → New UI**

| Old Component | New Component | Status |
|--------------|---------------|--------|
| `_buildHeader()` | `_buildNewHeader()` | ✅ Replaced |
| `_buildLevelPath()` | `_buildLevelSection()` | ✅ Replaced |
| `_buildProgressBar()` | Removed | ✅ Not needed |
| `_buildLevelNode()` | `_buildNewLevelCard()` | ✅ Replaced |
| `_buildLevelCard()` | `_buildNewLevelCard()` | ✅ Replaced |
| Background image | Solid color | ✅ Changed |
| Zigzag layout | Horizontal scroll | ✅ Changed |

### **Backend Logic (Unchanged)**

```dart
// ✅ All preserved
_fetchLevels()
_getTotalStars()
_getCompletedLevels()
_isLevelUnlocked(index)
buildStars(earned)
_openLevelDetail(level)
```

---

## 📋 TODO List

### **Immediate (UI Polish)**
1. ✅ Basic layout implemented
2. ⏳ Replace illustration placeholder dengan asset hewan
3. ⏳ Connect "Mulai" button ke first unlocked level
4. ⏳ Get real user name dari Supabase profile
5. ⏳ Implement Trophy page navigation
6. ⏳ Implement History page navigation

### **Next Phase (Theme System)**
1. ⏳ Extract `HomeColors` ke `lib/theme/app_colors.dart`
2. ⏳ Create `AppTheme` class untuk global theme
3. ⏳ Standardize spacing constants
4. ⏳ Standardize typography
5. ⏳ Create reusable widget components

### **Future Enhancements**
1. ⏳ Add animations (fade in, slide, etc.)
2. ⏳ Add hero card carousel (multiple topics)
3. ⏳ Add achievement badges
4. ⏳ Add daily streak indicator
5. ⏳ Add loading skeleton screens

---

## 🚀 Testing

### **Test Scenarios**

1. **Loading State**
   - ✅ Shows CircularProgressIndicator
   - ✅ Centered on screen

2. **Empty State**
   - ⏳ TODO: Handle when `_levels` is empty

3. **Level Unlock Logic**
   - ✅ Level 1 always unlocked
   - ✅ Level N unlocked if Level N-1 has stars > 0
   - ✅ Locked levels show lock icon + gray overlay

4. **Navigation**
   - ✅ Tap level card → `LevelDetailPage`
   - ✅ Tap profile → `ProfilePage` (via old header, need to add)
   - ⏳ Tap trophy → Trophy page (coming soon)
   - ⏳ Tap history → History page (coming soon)

5. **Data Binding**
   - ✅ Level numbers from `level['urutan']`
   - ✅ Level names from `level['nama_level']`
   - ✅ Stars from `level['star_earned']`
   - ✅ User level from `_getCompletedLevels() + 1`

---

## 🎨 Design Notes

### **Spacing**
- Screen padding: 20px
- Card spacing: 20px vertical
- Level card margin: 16px right
- Section spacing: 30px

### **Border Radius**
- Header card: 50px (pill)
- Hero card: 25px
- Level card: 25px
- Button: 25px

### **Typography**
- Header name: 18px bold
- Hero title: 28px bold
- Hero subtitle: 14px regular
- Section title: 20px semi-bold
- Level number: 72px bold
- Level name: 16px semi-bold

### **Shadows**
- Cards: `blurRadius: 10, offset: (0, 4-6)`
- Buttons: `blurRadius: 8, offset: (0, 4)`

---

## 🔧 Code Structure

```
lib/pages/home.dart
├── HomeColors (temporary theme)
├── HomePage (StatefulWidget)
└── _HomePageState
    ├── 🔒 Backend Logic (unchanged)
    │   ├── _levels, _loading
    │   ├── _fetchLevels()
    │   ├── _getTotalStars()
    │   ├── _getCompletedLevels()
    │   ├── _isLevelUnlocked()
    │   ├── buildStars()
    │   └── _openLevelDetail()
    │
    ├── 🎨 New UI Components
    │   ├── build() - Main scaffold
    │   ├── _buildNewHeader()
    │   ├── _buildHeroCard()
    │   ├── _buildLevelSection()
    │   ├── _buildNewLevelCard()
    │   └── _buildBottomNav()
    │
    └── 🗑️ Old UI Components (deprecated)
        ├── _buildHeader()
        ├── _buildLevelPath()
        ├── _buildProgressBar()
        ├── _buildLevelNode()
        └── _buildLevelCard()
```

---

## ✅ Summary

**Completed:**
- ✅ UI baru sesuai desain Figma
- ✅ Backend logic 100% preserved
- ✅ Color palette temporary implemented
- ✅ Horizontal scroll level cards
- ✅ Bottom navigation structure
- ✅ Lock/unlock logic working

**Next Steps:**
1. Add real assets (hewan illustrations)
2. Connect "Mulai" button
3. Get user profile data
4. Implement Trophy & History pages
5. Extract theme to separate file

Home page UI migration selesai! 🎉
