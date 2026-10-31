import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../search/search_screen.dart';
import 'cart_item_tile.dart';
import 'cart_summary.dart';

/// Giỏ hàng (prototype màn Giỏ hàng)
/// - MH-15 (Hạo): danh sách, đổi size/màu/số lượng, vuốt để xóa, giỏ trống.
/// - MH-16 (Hạo): tạm tính, voucher, phí ship, tổng tiền.
///
/// Chạy được cả khi là tab trong MainShell lẫn khi được push từ Chi tiết.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(cart.isEmpty ? 'Giỏ hàng' : 'Giỏ hàng (${cart.count})'),
      ),
      body: cart.isEmpty ? const _EmptyCart() : const _CartBody(),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              for (final item in items) ...[
                CartItemTile(
                  key: ValueKey(
                    '${item.product.id}|${item.size}|${item.color}',
                  ),
                  item: item,
                ),
                const SizedBox(height: 10),
              ],
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Vuốt sang trái để xóa sản phẩm',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const VoucherBox(),
              const SizedBox(height: 12),
              const CartSummary(),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.checkout),
                child: Text('Thanh toán · ${formatPrice(cart.total)}'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  void _shopNow(BuildContext context) {
    // Được push (từ Chi tiết) thì quay lại; là tab thì mở Tìm kiếm.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: AppColors.blush,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 52,
                color: AppColors.rose,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Giỏ hàng đang trống',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Chọn vài đôi giày bạn thích rồi quay lại đây nhé',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _shopNow(context),
              child: const Text('Mua sắm ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
