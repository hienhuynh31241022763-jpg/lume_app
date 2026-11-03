import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FlashSaleBanner extends StatefulWidget {
  const FlashSaleBanner({super.key});

  @override
  State<FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<FlashSaleBanner> {
  int _currentIndex = 0;
  Timer? _sliderTimer;

  // 4 ảnh: 3 ảnh cỏ xanh hoa nở chạy nhanh + 1 ảnh gốc cuối dừng 6 giây
  final List<String> _bannerImages = [
    'assets/images/banner_sale_1.png',
    'assets/images/banner_sale_2.png',
    'assets/images/banner_sale_3.png',
    'assets/images/anhnentrangchu.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    // Ảnh cuối (index 3) dừng 6 giây (6000ms), 3 ảnh đầu chạy nhanh 1.2 giây (1200ms)
    int durationMs = (_currentIndex == _bannerImages.length - 1) ? 6000 : 1200;

    _sliderTimer = Timer(Duration(milliseconds: durationMs), () {
      if (!mounted) return;
      
      setState(() {
        _currentIndex = (_currentIndex + 1) % _bannerImages.length;
      });

      _startAutoSlide();
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Dùng AnimatedSwitcher để chuyển ảnh mượt mà, KHÔNG BỊ NHÁY TRẮNG KHUNG
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _bannerImages[_currentIndex],
                key: ValueKey<int>(_currentIndex),
                fit: BoxFit.cover,
                width: double.infinity,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, _) => Image.asset(
                  'assets/images/anhnentrangchu.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // 2. Lớp phủ Kem / Hồng nhạt có độ đầm vừa phải, giữ trọn vẹn màu sắc ảnh và không làm mờ viền khung
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFCE4EC).withOpacity(0.95), // Màu kem hồng pastel đậm đà hơn ở phía chữ để nổi bật nội dung
                    const Color(0xFFFCE4EC).withOpacity(0.60), // Độ mờ vừa phải ở giữa
                    Colors.transparent,                        // Trong suốt hoàn toàn ở bên phải để thấy rõ giày và cỏ
                  ],
                  stops: const [0, 0.50, 0.80],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // 3. Nội dung chữ và đồng hồ đếm ngược
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FLASH SALE',
                  style: TextStyle(
                    color: AppColors.roseDark,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Giảm đến 50%',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const _Countdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown();

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day + 1);
    setState(() => _left = end.difference(now));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _box(int value) {
    return Container(
      width: 34,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value.toString().padLeft(2, '0'),
        style: const TextStyle(
          color: AppColors.roseDark,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colon = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(color: AppColors.roseDark, fontWeight: FontWeight.w800),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _box(_left.inHours),
        colon,
        _box(_left.inMinutes % 60),
        colon,
        _box(_left.inSeconds % 60),
      ],
    );
  }
}