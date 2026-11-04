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
                  'Tick chọn món muốn mua · vuốt sang trái để xóa',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const VoucherBox(),
              const SizedBox(height: 12),
              const CartSummary(),
            ],
          ),
        ),
        const _CartBottomBar(),
      ],
    );
  }
}

/// MH-15: thanh dưới hai tầng. Tầng trên chọn "Tất cả" và xóa hàng loạt,
/// tầng dưới hiện tiền của các món đã tick và nút Thanh toán.
class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar();

  Future<void> _confirmRemove(BuildContext context, CartProvider cart) async {
    final count = cart.selectedCount;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Xóa sản phẩm đã chọn?'),
        content: Text('$count sản phẩm sẽ bị xóa khỏi giỏ hàng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    cart.removeSelected();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Đã xóa $count sản phẩm')));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final chosen = cart.hasSelection;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  value: cart.allSelected,
                  activeColor: AppColors.rose,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) => cart.selectAll(value ?? false),
                ),
                const SizedBox(width: 6),
                Text('Tất cả (${cart.items.length})'),
                const Spacer(),
                if (chosen)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text('Xóa (${cart.selectedCount})'),
                    onPressed: () => _confirmRemove(context, cart),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chosen ? 'Tổng cộng' : 'Chưa chọn sản phẩm nào',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        PriceText(cart.selectedTotal),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 168,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: chosen
                          ? () =>
                                Navigator.pushNamed(context, AppRoutes.checkout)
                          : null,
                      child: Text('Thanh toán (${cart.selectedCount})'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
