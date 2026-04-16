import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import file konfigurasi yang kamu generate tadi
// Import View kamu (sesuaikan pathnya)
// import 'views/auth/login_view.dart'; 

void main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizPrice Tracker',
      theme: ThemeData(
        // Sesuaikan dengan tema hijau/teal di gambar referensi kamu
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D40)),
        useMaterial3: true,
      ),
      // Untuk sementara arahkan ke Scaffold kosong dulu 
      // Nanti ganti dengan LoginView() jika Anggota A sudah selesai
      home: const PlaceholderScreen(), 
    );
  }
}

// Halaman sementara sebelum LoginView digabung
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Firebase Ready! Menunggu UI Login..."),
      ),
    );
  }
}