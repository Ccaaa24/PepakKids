// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart';

const SUPABASE_URL = 'https://relzmmwfuljuhjcvijqc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlbHptbXdmdWxqdWhqY3ZpanFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1NTQ0NjMsImV4cCI6MjA3MTEzMDQ2M30.wDLmFdgGz8zH642wcFYsJpvXskdOCU29f3Sp2gIi4RQ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    // supabase_flutter sudah handle session persistence otomatis
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Jika sudah login, langsung ke Home; kalau belum, ke Login
      home: session != null ? const HomePage() : const LoginPage(),
    );
  }
}
