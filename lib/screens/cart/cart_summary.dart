import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';

/// MH-16: nhập voucher. Đã áp mã thì hiện khung viền gạch kèm nút bỏ mã.
class VoucherBox extends StatefulWidget {
  const VoucherBox({super.key});

  @override
  State<VoucherBox> createState() => _VoucherBoxState();
}

class _VoucherBoxState extends State<VoucherBox> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    final ok = context.read<CartProvider>().applyVoucher(code);
    setState(() => _error = ok ? null : 'Mã không hợp lệ');
    if (ok) {
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final code = cart.voucherCode;

    if (code != null) {
      return CustomPaint(
        painter: _DashedBorder(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
          child: Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.rose,
              ),
              const SizedBox(width: 10),
              Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              const Text(
                'Đã áp dụng ✓',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              IconButton(
                tooltip: 'Bỏ mã',
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.muted,
                onPressed: cart.removeVoucher,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _apply(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: 'Nhập mã voucher',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              errorText: _error,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            // Theme để nút rộng hết cỡ; trong Row phải đặt lại chiều ngang.
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: _apply,
            child: const Text('Áp dụng'),
          ),
        ),
      ],
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// MH-16: Tạm tính, Giảm giá, Phí giao hàng, Tổng cộng.
class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final missing = CartProvider.freeShipFrom - cart.subtotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Tạm tính (${cart.count} sản phẩm)',
            value: formatPrice(cart.subtotal),
          ),
          if (cart.discount > 0)
            _Row(
              label: 'Giảm giá',
              value: '−${formatPrice(cart.discount)}',
              valueColor: AppColors.rose,
            ),
          _Row(
            label: 'Phí giao hàng',
            value: cart.shipping == 0 ? 'Miễn phí' : formatPrice(cart.shipping),
            valueColor: cart.shipping == 0 ? AppColors.success : null,
          ),
          if (missing > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mua thêm ${formatPrice(missing)} để được miễn phí giao hàng',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
            ),
          const Divider(height: 20, color: AppColors.line),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tổng cộng',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              PriceText(cart.total),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.ink,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
