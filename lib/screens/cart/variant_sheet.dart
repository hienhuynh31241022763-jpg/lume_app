import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../product_detail/color_names.dart';

/// MH-15: đổi size, màu ngay trong giỏ. Chỉ cho chọn size còn hàng.
Future<void> showVariantSheet(BuildContext context, CartItem item) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _VariantSheet(item: item),
  );
}

class _VariantSheet extends StatefulWidget {
  const _VariantSheet({required this.item});

  final CartItem item;

  @override
  State<_VariantSheet> createState() => _VariantSheetState();
}

class _VariantSheetState extends State<_VariantSheet> {
  late String _size = widget.item.size;
  late String _color = widget.item.color;

  BorderSide _border(bool selected) => BorderSide(
    color: selected ? AppColors.rose : AppColors.line,
    width: selected ? 1.6 : 1,
  );

  @override
  Widget build(BuildContext context) {
    final product = widget.item.product;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (product.colors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Màu sắc', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in product.colors)
                    ChoiceChip(
                      selected: c == _color,
                      onSelected: (_) => setState(() => _color = c),
                      avatar: CircleAvatar(
                        radius: 7,
                        backgroundColor: colorFromName(c),
                      ),
                      label: Text(c),
                      selectedColor: AppColors.blush,
                      showCheckmark: false,
                      side: _border(c == _color),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Size', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in product.sizes)
                  ChoiceChip(
                    selected: s == _size,
                    onSelected: (_) => setState(() => _size = s),
                    label: Text(s),
                    selectedColor: AppColors.blush,
                    showCheckmark: false,
                    side: _border(s == _size),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().changeVariant(
                    widget.item,
                    size: _size,
                    color: _color,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
