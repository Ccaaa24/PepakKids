// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,       // ambil dari .env
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, // ambil dari .env
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
      home: session != null ? const HomePage() : const LoginPage(),
    );
  }
}
