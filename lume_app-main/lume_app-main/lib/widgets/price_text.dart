import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

String formatPrice(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}$buffer₫';
}

class PriceText extends StatelessWidget {
  const PriceText(this.price, {super.key, this.style});

  final int price;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleMedium;
    return Text(
      formatPrice(price),
      style: base?.copyWith(
        color: AppColors.roseDark,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
