import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'maqu.dart';
import 'profil.dart';
import 'login.dart';

final supabase = Supabase.instance.client;

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
        debugPrint("⚠️ User belum login, redirect ke login");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        return;
      }

      // 🔹 Ambil data level + progress user (LEFT JOIN progress)
      final levelsResponse = await supabase
          .from('level')
          .select('level_id, nama_level, urutan, kategori, deskripsi, '
              'progress!left(user_id, star_earned)')
          .order('urutan', ascending: true);

      // Supabase balikin List<dynamic>, kita cast ke List<Map>
      final List<Map<String, dynamic>> levels =
          (levelsResponse as List).map((row) {
        final progress = (row['progress'] as List).isNotEmpty
            ? row['progress'][0] as Map<String, dynamic>
            : null;
        row['star_earned'] = progress != null ? progress['star_earned'] : 0;
        return Map<String, dynamic>.from(row);
      }).toList();

      setState(() {
        _levels = levels;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching levels: $e');
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

  void _openLevelDetail(dynamic level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelDetailPage(level: level),
      ),
    );
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PepakKids - Levels"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profil",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Log Out",
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final level = _levels[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade200,
                      child: Text("${level['urutan']}"),
                    ),
                    title: Text(level['nama_level']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kategori: ${level['kategori'] ?? 'Umum'}"),
                        buildStars(level['star_earned'] ?? 0), // ⭐ Progress
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _openLevelDetail(level),
                  ),
                );
              },
            ),
    );
  }
}

class LevelDetailPage extends StatelessWidget {
  final Map<String, dynamic> level;

  const LevelDetailPage({super.key, required this.level});

  Widget buildStars(int earned) {
    return Row(
      children: List.generate(3, (i) {
        return Icon(
          i < earned ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int star = level['star_earned'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(level['nama_level']),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level['nama_level'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("Kategori: ${level['kategori'] ?? 'Umum'}"),
            if (level['deskripsi'] != null) ...[
              const SizedBox(height: 10),
              Text(level['deskripsi']),
            ],
            const SizedBox(height: 20),
            const Text("Progress kamu:"),
            buildStars(star), // ⭐ Tampilkan bintang user
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MateriQuizPage(levelId: level['level_id']),
                    ),
                  );
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Lihat Materi & Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
