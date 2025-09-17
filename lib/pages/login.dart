// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'register.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // ambil ukuran layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // hitung lebar max untuk card agar tidak melebar di tablet/pc
            double maxCardWidth = constraints.maxWidth > 500 ? 400 : constraints.maxWidth * 0.9;

            return Stack(
              children: [
                // Background responsif menggunakan FittedBox
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover, // isi penuh layar, tetap proporsional
                    child: Image.asset("assets/images/bglog.png"),
                  ),
                ),

                // Konten login
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.08),

                        // Maskot
                        Image.asset(
                          "assets/images/maskotlog.png",
                          height: size.height * 0.2, // responsif
                        ),

                        const SizedBox(height: 20),

                        // Card putih responsif
                        Container(
                          width: maxCardWidth,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width < 350 ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Email
                              TextField(
                                controller: _email,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.brown),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.brown),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.brown, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Password
                              TextField(
                                controller: _password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: Colors.brown),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.brown),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.brown, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Tombol Login
                              ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA97142),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                              ),

                              const SizedBox(height: 10),

                              // Lupa password
                              Center(
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Lupa password?",
                                    style: TextStyle(
                                      color: Colors.brown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Register text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Belum punya akun? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                                );
                              },
                              child: const Text(
                                "Daftar sekarang",
                                style: TextStyle(
                                  color: Color(0xFFA97142),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

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
