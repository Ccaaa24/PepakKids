import 'package:flutter/material.dart';

/// Content Card Widget
/// Reusable card untuk menampilkan konten materi atau quiz
class ContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Color backgroundColor;

  const ContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.backgroundColor = const Color(0xFFFFC107),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display image if available
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Title/Word
          Text(
            title,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Subtitle/Translation
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "( $subtitle )",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
