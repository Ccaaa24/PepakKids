import 'package:flutter/material.dart';
import 'package:pepakkids/pages/materi.dart';
import 'package:pepakkids/pages/quiz.dart';
import '../widgets/button_coklat.dart';

class LevelDetailPage extends StatelessWidget {
  final Map<String, dynamic> level;

  const LevelDetailPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final int star = level['star_earned'] as int? ?? 0;
    // Quiz hanya unlock jika mendapat 3 bintang (perfect score)
    final bool hasCompletedPerfectly = star >= 3;
    final String kategori = level['kategori'] ?? 'Umum';
    final String deskripsi = level['deskripsi'] ?? 'Mempelajari macam-macam buah buahan dalam bahasa jawa';
    
    // Debug: Print star info
    debugPrint("Choice Page - Level: ${level['nama_level']}, Stars: $star, Quiz Unlocked: $hasCompletedPerfectly");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Level Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Illustration placeholder
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4D6),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Level info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kategori,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D4E37),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  deskripsi,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Progress badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "${(star / 3 * 100).toInt()}%",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Mulai Belajar Button
                    ButtonCoklat(
                      text: "Mulai Belajar",
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MateriPage(levelId: level['level_id']),
                          ),
                        );
                        
                        // Return true ke home untuk trigger refresh
                        if (result == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      width: double.infinity,
                      height: 60,
                    ),

                    const SizedBox(height: 16),

                    // Quiz Button (locked/unlocked)
                    _buildQuizButton(context, hasCompletedPerfectly, star),

                    const SizedBox(height: 40),

                    // Note text - Dynamic based on stars
                    Text(
                      star == 0
                          ? "catatan : Quiz akan terbuka jika sudah\nmenyelesaikan kosa kata dengan sempurna (⭐⭐⭐)"
                          : star < 3
                              ? "catatan : Dapatkan 3 bintang untuk\nmembuka akses langsung ke Quiz"
                              : "catatan : Kamu sudah bisa langsung\nmengerjakan Quiz tanpa materi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: star >= 3 ? Colors.green[700] : Colors.grey[600],
                        height: 1.5,
                        fontWeight: star >= 3 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context, bool isUnlocked, int currentStars) {
    if (isUnlocked) {
      // Unlocked - dapat diklik, langsung ke quiz (hanya jika 3 bintang)
      return ButtonCoklat(
        text: "Quiz",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(
                levelId: level['level_id'],
              ),
            ),
          );
          
          // Return true ke home untuk trigger refresh
          if (result == true && context.mounted) {
            Navigator.pop(context, true);
          }
        },
        width: double.infinity,
        height: 60,
      );
    } else {
      // Locked - tidak dapat diklik, gunakan gambar locked button
      return GestureDetector(
        onTap: () {
          final message = currentStars == 0
              ? 'Selesaikan materi dan quiz dengan sempurna (⭐⭐⭐) untuk membuka akses langsung ke Quiz'
              : 'Dapatkan 3 bintang (⭐⭐⭐) untuk membuka akses langsung ke Quiz. Saat ini: ${_buildStarsText(currentStars)}';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/widgets/Locketbutton.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback jika gambar tidak ada
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Quiz",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.lock,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  String _buildStarsText(int stars) {
    return '⭐' * stars + '☆' * (3 - stars);
  }
}
