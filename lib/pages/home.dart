import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'maqu.dart';
import 'profil.dart'; // 🔹 Tambahin import ProfilePage
import 'login.dart'; // 🔹 Pastikan ada halaman login

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _levels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLevels();
  }

  Future<void> _fetchLevels() async {
    setState(() {
      _loading = true;
    });

    try {
      // 🔹 Ambil data level dari Supabase
      final response = await supabase
          .from('level')
          .select('level_id, nama_level, urutan, kategori, deskripsi')
          .order('urutan', ascending: true);

      setState(() {
        _levels = response;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching levels: $e');
      setState(() {
        _loading = false;
      });
    }
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
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade200,
                      child: Text("${level['urutan']}"),
                    ),
                    title: Text(level['nama_level']),
                    subtitle: Text(
                      "Kategori: ${level['kategori'] ?? 'Umum'}",
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
  final dynamic level;

  const LevelDetailPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
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
            const Spacer(),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MateriQuizPage(levelId: level['level_id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text("📖 Lihat Materi & Quiz"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
