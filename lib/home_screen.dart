import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Class GiftModel tidak berubah
class GiftModel {
  final double size;
  final String content;
  bool isOpened;
  double top;
  double left;

  GiftModel({
    required this.size,
    required this.content,
    this.isOpened = false,
    this.top = 0,
    this.left = 0,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  Timer? _confettiTimer;
  Timer? _randomMovementTimer;

  String? _userName;
  XFile? _userImage;

  final List<GiftModel> _gifts = [
    GiftModel(size: 80.0, content: 'assets/aa.gif'),
    GiftModel(size: 60.0, content: 'assets/aa.gif'),
    GiftModel(size: 70.0, content: 'assets/ac.gif'),
    GiftModel(size: 55.0, content: 'assets/ad.gif'),
    GiftModel(size: 75.0, content: 'assets/ae.gif'),
  ];

  bool _canOpenGift = true;
  final Random _random = Random();

  final _pageController = PageController();

  final List<String> _greetingCards = [
    "Semoga hari ini secerah dan seindah senyummu. Selamat ulang tahun!",
    "Panjang umur, sehat selalu, dan semoga semua impianmu tercapai di tahun ini.",
    "Bertambah satu tahun usiamu, semoga juga bertambah kebijaksanaan dan kebahagiaanmu. Barokallahu fii umrik.",
    "HAHAHA tambah tua! Semoga jadi pribadi yang lebih baik dan selalu dikelilingi orang-orang baik.",
    "Happy Birthday! Terima kasih sudah menjadi musuh yang luar biasa. Wish you all the best!",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 300));
    _confettiTimer = Timer.periodic(const Duration(seconds: 2), (timer) => _confettiController.play());
    _loadAllData();
  }
  
  // ... (Semua fungsi lain sebelum 'build' tidak perlu diubah)
  Future<void> _loadAllData() async {
  final prefs = await SharedPreferences.getInstance();
  final int lastOpenedYear = prefs.getInt('lastOpenedYear') ?? 0;
  final List<String> openedIndices = prefs.getStringList('openedGiftIndices') ?? [];
  final currentYear = DateTime.now().year;
  final String? savedName = prefs.getString('userName');
  final String? savedImagePath = prefs.getString('userImagePath');
  setState(() {
      _canOpenGift = currentYear > lastOpenedYear;
      for (var i = 0; i < _gifts.length; i++) {
        if (openedIndices.contains(i.toString())) {
          _gifts[i].isOpened = true;
        }
        _gifts[i].top = _random.nextDouble() * (MediaQuery.of(context).size.height - 150);
        _gifts[i].left = _random.nextDouble() * (MediaQuery.of(context).size.width - 80);
      }
      _userName = savedName;
      if (savedImagePath != null) {
        _userImage = XFile(savedImagePath);
      }
  });
  _startRandomMovement();
  }
  Future<void> _saveGiftData(int openedIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final currentYear = DateTime.now().year;
    final List<String> openedIndices = prefs.getStringList('openedGiftIndices') ?? [];
    if (!openedIndices.contains(openedIndex.toString())) {
      openedIndices.add(openedIndex.toString());
      await prefs.setStringList('openedGiftIndices', openedIndices);
    }
    await prefs.setInt('lastOpenedYear', currentYear);
  }
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userName != null) {
      await prefs.setString('userName', _userName!);
    }
    if (_userImage != null) {
      await prefs.setString('userImagePath', _userImage!.path);
    }
  }
  void _startRandomMovement() {
    _randomMovementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        for (var gift in _gifts) {
          gift.top = _random.nextDouble() * (MediaQuery.of(context).size.height - 150);
          gift.left = _random.nextDouble() * (MediaQuery.of(context).size.width - 80);
        }
      });
    });
  }
  @override
  void dispose() {
    _confettiController.dispose();
    _confettiTimer?.cancel();
    _randomMovementTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  void _showGiftDialog(BuildContext context, int giftIndex) {
    if (_gifts[giftIndex].isOpened) {
    } else if (_canOpenGift) {
      setState(() {
        _gifts[giftIndex].isOpened = true;
        _canOpenGift = false;
      });
      _saveGiftData(giftIndex);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Wlee... buatmu satu aja! Coba lagi tahun depan ya!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 120,
            right: 20,
            left: 20,
          ),
          backgroundColor: Colors.pinkAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.pink[50],
        contentPadding: const EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(_gifts[giftIndex].content),
            ),
            TextButton(
              child: const Text('Tutup', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }
  void _showNameAndImageDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: _userName);
    XFile? dialogPickedImage = _userImage;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Personalisasi Ucapan', style: TextStyle(color: Colors.pink)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kamu',
                        hintText: 'Tulis namamu di sini...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.pink, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() {
                            dialogPickedImage = image;
                          });
                        }
                      },
                      child: dialogPickedImage == null
                          ? Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink.withOpacity(0.3), style: BorderStyle.solid)
                              ),
                              child: const Center(child: Icon(Icons.add_a_photo, color: Colors.pink, size: 30)),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(dialogPickedImage!.path), height: 100, width: double.infinity, fit: BoxFit.cover,)
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _userName = nameController.text;
                      _userImage = dialogPickedImage;
                    });
                    _saveUserData();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Stack(
        children: [
          // [MODIFIKASI] Kado-kado dipindahkan ke sini (lapisan paling bawah)
          ..._gifts.asMap().entries.map((entry) {
            int index = entry.key;
            GiftModel gift = entry.value;
            return AnimatedPositioned(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              top: gift.top,
              left: gift.left,
              child: GestureDetector(
                onTap: () => _showGiftDialog(context, index),
                child: Opacity(
                  opacity: gift.isOpened ? 0.4 : 1.0,
                  child: Image.asset('assets/gift.png', width: gift.size),
                ),
              ),
            );
          }),

          // Konten utama (teks, gambar, kartu) diletakkan setelah kado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showNameAndImageDialog(context),
                  child: _userImage == null
                      ? const Icon(Icons.cake, size: 100, color: Colors.pinkAccent)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
                          .then()
                          .shake(hz: 2, duration: 500.ms)
                      : ClipOval(
                          child: Image.file(File(_userImage!.path), width: 100, height: 100, fit: BoxFit.cover,),
                        ).animate().scale(duration: 500.ms),
                ),
                const SizedBox(height: 16),
                _userName == null || _userName!.isEmpty
                    ? const Text('Selamat Ulang Tahun!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink))
                        .animate()
                        .fade(delay: 200.ms, duration: 800.ms)
                        .shimmer(duration: 1500.ms, delay: 500.ms, color: Colors.pink[100])
                    : Column(
                        children: [
                          const Text('Selamat Ulang Tahun,', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
                          Text(_userName!, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                        ],
                      ).animate().fade(duration: 500.ms),
                
                const SizedBox(height: 24),

                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _greetingCards.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              _greetingCards[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.pink[800],
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _greetingCards.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: Colors.pinkAccent,
                    dotColor: Colors.pink.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Confetti tetap di paling atas agar menutupi semua
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              emissionFrequency: 0.02,
              numberOfParticles: 15,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [Colors.pink, Colors.yellow, Colors.lightBlue, Colors.white],
            ),
          ),
        ],
      ),
    );
  }
}