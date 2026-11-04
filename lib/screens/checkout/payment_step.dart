import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import 'address_step.dart';
import 'order_format.dart';

/// HT-01 · Phương thức thanh toán. Chỉ mô phỏng, không nối cổng thanh toán.
enum PaymentChoice {
  cod(
    'Thanh toán khi nhận hàng',
    'Trả tiền mặt cho shipper (COD)',
    Icons.payments_outlined,
  ),
  bank(
    'Chuyển khoản ngân hàng',
    'Xác nhận trong 5 phút',
    Icons.account_balance_outlined,
  ),
  wallet(
    'Ví điện tử',
    'MoMo, ZaloPay (mô phỏng)',
    Icons.account_balance_wallet_outlined,
  );

  const PaymentChoice(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;

  static const wallets = ['MoMo', 'ZaloPay'];

  /// Tên ghi vào đơn hàng, theo định dạng nhóm đã thống nhất.
  String orderName(String wallet) => switch (this) {
    cod => PaymentNames.cod,
    bank => PaymentNames.bank,
    PaymentChoice.wallet => PaymentNames.wallet(wallet),
  };
}

/// HT-01 · Bước 2: chọn COD / chuyển khoản / ví điện tử.
class PaymentStep extends StatelessWidget {
  const PaymentStep({
    super.key,
    required this.choice,
    required this.wallet,
    required this.phone,
    required this.onChoice,
    required this.onWallet,
  });

  final PaymentChoice choice;
  final String wallet;

  /// Dùng làm nội dung chuyển khoản.
  final String phone;
  final ValueChanged<PaymentChoice> onChoice;
  final ValueChanged<String> onWallet;

  @override
  Widget build(BuildContext context) {
    final total = context.watch<CartProvider>().selectedTotal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const SectionLabel('Phương thức thanh toán'),
        for (final c in PaymentChoice.values) ...[
          _PaymentTile(
            choice: c,
            selected: c == choice,
            onTap: () => onChoice(c),
          ),
          const SizedBox(height: 10),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (choice) {
            PaymentChoice.bank => _BankInfo(
              key: const ValueKey('bank'),
              total: total,
              phone: phone,
            ),
            PaymentChoice.wallet => Wrap(
              key: const ValueKey('wallet'),
              spacing: 8,
              children: [
                for (final w in PaymentChoice.wallets)
                  ChoiceChip(
                    label: Text(w),
                    selected: w == wallet,
                    onSelected: (_) => onWallet(w),
                    selectedColor: AppColors.blush,
                    side: BorderSide(
                      color: w == wallet ? AppColors.rose : AppColors.line,
                    ),
                  ),
              ],
            ),
            PaymentChoice.cod => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final PaymentChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.blush.withValues(alpha: 0.45)
          : AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.rose : AppColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(choice.icon, color: AppColors.roseDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      choice.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.rose : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thông tin chuyển khoản mẫu (mô phỏng).
class _BankInfo extends StatelessWidget {
  const _BankInfo({super.key, required this.total, required this.phone});

  final int total;
  final String phone;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row('Ngân hàng', 'Vietcombank'),
          row('Số tài khoản', '0123 4567 89'),
          row('Chủ tài khoản', 'CONG TY LUME'),
          row('Số tiền', formatPrice(total)),
          row('Nội dung', 'LUME ${phone.isEmpty ? '<số điện thoại>' : phone}'),
          const SizedBox(height: 4),
          const Text(
            'Đây là thông tin mô phỏng cho đồ án, không chuyển tiền thật.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
