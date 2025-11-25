// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'register.dart';
import '../widgets/button_coklat.dart';

final supabase = Supabase.instance.client;

// App Theme Constants
class AppTheme {
  static const Color primaryBrown = Color(0xFFA97142);
  static const Color lightBrown = Colors.brown;
  static const Color textSecondary = Colors.black54;
  static const Color cardBackground = Colors.white;
  
  static const double borderRadius = 20.0;
  static const double buttonBorderRadius = 30.0;
  static const double cardPadding = 24.0;
  static const double defaultSpacing = 20.0;
  static const double smallSpacing = 15.0;
  static const double tinySpacing = 10.0;
  
  static const double titleFontSize = 22.0;
  static const double titleFontSizeSmall = 18.0;
  static const double buttonFontSize = 16.0;
  
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showErrorMessage('Email dan password tidak boleh kosong');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on AuthException catch (e) {
      _showErrorMessage(e.message);
    } catch (e) {
      _showErrorMessage('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppTheme.lightBrown),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.lightBrown),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.lightBrown, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
  
  Widget _buildLoginButton() {
    return ButtonCoklat(
      text: "Login",
      onPressed: _handleLogin,
      isLoading: _isLoading,
      height: 50,
    );
  }
  
  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Belum punya akun? ",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        GestureDetector(
          onTap: _navigateToRegister,
          child: const Text(
            "Daftar sekarang",
            style: TextStyle(
              color: AppTheme.primaryBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 350;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // hitung lebar max untuk card agar tidak melebar di tablet/pc
            double maxCardWidth = constraints.maxWidth > 500 ? 400 : constraints.maxWidth * 0.9;

            return Stack(
              children: [
                // Background image
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.asset("assets/images/bglog.png"),
                  ),
                ),

                // Login content
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.defaultSpacing),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.08),

                        // Mascot image
                        Image.asset(
                          "assets/images/maskotlog.png",
                          height: size.height * 0.2,
                        ),

                        const SizedBox(height: AppTheme.defaultSpacing),

                        // Login card
                        Container(
                          width: maxCardWidth,
                          padding: const EdgeInsets.all(AppTheme.cardPadding),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                            boxShadow: [AppTheme.cardShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Text(
                                "Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallScreen 
                                      ? AppTheme.titleFontSizeSmall 
                                      : AppTheme.titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.lightBrown,
                                ),
                              ),
                              const SizedBox(height: AppTheme.defaultSpacing),

                              // Email field
                              _buildCustomTextField(
                                controller: _emailController,
                                labelText: "Email",
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppTheme.smallSpacing),

                              // Password field
                              _buildCustomTextField(
                                controller: _passwordController,
                                labelText: "Password",
                                obscureText: true,
                              ),
                              const SizedBox(height: AppTheme.defaultSpacing),

                              // Login button
                              _buildLoginButton(),

                              const SizedBox(height: AppTheme.tinySpacing),

                              // Forgot password
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password functionality
                                  },
                                  child: const Text(
                                    "Lupa password?",
                                    style: TextStyle(
                                      color: AppTheme.lightBrown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.defaultSpacing),

                        // Register prompt
                        _buildRegisterPrompt(),

                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
