import 'package:flutter/material.dart';

/// Small Level Card Widget
/// Menampilkan card level dengan nomor besar dan label di bawah
class SmallLevelCard extends StatelessWidget {
  final Map<String, dynamic> level;
  final int index;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  const SmallLevelCard({
    super.key,
    required this.level,
    required this.index,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Color rotation for level cards
    final colors = [
      const Color(0xFF5DADE2), // Blue
      const Color(0xFFF48FB1), // Pink
      const Color(0xFFAB7FE8), // Purple
    ];
    final cardColor = colors[index % colors.length];

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card container
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: isUnlocked ? cardColor : Colors.grey[400],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Lock overlay for locked levels
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                // Level number - centered
                Center(
                  child: Text(
                    "${level['urutan']}",
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Level label - below card
          Text(
            level['nama_level'] ?? 'Level ${index + 1}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B6F47),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

}
