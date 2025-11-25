import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/button_coklat.dart';

final supabase = Supabase.instance.client;

// App Theme Constants - Identical to login.dart
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGender;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty || 
        _passwordController.text.isEmpty ||
        _selectedGender == null) {
      _showErrorMessage('Semua field harus diisi');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showErrorMessage('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Register ke Auth - Same as original backend logic
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;
      if (user == null) {
        throw Exception("Gagal membuat akun");
      }

      // 2. Insert ke tabel users - Restored original parameters
      await supabase.from("users").insert({
        'user_id': user.id,
        'nama': _nameController.text.trim(),
        'gender': _selectedGender,
        'email': _emailController.text.trim(),
        'level': 1,
      });

      if (mounted) {
        _showSuccessMessage("Registrasi berhasil!");
        Navigator.pop(context);
      }
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
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _navigateToLogin() {
    Navigator.pop(context);
  }
  
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: const [
        DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki")),
        DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      decoration: const InputDecoration(
        labelText: "Jenis Kelamin",
        labelStyle: TextStyle(color: AppTheme.lightBrown),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.lightBrown),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.lightBrown, width: 2),
        ),
      ),
      dropdownColor: AppTheme.cardBackground,
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
  
  
  Widget _buildRegisterButton() {
    return ButtonCoklat(
      text: "Register",
      onPressed: _handleRegister,
      isLoading: _isLoading,
      height: 50,
    );
  }
  
  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sudah punya akun? ",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        GestureDetector(
          onTap: _navigateToLogin,
          child: const Text(
            "Login sekarang",
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

                // Register content
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.defaultSpacing),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.08),

                        // Mascot image - same size as login
                        Image.asset(
                          "assets/images/maskotlog.png",
                          height: size.height * 0.2,
                        ),

                        const SizedBox(height: AppTheme.defaultSpacing),

                        // Register card - Identical styling to login.dart
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
                                "Register",
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

                              // Full Name field
                              _buildCustomTextField(
                                controller: _nameController,
                                labelText: "Nama Lengkap",
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: AppTheme.smallSpacing),

                              // Gender dropdown - Same spacing as other fields
                              _buildGenderDropdown(),
                              const SizedBox(height: AppTheme.smallSpacing),

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

                              // Register button
                              _buildRegisterButton(),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.defaultSpacing),

                        // Login prompt
                        _buildLoginPrompt(),

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
