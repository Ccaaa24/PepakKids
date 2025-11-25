import 'package:flutter/material.dart';

// Level Info Card Widget - Menampilkan info level dengan bintang
class LevelInfoCard extends StatelessWidget {
  final String levelName;
  final int stars; // 0-3 bintang
  final VoidCallback? onTap;

  const LevelInfoCard({
    super.key,
    required this.levelName,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna berdasarkan bintang
    Color statusColor;
    if (stars >= 3) {
      statusColor = const Color(0xFF4CAF50); // Hijau - Perfect
    } else if (stars >= 2) {
      statusColor = const Color(0xFFFFC107); // Kuning - Good
    } else if (stars >= 1) {
      statusColor = const Color(0xFFFF9800); // Orange - OK
    } else {
      statusColor = Colors.grey; // Abu-abu - Belum dikerjakan
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
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
            // Level name
            Expanded(
              child: Text(
                levelName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D4E37),
                ),
              ),
            ),
            
            // Stars display
            _buildStarsDisplay(stars),
            
            const SizedBox(width: 12),
            
            // Status circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: stars > 0
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsDisplay(int earned) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < earned ? Icons.star : Icons.star_border,
          color: i < earned ? const Color(0xFFFFC107) : Colors.grey[400],
          size: 20,
        );
      }),
    );
  }
}
