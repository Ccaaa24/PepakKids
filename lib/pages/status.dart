import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/level_info.dart';

final supabase = Supabase.instance.client;

// Status Page - Menampilkan history pembelajaran user
class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _levelProgress = [];
  Map<String, List<Map<String, dynamic>>> _groupedLevels = {};

  @override
  void initState() {
    super.initState();
    _fetchLevelProgress();
  }

  Future<void> _fetchLevelProgress() async {
    setState(() => _loading = true);
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('User not logged in');
        setState(() => _loading = false);
        return;
      }

      // Fetch all levels with user progress
      final levelsData = await supabase
          .from('level')
          .select('level_id, nama_level, urutan, kategori, progress!left(user_id, star_earned)')
          .order('urutan', ascending: true);

      // Process data
      final List<Map<String, dynamic>> processedLevels = [];
      
      for (var level in levelsData) {
        final progressList = (level['progress'] as List)
            .where((p) => p['user_id'] == userId)
            .toList();
        
        final stars = progressList.isNotEmpty 
            ? (progressList[0]['star_earned'] as int? ?? 0) 
            : 0;
        
        processedLevels.add({
          'level_id': level['level_id'],
          'nama_level': level['nama_level'],
          'urutan': level['urutan'],
          'kategori': level['kategori'] ?? 'Umum',
          'stars': stars,
        });
      }

      // Group by category
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var level in processedLevels) {
        final category = level['kategori'] as String;
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(level);
      }

      setState(() {
        _levelProgress = processedLevels;
        _groupedLevels = grouped;
        _loading = false;
      });

      debugPrint('Loaded ${processedLevels.length} levels in ${grouped.length} categories');
    } catch (e) {
      debugPrint('Error fetching level progress: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA97142)),
                      ),
                    )
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF5D4E37),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          // Title
          const Text(
            "History Pembelajaran",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4E37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_groupedLevels.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada data pembelajaran",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF8B6F47),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current progress section
          _buildCurrentProgressSection(),
          
          const SizedBox(height: 24),
          
          // Completed levels by category
          ..._groupedLevels.entries.map((entry) {
            return _buildCategorySection(entry.key, entry.value);
          }).toList(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentProgressSection() {
    // Find level yang sedang dikerjakan (belum 3 bintang)
    final currentLevel = _levelProgress.firstWhere(
      (level) => level['stars'] < 3,
      orElse: () => _levelProgress.isNotEmpty ? _levelProgress.last : {},
    );

    if (currentLevel.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge "Sedang berjalan"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFA97142),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Sedang berjalan",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Current level card
        LevelInfoCard(
          levelName: currentLevel['nama_level'] ?? 'Level',
          stars: currentLevel['stars'] ?? 0,
          onTap: () {
            // Optional: Navigate to level detail
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> levels) {
    // Filter hanya level yang sudah dikerjakan (stars > 0)
    final completedLevels = levels.where((level) => level['stars'] > 0).toList();
    
    if (completedLevels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFA97142),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Riwayat Selesai - $category",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Level cards
        ...completedLevels.map((level) {
          return LevelInfoCard(
            levelName: level['nama_level'] ?? 'Level',
            stars: level['stars'] ?? 0,
            onTap: () {
              // Optional: Navigate to level detail
            },
          );
        }).toList(),
        
        const SizedBox(height: 16),
      ],
    );
  }
}
