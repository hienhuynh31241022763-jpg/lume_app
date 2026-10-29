import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class _Slide {
  final String model;
  final String title;
  final String desc;
  const _Slide(this.model, this.title, this.desc);
}

const _slides = [
  _Slide(
    'assets/models/party_shoe.glb',
    'Tìm đôi giày hoàn hảo',
    'Xem hàng trăm mẫu giày, xoay mọi góc nhìn trước khi mua.',
  ),
  _Slide(
    'assets/models/shoes.glb',
    'Lọc theo đúng ý bạn',
    'Size, màu, chiều cao gót, dịp sử dụng. Chỉ vài chạm là ra đôi phù hợp.',
  ),
  _Slide(
    'assets/models/winter_shoe.glb',
    'Đúng size ngay lần đầu',
    'Nhập chiều dài bàn chân, LUMÉ gợi ý size chuẩn cho bạn.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _next() {
    if (_isLast) {
      _goLogin();
    } else {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              // Hàng trên: logo ảnh + Bỏ qua
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/lume_logo.png', height: 52),
                  TextButton(onPressed: _goLogin, child: const Text('Bỏ qua')),
                ],
              ),
              // Phần các slide vuốt được
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              // Chấm trang
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.rose : AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Nút Tiếp tục / Bắt đầu mua sắm
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Bắt đầu mua sắm' : 'Tiếp tục'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  Widget _spark(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: AppColors.gold,
      shape: BoxShape.circle,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Vòng tròn hồng nhạt phía sau, giày 3D thật xoay ở giữa
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: AppColors.blush,
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(top: 30, left: 40, child: _spark(10)),
              Positioned(top: 60, right: 34, child: _spark(6)),
              Positioned(bottom: 36, left: 58, child: _spark(5)),
              SizedBox(
                width: 280,
                height: 280,
                child: ModelViewer(
                  key: ValueKey(slide.model),
                  src: slide.model,
                  alt: slide.title,
                  autoRotate: true,
                  rotationPerSecond: '40deg',
                  cameraControls: false,
                  disableZoom: true,
                  ar: false,
                  shadowIntensity: 0.6,
                  backgroundColor: Colors.transparent,
                  interactionPrompt: InteractionPrompt.none,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          slide.desc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, height: 1.5),
        ),
      ],
    );
  }
}
