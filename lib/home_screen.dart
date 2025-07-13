import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GiftModel {
  final double size;
  final String content;
  bool isOpened;
  final double radiusX;
  final double radiusY;
  final double speed;
  final double initialAngle;

  GiftModel({
    required this.size,
    required this.content,
    this.isOpened = false,
    required this.radiusX,
    required this.radiusY,
    required this.speed,
    required this.initialAngle,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  Timer? _confettiTimer;
  late AnimationController _animationController;

  String? _userName;
  XFile? _userImage;
  final Random _random = Random();
  List<GiftModel> _gifts = [];
  bool _canOpenGift = true;
  final _pageController = PageController();

  bool _isNotificationVisible = false;
  String _notificationMessage = '';
  Timer? _notificationTimer;

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
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 300));
    _confettiTimer = Timer.periodic(
        const Duration(seconds: 2), (timer) => _confettiController.play());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Panggil _initializeGifts setelah build pertama selesai.
    // _loadAllData akan dipanggil dari dalam _initializeGifts.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeGifts());
  }

  void _initializeGifts() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Hanya inisialisasi jika list masih kosong
    if (_gifts.isEmpty) {
      _gifts = [
        _createRandomGift('assets/aa.gif', 80.0, screenWidth, screenHeight),
        _createRandomGift('assets/aa.gif', 60.0, screenWidth, screenHeight),
        _createRandomGift('assets/ac.gif', 70.0, screenWidth, screenHeight),
        _createRandomGift('assets/ad.gif', 55.0, screenWidth, screenHeight),
        _createRandomGift('assets/ae.gif', 75.0, screenWidth, screenHeight),
        _createRandomGift('assets/af.gif', 45.0, screenWidth, screenHeight),
        _createRandomGift('assets/ag.gif', 85.0, screenWidth, screenHeight),
        _createRandomGift('assets/ah.gif', 95.0, screenWidth, screenHeight),
      ];
    }
    
    // [FIX] Panggil _loadAllData setelah _gifts dijamin sudah terisi.
    _loadAllData();
  }

  GiftModel _createRandomGift(String content, double size, double w, double h) {
    return GiftModel(
      content: content,
      size: size,
      radiusX: _random.nextDouble() * (w / 2.5) + 40,
      radiusY: _random.nextDouble() * (h / 3) + 60,
      speed: (_random.nextInt(3) + 1).toDouble(),
      initialAngle: _random.nextDouble() * 2 * pi,
    );
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final int lastOpenedYear = prefs.getInt('lastOpenedYear') ?? 0;
    final List<String> openedIndices =
        prefs.getStringList('openedGiftIndices') ?? [];
    final currentYear = DateTime.now().year;
    final String? savedName = prefs.getString('userName');
    final String? savedImagePath = prefs.getString('userImagePath');
    
    if (mounted) {
      setState(() {
        _canOpenGift = currentYear > lastOpenedYear;
        // [FIX] Loop ini sekarang akan berjalan dengan benar karena _gifts sudah terisi.
        for (var i = 0; i < _gifts.length; i++) {
          if (openedIndices.contains(i.toString())) {
            _gifts[i].isOpened = true;
          }
        }
        _userName = savedName;
        if (savedImagePath != null) {
          _userImage = XFile(savedImagePath);
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _confettiTimer?.cancel();
    _animationController.dispose();
    _pageController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _showTopNotification(String message) {
    _notificationTimer?.cancel();
    setState(() {
      _notificationMessage = message;
      _isNotificationVisible = true;
    });
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isNotificationVisible = false;
        });
      }
    });
  }

  void _showGiftDialog(BuildContext context, int giftIndex) {
    if (_gifts[giftIndex].isOpened) {
      // Biarkan dialog tetap muncul jika kado sudah dibuka
    } else if (_canOpenGift) {
      setState(() {
        _gifts[giftIndex].isOpened = true;
        _canOpenGift = false;
      });
      _saveGiftData(giftIndex);
    } else {
      _showTopNotification('Wlee... buatmu satu aja! Coba lagi tahun depan ya!');
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(_gifts[giftIndex].content),
            ),
            TextButton(
              child: const Text('Tutup',
                  style: TextStyle(
                      color: Colors.pink, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _saveGiftData(int openedIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final currentYear = DateTime.now().year;
    final List<String> openedIndices =
        prefs.getStringList('openedGiftIndices') ?? [];
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

  void _showNameAndImageDialog(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: _userName);
    XFile? dialogPickedImage = _userImage;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Personalisasi Ucapan',
                  style: TextStyle(color: Colors.pink)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kamu',
                        hintText: 'Tulis namamu di sini...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.pink, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
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
                                  border: Border.all(
                                      color: Colors.pink.withOpacity(0.3),
                                      style: BorderStyle.solid)),
                              child: const Center(
                                  child: Icon(Icons.add_a_photo,
                                      color: Colors.pink, size: 30)),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(dialogPickedImage!.path),
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
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
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final t = _animationController.value * 2 * pi;

              return Stack(
                children: _gifts.asMap().entries.map((entry) {
                  int index = entry.key;
                  GiftModel gift = entry.value;

                  final newLeft = (screenWidth / 2) +
                      gift.radiusX * cos(gift.speed * t + gift.initialAngle) -
                      (gift.size / 2);
                  final newTop = (screenHeight / 2) +
                      gift.radiusY * sin(gift.speed * t + gift.initialAngle) -
                      (gift.size / 2);

                  return Positioned(
                    top: newTop,
                    left: newLeft,
                    child: GestureDetector(
                      onTap: () => _showGiftDialog(context, index),
                      child: Opacity(
                        opacity: gift.isOpened ? 0.3 : 0.8,
                        child: Image.asset('assets/gift.png', width: gift.size),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showNameAndImageDialog(context),
                  child: _userImage == null
                      ? const Icon(Icons.cake,
                              size: 100, color: Colors.pinkAccent)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                              duration: 1500.ms,
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1))
                          .then()
                          .shake(hz: 2, duration: 500.ms)
                      : ClipOval(
                          child: Image.file(
                            File(_userImage!.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ).animate().scale(duration: 500.ms),
                ),
                const SizedBox(height: 16),
                _userName == null || _userName!.isEmpty
                    ? Text(
                        'Selamat Ulang Tahun!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dancingScript(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                            duration: 2000.ms,
                            delay: 3000.ms,
                            color: Colors.pink[100])
                    : Column(
                        children: [
                          Text(
                            'Selamat Ulang Tahun,',
                            style: GoogleFonts.dancingScript(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink),
                          ),
                          Text(
                            _userName!,
                            style: GoogleFonts.dancingScript(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent),
                          ),
                        ],
                      )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                            duration: 2000.ms,
                            delay: 3000.ms,
                            color: Colors.pink[100]),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            top: _isNotificationVisible
                ? MediaQuery.of(context).padding.top + 10
                : -100,
            left: 20,
            right: 20,
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _notificationMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.02,
              numberOfParticles: 15,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.pink,
                Colors.yellow,
                Colors.lightBlue,
                Colors.white
              ],
            ),
          ),
        ],
      ),
    );
  }
}
