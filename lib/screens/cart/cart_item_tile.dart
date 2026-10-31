import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../home/adaptive_image.dart';
import '../home/category_emoji.dart';
import '../product_detail/color_names.dart';
import 'variant_sheet.dart';

/// Ảnh giày nhỏ bo góc, thiếu ảnh thì hiện emoji theo danh mục.
/// Dùng ở dòng giỏ hàng và ảnh bay vào giỏ (HT-19).
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.url,
    required this.category,
    this.size = 72,
  });

  final String url;
  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.18),
      child: SizedBox.square(
        dimension: size,
        child: AdaptiveImage(
          url: url,
          cacheWidth: (size * 3).round(),
          fallbackColor: AppColors.blush,
          padding: EdgeInsets.all(size * 0.06),
          placeholder: Container(
            color: AppColors.blush,
            alignment: Alignment.center,
            child: Text(
              emojiForCategory(category),
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// MH-15: một dòng trong giỏ. Vuốt sang trái để xóa, có Hoàn tác.
class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  void _delete(BuildContext context) {
    final cart = context.read<CartProvider>();
    final removed = item;
    cart.remove(removed);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${removed.product.name}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => cart.add(
              removed.product,
              size: removed.size,
              color: removed.color,
              quantity: removed.quantity,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = item.product;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey('${product.id}|${item.size}|${item.color}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ProductThumb(url: product.image, category: product.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _VariantChip(
                        label: 'Size ${item.size}',
                        onTap: () => showVariantSheet(context, item),
                      ),
                      if (item.color.isNotEmpty)
                        _VariantChip(
                          label: item.color,
                          dot: colorFromName(item.color),
                          onTap: () => showVariantSheet(context, item),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: PriceText(product.price)),
                      _Stepper(
                        quantity: item.quantity,
                        // Về 1 thì khóa nút −, muốn xóa thì vuốt.
                        onMinus: item.quantity > 1
                            ? () => cart.decrease(item)
                            : null,
                        onPlus: () => cart.increase(item),
                      ),
                    ],
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

class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.label, required this.onTap, this.dot});

  final String label;
  final VoidCallback onTap;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(label, style: const TextStyle(fontSize: 12)),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, tooltip: 'Giảm', onTap: onMinus),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.add, tooltip: 'Tăng', onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      color: AppColors.ink,
      disabledColor: AppColors.line,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
    );
  }
}
