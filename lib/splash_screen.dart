import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart'; // Halaman ucapan
import 'countdown_screen.dart'; // Halaman countdown

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final int birthdayMonth = 7;
  final int birthdayDay = 13;

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() {
    // Durasi loading screen singkat, misalnya 4 detik
    Timer(const Duration(seconds: 4), () {
      final now = DateTime.now();
      
      // Mengatur tanggal ulang tahun untuk tahun ini
      var birthdayThisYear = DateTime(now.year, birthdayMonth, birthdayDay);
      
      // Tanggal akhir periode ucapan (H+3). Kita cek sebelum H+4
      var endOfWindow = birthdayThisYear.add(const Duration(days: 4));

      Widget nextPage;

      // Logika Pengecekan Tanggal
      if (now.isAfter(birthdayThisYear) && now.isBefore(endOfWindow)) {
        // KASUS 1: Masuk dalam periode ulang tahun (Hari H sampai H+3)
        // Arahkan ke Halaman Ucapan
        nextPage = const HomeScreen();
      } else {
        // KASUS 2: Di luar periode ulang tahun
        // Arahkan ke Halaman Countdown
        
        // Cek apakah ultah tahun ini sudah lewat? Jika ya, targetkan tahun depan.
        if (now.isAfter(birthdayThisYear)) {
          birthdayThisYear = DateTime(now.year + 1, birthdayMonth, birthdayDay);
        }
        nextPage = CountdownScreen(targetDate: birthdayThisYear);
      }

      // Navigasi ke halaman yang sesuai
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Amplop Bergerak
            Image.asset('assets/envelope.png', width: 120)
                .animate(onPlay: (controller) => controller.repeat())
                .shake(hz: 2, duration: 2000.ms, rotation: 0.2)
                .then(delay: 2000.ms), // Bergetar selama 2 detik, lalu jeda

            const SizedBox(height: 20),

            const Text(
              'Mempersiapkan Kejutan...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}