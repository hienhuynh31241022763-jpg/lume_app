import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/referral.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';

/// Tiếp thị liên kết: mã của tôi, số đơn nhờ mã, hoa hồng tạm tính.
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderProvider>().load();
    });
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Đã sao chép mã giới thiệu')),
      );
  }

  int _sum(List<Order> list) => list.fold(0, (s, o) => s + o.total);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<OrderProvider>();
    final code = auth.referralCode;

    if (!auth.isLoggedIn || code.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tiếp thị liên kết')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Hãy đăng nhập để nhận mã giới thiệu của bạn',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Đơn dùng mã của mình, bỏ đơn đã hủy.
    final mine = provider.orders
        .where((o) => o.refCode == code && o.status != OrderStatus.cancelled)
        .toList();
    final delivered = mine
        .where((o) => o.status == OrderStatus.delivered)
        .toList();
    final waiting = mine
        .where((o) => o.status != OrderStatus.delivered)
        .toList();
    final earned = (_sum(delivered) * Referral.commissionRate).round();
    final pending = (_sum(waiting) * Referral.commissionRate).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Tiếp thị liên kết')),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // 1. Mã của tôi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Mã giới thiệu của bạn',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.rose,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: () => _copy(code),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Sao chép mã'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Cách hoạt động
            const Text(
              'Cách hoạt động',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Gửi mã cho bạn bè.\n'
              '2. Bạn bè nhập mã khi thanh toán và được giảm 5%.\n'
              '3. Khi đơn được giao thành công, bạn nhận hoa hồng 5% giá trị đơn.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),

            // 3. Thống kê
            Row(
              children: [
                _StatCard(value: '${mine.length}', label: 'Đơn nhờ mã'),
                const SizedBox(width: 10),
                _StatCard(
                  value: formatPrice(earned),
                  label: 'Hoa hồng đã nhận',
                ),
                const SizedBox(width: 10),
                _StatCard(value: formatPrice(pending), label: 'Đang chờ giao'),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Hoa hồng tạm tính, chỉ ghi nhận khi đơn đã giao.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 16),

            // 4. Danh sách đơn
            const Text(
              'Đơn dùng mã của bạn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading && provider.orders.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (mine.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Chưa có đơn nào dùng mã của bạn',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              for (final o in mine)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đơn #${o.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              o.status,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PriceText(o.total),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
