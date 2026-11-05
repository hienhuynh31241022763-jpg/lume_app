import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';

/// Ô nhập mã giới thiệu ở bước xem lại đơn. Áp mã xong hiện khung kèm nút bỏ mã.
class ReferralBox extends StatefulWidget {
  const ReferralBox({super.key});

  @override
  State<ReferralBox> createState() => _ReferralBoxState();
}

class _ReferralBoxState extends State<ReferralBox> {
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
    final own = context.read<AuthProvider>().referralCode;
    final error = context.read<CartProvider>().applyReferral(
      code,
      ownCode: own,
    );
    setState(() => _error = error);
    if (error == null) {
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final code = cart.referralCode;

    if (code != null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
        decoration: BoxDecoration(
          color: AppColors.blush,
          border: Border.all(color: AppColors.rose),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.share_outlined, color: AppColors.rose),
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
              'Giảm 5% ✓',
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
              onPressed: cart.removeReferral,
            ),
          ],
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
              hintText: 'Nhập mã giới thiệu (ví dụ LUME1A2B3)',
              prefixIcon: const Icon(Icons.share_outlined),
              errorText: _error,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: _apply,
            child: const Text('Áp dụng'),
          ),
        ),
      ],
    );
  }
}
