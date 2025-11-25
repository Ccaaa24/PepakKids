import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/profil.dart';
import '../pages/status.dart';
import '../widgets/small_level_card.dart';
import '../widgets/hero_category_card.dart';
import 'login.dart';
import 'choice.dart';

final supabase = Supabase.instance.client;

// Temporary color constants - akan dipindah ke theme file nanti
class HomeColors {
  static const background = Color(0xFFF5F0E8);
  static const cardWhite = Colors.white;
  static const levelBadge = Color(0xFFD4B896);
  static const heroYellow = Color(0xFFFFF4D6);
  static const heroText = Color(0xFF5D4E37);
  static const level1 = Color(0xFF5DADE2);
  static const level2 = Color(0xFFF48FB1);
  static const level3 = Color(0xFFAB7FE8);
  static const textDark = Color(0xFF4A4A4A);
  static const textGray = Color(0xFF9E9E9E);
  static const navBrown = Color(0xFF8B6F47);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _levels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLevels();
  }

  Future<void> _fetchLevels() async {
    setState(() => _loading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint("WARNING: User belum login, redirect ke login");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        return;
      }


      // Ambil data level + progress user (LEFT JOIN progress dengan filter user_id)
      final levelsResponse = await supabase
          .from('level')
          .select('level_id, nama_level, urutan, kategori, deskripsi, '
              'progress!left(user_id, star_earned)')
          .order('urutan', ascending: true);

      // Supabase balikin List<dynamic>, kita cast ke List<Map>
      final List<Map<String, dynamic>> levels =
          (levelsResponse as List).map((row) {
        // Filter progress hanya untuk user yang sedang login
        final progressList = (row['progress'] as List)
            .where((p) => p['user_id'] == userId)
            .toList();
        
        final progress = progressList.isNotEmpty
            ? progressList[0] as Map<String, dynamic>
            : null;
        
        final starEarned = progress != null ? (progress['star_earned'] as int? ?? 0) : 0;
        
        row['star_earned'] = starEarned;
        
        debugPrint("Level ${row['urutan']}: ${row['nama_level']} - Stars: $starEarned");
        
        return Map<String, dynamic>.from(row);
      }).toList();

      setState(() {
        _levels = levels;
        _loading = false;
      });
      
      debugPrint("Loaded ${levels.length} levels");
    } catch (e) {
      debugPrint('ERROR: Error fetching levels: $e');
      setState(() => _loading = false);
    }
  }

  Widget buildStars(int earned) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < earned ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  // ========================================
  // 🎨 NEW UI IMPLEMENTATION
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(HomeColors.navBrown),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNewHeader(),
                          const SizedBox(height: 20),
                          _buildHeroCard(),
                          const SizedBox(height: 30),
                          _buildLevelSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
            ),
    );
  }

  // ========================================
  // 🎨 NEW UI COMPONENTS
  // ========================================

  Widget _buildNewHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        final userName = snapshot.data?['nama'] ?? "User";
        final userLevel = _getCompletedLevels() + 1;
        final avatar = snapshot.data?['avatar'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: HomeColors.cardWhite,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HomeColors.textDark,
                    ),
                  ),
                ),
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: HomeColors.levelBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "lv.$userLevel",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('users')
          .select('nama, avatar')
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Widget _buildHeroCard() {
    // Tentukan kategori yang sedang aktif berdasarkan progress user
    final currentCategory = _getCurrentCategory();
    debugPrint('🎯 Current Category: $currentCategory');
    
    return HeroCategoryCard(
      category: currentCategory,
      onTap: () {
        // Cari level pertama dari kategori ini yang belum selesai
        final targetLevel = _getFirstIncompleteLevelOfCategory(currentCategory);
        if (targetLevel != null) {
          _openLevelDetail(targetLevel);
        }
      },
    );
  }

  // Helper: Dapatkan kategori yang sedang aktif
  String _getCurrentCategory() {
    // Cari level terakhir yang belum selesai sempurna (< 3 bintang)
    for (var level in _levels) {
      final stars = level['star_earned'] as int? ?? 0;
      if (stars < 3) {
        return level['kategori'] ?? 'Hewan';
      }
    }
    
    // Jika semua level sudah 3 bintang, return kategori terakhir
    if (_levels.isNotEmpty) {
      return _levels.last['kategori'] ?? 'Hewan';
    }
    
    return 'Hewan'; // Default
  }

  // Helper: Dapatkan level pertama yang belum selesai dari kategori tertentu
  Map<String, dynamic>? _getFirstIncompleteLevelOfCategory(String category) {
    for (var level in _levels) {
      final levelCategory = level['kategori'] ?? '';
      final stars = level['star_earned'] as int? ?? 0;
      final levelIndex = _levels.indexOf(level);
      final isUnlocked = _isLevelUnlocked(levelIndex);
      
      if (levelCategory.toLowerCase() == category.toLowerCase() && 
          stars < 3 && 
          isUnlocked) {
        return level;
      }
    }
    return null;
  }

  Widget _buildLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          "Pilih Level Mu Yuk",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: HomeColors.textGray,
          ),
        ),
        const SizedBox(height: 16),
        // Level scroll with snap - 1 level per page, show 2 levels
        SizedBox(
          height: 200,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(
              viewportFraction: 0.45, // Show 2 cards, scroll 1 at a time
              initialPage: 0,
            ),
            itemCount: _levels.length,
            itemBuilder: (context, index) {
              final level = _levels[index];
              final isUnlocked = _isLevelUnlocked(index);
              final stars = level['star_earned'] as int? ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildNewLevelCard(level, index, isUnlocked, stars),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewLevelCard(
    Map<String, dynamic> level,
    int index,
    bool isUnlocked,
    int stars,
  ) {
    return SmallLevelCard(
      level: level,
      index: index,
      isUnlocked: isUnlocked,
      stars: stars,
      onTap: () => _openLevelDetail(level),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, true, null),
          _buildNavItem(Icons.emoji_events, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatusPage()),
            );
          }),
          _buildNavItem(Icons.person, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap ?? () {
        if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon!")),
          );
        }
      },
      child: Icon(
        icon,
        size: 32,
        color: isActive ? HomeColors.navBrown : Colors.grey[400],
      ),
    );
  }

  // ========================================
  // 🗑️ OLD UI COMPONENTS (DEPRECATED)
  // ========================================

  // Header dengan stats seperti di gambar referensi
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Stats row (stars dan diamonds)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stars count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      _getTotalStars().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Profile button dengan logout shortcut
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Completed levels indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          _getCompletedLevels().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Profile/Logout button
                  Tooltip(
                    message: "Profil & Logout",
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Title dan subtitle
          const Text(
            "Petualangan mu",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Selesaikan level untuk membuka level selanjutnya",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Level path seperti di gambar referensi
  Widget _buildLevelPath() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(),
          const SizedBox(height: 30),
          
          // Level nodes
          ..._levels.asMap().entries.map((entry) {
            final index = entry.key;
            final level = entry.value;
            final isUnlocked = _isLevelUnlocked(index);
            final stars = level['star_earned'] as int? ?? 0;
            
            return _buildLevelNode(level, index, isUnlocked, stars);
          }).toList(),
        ],
      ),
    );
  }

  // Progress bar di atas
  Widget _buildProgressBar() {
    final completedLevels = _getCompletedLevels();
    final totalLevels = _levels.length;
    final progress = totalLevels > 0 ? completedLevels / totalLevels : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Level",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            Text(
              "$completedLevels/$totalLevels",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.amber],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Level node individual
  Widget _buildLevelNode(Map<String, dynamic> level, int index, bool isUnlocked, int stars) {
    final isEven = index % 2 == 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          if (isEven) ...[
            Expanded(flex: 2, child: Container()),
            Expanded(flex: 3, child: _buildLevelCard(level, index, isUnlocked, stars)),
          ] else ...[
            Expanded(flex: 3, child: _buildLevelCard(level, index, isUnlocked, stars)),
            Expanded(flex: 2, child: Container()),
          ],
        ],
      ),
    );
  }

  // Level card
  Widget _buildLevelCard(Map<String, dynamic> level, int index, bool isUnlocked, int stars) {
    return GestureDetector(
      onTap: isUnlocked ? () => _openLevelDetail(level) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked ? Colors.brown : Colors.grey,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Level number circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.brown : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        "${level['urutan']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Level name
            Text(
              level['nama_level'] ?? 'Level ${index + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.brown : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Stars
            if (isUnlocked) buildStars(stars),
          ],
        ),
      ),
    );
  }

  // Helper methods
  int _getTotalStars() {
    return _levels.fold<int>(0, (sum, level) {
      final stars = level['star_earned'] as int? ?? 0;
      return sum + stars;
    });
  }

  int _getCompletedLevels() {
    return _levels.where((level) {
      final stars = level['star_earned'] as int? ?? 0;
      return stars > 0;
    }).length;
  }

  bool _isLevelUnlocked(int index) {
    if (index == 0) return true; // Level pertama selalu terbuka
    
    // Level terbuka jika level sebelumnya punya minimal 1 bintang
    final previousLevel = _levels[index - 1];
    final stars = previousLevel['star_earned'] as int? ?? 0;
    return stars > 0;
  }

  // Open level detail - dipindah ke atas untuk menghindari error scope
  void _openLevelDetail(Map<String, dynamic> level) async {
    // Navigate dan tunggu result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelDetailPage(level: level),
      ),
    );
    
    // Refresh data jika ada perubahan
    if (result == true && mounted) {
      _fetchLevels();
    }
  }
}
