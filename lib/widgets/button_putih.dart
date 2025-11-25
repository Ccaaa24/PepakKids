import 'package:flutter/material.dart';

// Color Palette
class AppColors {
  static const Color brown = Color(0xFF774C26);
  static const Color lightBrown = Color(0xFFA37B58);
  static const Color cream = Color(0xFFFFE4BF);
  static const Color lightCream = Color(0xFFFDF6F1);
  static const Color white = Color(0xFFFFFCF9);
}

class ButtonPutih extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final bool isLoading;

  const ButtonPutih({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 50,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.lightBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFFA37B58),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightBrown,
                ),
              ),
      ),
    );
  }
}
