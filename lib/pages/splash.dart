import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _textController;

  late Animation<double> _circleScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Circle zoom in animation - dari kecil ke sangat besar (memenuhi layar)
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _circleScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0, // Scale besar untuk memenuhi layar
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));

    // Text fade in animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Delay awal
    await Future.delayed(const Duration(milliseconds: 500));

    // Start circle zoom in
    _circleController.forward();

    // Tunggu circle hampir selesai, lalu munculkan text
    await Future.delayed(const Duration(milliseconds: 1000));
    _textController.forward();

    // Navigate setelah animasi selesai
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      // Check session untuk navigate ke home atau login
      final session = Supabase.instance.client.auth.currentSession;
      final destination =
          session != null ? const HomePage() : const LoginPage();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _circleController,
        _textController,
      ]),
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background cream (base layer)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF5E6D3), // Cream
              ),

              // Circle putih yang zoom in (overlay layer)
              Positioned.fill(
                child: Center(
                  child: Transform.scale(
                    scale: _circleScaleAnimation.value,
                    child: Container(
                      width: size.width * 0.5,
                      height: size.width * 0.5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // App name text (top layer)
              Center(
                child: Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Pepak",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA97142), // Cream/Coklat
                            letterSpacing: 1.5,
                          ),
                        ),
                        TextSpan(
                          text: "Kids",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE74C3C), // Merah
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}