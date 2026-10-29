import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Banner đầu trang Đăng nhập / Đăng ký: logo ở góc trái, đôi giày ở góc phải dưới.
class AuthBanner extends StatelessWidget {
  final bool showBack;
  final double heightFactor;

  const AuthBanner({
    super.key,
    this.showBack = false,
    this.heightFactor = 0.30,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final top = mq.padding.top;
    final bodyHeight = (mq.size.height * heightFactor)
        .clamp(190.0, 320.0)
        .toDouble();
    final shoeWidth = mq.size.width * 0.68;

    return Container(
      width: double.infinity,
      height: top + bodyHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blush, AppColors.background],
        ),
      ),
      child: Stack(
        children: [
          // Đôi giày ở góc phải phía dưới
          Positioned(
            right: -6,
            bottom: 0,
            width: shoeWidth,
            child: Image.asset(
              'assets/images/giay_nen.png',
              fit: BoxFit.contain,
            ),
          ),
          // Logo (kèm nút quay lại nếu cần) ở góc trái phía trên
          Positioned(
            left: showBack ? 6 : 20,
            top: top + 10,
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: AppColors.ink,
                    onPressed: () => Navigator.pop(context),
                  ),
                Image.asset('assets/images/lume_logo.png', height: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
