import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart'; // Import package confetti

class CountdownScreen extends StatefulWidget {
  final DateTime targetDate;

  const CountdownScreen({super.key, required this.targetDate});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;
  late ConfettiController _confettiController; // Controller untuk animasi confetti

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi controller confetti
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _updateTimeRemaining();
    // Update countdown setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    if (!mounted) return; // Pastikan widget masih ada di tree
    setState(() {
      if (widget.targetDate.isAfter(now)) {
        _timeRemaining = widget.targetDate.difference(now);
      } else {
        _timeRemaining = Duration.zero;
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat('d MMMM yyyy', 'id_ID').format(widget.targetDate);
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    // Pemicu confetti saat layar disentuh
    return GestureDetector(
      onTap: () {
        _confettiController.play();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0F5), // Warna pastel pink (Lavender Blush)
        body: Stack( // Bungkus dengan Stack agar confetti bisa tampil di atas konten
          alignment: Alignment.center,
          children: [
            // Konten utama halaman
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Menghitung Mundur Menuju Hari Spesial',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFC71585), // Warna pink tua
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.white,
                          offset: Offset(0, 0),
                        ),
                      ]
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeCard(days.toString(), 'Days'),
                      _buildTimeCard(hours.toString(), 'Hours'),
                      _buildTimeCard(minutes.toString(), 'Mins'),
                      _buildTimeCard(seconds.toString().padLeft(2, '0'), 'Secs'),
                    ],
                  )
                ],
              ),
            ),
            
            // Widget Confetti di bagian atas, agar menyebar ke bawah
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive, // Menyebar ke segala arah
                shouldLoop: false,
                colors: const [
                  Colors.pink,
                  Colors.orange,
                  Colors.yellow,
                  Colors.lightBlue,
                  Colors.lightGreen,
                ],
                gravity: 0.1,
                emissionFrequency: 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String time, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 42,
              color: Color(0xFFC71585),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFDB7093)),
          ),
        ],
      ),
    );
  }
}