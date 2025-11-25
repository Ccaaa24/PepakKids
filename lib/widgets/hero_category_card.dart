import 'package:flutter/material.dart';

// Hero Category Card Widget - Menampilkan kategori yang sedang aktif
class HeroCategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback? onTap;

  const HeroCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData(category);
    debugPrint('🎨 Building HeroCategoryCard for: "$category"');
    debugPrint('📦 Category Data: ${categoryData['title']}, Image: ${categoryData['imagePath']}');
    debugPrint('🔍 Category toLowerCase: "${category.toLowerCase()}"');
    
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0, // Square - width = height
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
          color: const Color(0xFFFFF4D6), // heroYellow
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          // Background image
          image: categoryData['imagePath'] != null
              ? DecorationImage(
                  image: AssetImage(categoryData['imagePath']),
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  opacity: 0.9,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    categoryData['title'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4E37), // heroText
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    categoryData['subtitle'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5D4E37), // heroText
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              
              // Button "Mulai" at bottom
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Mulai",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4E37), // heroText
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // Helper: Dapatkan data kategori (title, subtitle, image, dll)
  Map<String, dynamic> _getCategoryData(String category) {
    // Trim dan lowercase untuk matching yang lebih robust
    final cleanCategory = category.trim().toLowerCase();
    debugPrint('🧹 Clean category: "$cleanCategory" (length: ${cleanCategory.length})');
    
    switch (cleanCategory) {
      case 'hewan':
        return {
          'title': 'Bermain Hewan',
          'subtitle': 'Mulai Pelajaran mu hari ini dengan\nbelajar nama hewan',
          'imagePath': 'assets/images/Hewan.png',
          'icon': Icons.pets,
          'iconColor': Colors.orange,
          'bgColor': Colors.orange.withOpacity(0.2),
        };
      case 'buah':
        return {
          'title': 'Bermain Buah',
          'subtitle': 'Lanjutkan petualangan mu dengan\nbelajar nama buah-buahan',
          'imagePath': 'assets/images/Buah.png',
          'icon': Icons.apple,
          'iconColor': Colors.red,
          'bgColor': Colors.red.withOpacity(0.2),
        };
      case 'sayuran':
        return {
          'title': 'Bermain Sayuran',
          'subtitle': 'Ayo belajar nama sayuran\nyang sehat dan bergizi',
          'imagePath': 'assets/images/Sayuran.png',
          'icon': Icons.eco,
          'iconColor': Colors.green,
          'bgColor': Colors.green.withOpacity(0.2),
        };
      case 'warna':
        return {
          'title': 'Bermain Warna',
          'subtitle': 'Mari mengenal berbagai\nwarna yang indah',
          'imagePath': 'assets/images/Warna.png',
          'icon': Icons.palette,
          'iconColor': Colors.purple,
          'bgColor': Colors.purple.withOpacity(0.2),
        };
      case 'angka':
        return {
          'title': 'Bermain Angka',
          'subtitle': 'Belajar menghitung angka\ndalam bahasa Jawa',
          'imagePath': 'assets/images/Angka.png',
          'icon': Icons.numbers,
          'iconColor': Colors.blue,
          'bgColor': Colors.blue.withOpacity(0.2),
        };
      default:
        return {
          'title': 'Bermain $category',
          'subtitle': 'Mulai Pelajaran mu hari ini dengan\nbelajar $category',
          'imagePath': null,
          'icon': Icons.school,
          'iconColor': Colors.blue,
          'bgColor': Colors.blue.withOpacity(0.2),
        };
    }
  }
}
