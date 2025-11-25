import 'package:flutter/material.dart';

// Result Info Card Widget - Reusable card untuk menampilkan info hasil quiz
class ResultInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final Color textColor;
  final bool showCircle;

  const ResultInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    this.showCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          
          // Value and Circle
          if (value.isNotEmpty)
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (showCircle) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.circle,
                      color: textColor,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
