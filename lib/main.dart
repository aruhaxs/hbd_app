import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'splash_screen.dart';

void main() async { // <-- 2. JADIKAN FUNGSI main() MENJADI ASYNC
  
  // Baris ini wajib ada jika Anda menjalankan kode sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 3. Inisialisasi format tanggal untuk 'id_ID' (Indonesia)
  await initializeDateFormatting('id_ID', null); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Aplikasi Ulang Tahun',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}