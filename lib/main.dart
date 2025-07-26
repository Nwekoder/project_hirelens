import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/models/user_model.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/utils/auth_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  try {
    debugPrint('Init Supabase...');
    await Supabase.initialize(
      url: 'https://lebuzerrmpjjugoxaaav.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlYnV6ZXJybXBqanVnb3hhYWF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzOTQ4NjAsImV4cCI6MjA2NDk3MDg2MH0.6yeXMi_H8NtqhvGGNGvEQi7lB78eJzqHwb9_AGGPi7Q',
    );
    debugPrint('Supabase ready ✅');
  } catch (err) {
    debugPrint('Supabase init error: $err');
  }

  final userProvider = UserProvider();

  try {
    final token = await getAuthToken();

    if (token != null) {
      debugPrint('Token ketemu: $token');
      try {
        debugPrint('Re-authenticating...');
        await Supabase.instance.client.auth.reauthenticate();
        final user = Supabase.instance.client.auth.currentUser;

        if (user != null) {
          debugPrint('User login: ${user.email}');
          userProvider.setUser(
            UserModel(
              id: user.id,
              email: user.email!,
              displayName: user.userMetadata?['displayName'] ?? user.email!,
            ),
          );
        } else {
          debugPrint('Token ga valid, reset...');
          await clearAuthToken();
        }
      } catch (err) {
        debugPrint('Re-auth failed: $err');
        await clearAuthToken();
      }
    } else {
      debugPrint('Token kosong, skip auth.');
    }
  } catch (err) {
    debugPrint('Error pas ambil token: $err');
  }

  runApp(
    ChangeNotifierProvider(create: (_) => userProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF292929)),
      ),
      home: const LoginPage(),
    );
  }
}
