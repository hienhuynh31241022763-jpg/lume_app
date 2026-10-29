import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import 'product_filter.dart';

/// MH-08 · Bộ lọc: giao diện (theo prototype màn 04)
/// Bảng trượt từ dưới lên: loại, size, màu, chiều cao gót, dịp dùng,
/// chất liệu, thanh trượt giá, công tắc giảm giá và hàng mới.
/// Số trên nút "Xem N kết quả" đổi ngay khi chọn.
///
/// Trả về bộ lọc mới khi bấm nút, trả về null khi kéo đóng.
Future<ProductFilter?> showFilterSheet(
  BuildContext context, {
  required List<Product> products,
  required ProductFilter initial,
}) {
  return showModalBottomSheet<ProductFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(products: products, initial: initial),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.products, required this.initial});

  final List<Product> products;
  final ProductFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ProductFilter _f = widget.initial;

  // Chỉ hiện lựa chọn nào có trong dữ liệu, để không bấm ra 0 kết quả vô lý.
  late final _categories = [
    ...categoryOrder.where((c) => widget.products.any((p) => p.category == c)),
    ...{
      for (final p in widget.products)
        if (!categoryOrder.contains(p.category)) p.category,
    },
  ];
  late final _sizesInStock = {for (final p in widget.products) ...p.sizes};
  late final _families = colorFamilies
      .where((f) => widget.products.any((p) => p.colors.any(f.matches)))
      .toList();
  late final _occasions = occasionOrder
      .where((o) => widget.products.any((p) => p.occasions.contains(o)))
      .toList();
  late final _materials = [
    for (final (name, _) in materialGroups)
      if (widget.products.any((p) => materialGroupsOf(p.material).contains(name)))
        name,
  ];
  late final _bounds = priceBounds(widget.products);

  void _update(ProductFilter f) => setState(() => _f = f);

  /// Khoảng giá đang chọn, kẹp trong giới hạn để thanh trượt không lỗi
  /// khi dữ liệu đổi (VD: chuyển từ dữ liệu giả lập sang API thật).
  RangeValues get _priceValues {
    final r = _f.price ?? _bounds;
    final start = r.start.clamp(_bounds.start, _bounds.end).toDouble();
    final end = r.end.clamp(start, _bounds.end).toDouble();
    return RangeValues(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = widget.products.where(_f.matches).length;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                Expanded(child: Text('Bộ lọc', style: textTheme.titleLarge)),
                TextButton(
                  onPressed: _f.isEmpty
                      ? null
                      : () => _update(const ProductFilter()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.rose,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Đặt lại'),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              children: [
                _Section(
                  title: 'Loại giày',
                  child: _ChipWrap(
                    options: _categories,
                    selected: _f.categories,
                    onTap: (v) => _update(
                      _f.copyWith(categories: toggleIn(_f.categories, v)),
                    ),
                  ),
                ),
                _Section(
                  title: 'Size',
                  child: Row(
                    children: [
                      for (var i = 0; i < allSizes.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _SizeBox(
                            label: allSizes[i],
                            enabled: _sizesInStock.contains(allSizes[i]),
                            selected: _f.sizes.contains(allSizes[i]),
                            onTap: () => _update(
                              _f.copyWith(
                                sizes: toggleIn(_f.sizes, allSizes[i]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _Section(
                  title: 'Màu sắc',
                  trailing: _f.colors.isEmpty ? null : _f.colors.join(', '),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final fam in _families)
                        _Swatch(
                          family: fam,
                          selected: _f.colors.contains(fam.name),
                          onTap: () => _update(
                            _f.copyWith(colors: toggleIn(_f.colors, fam.name)),
                          ),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Chiều cao gót',
                  child: _ChipWrap(
                    options: [for (final h in heelRanges) h.label],
                    selected: _f.heels,
                    onTap: (v) =>
                        _update(_f.copyWith(heels: toggleIn(_f.heels, v))),
                  ),
                ),
                if (_occasions.isNotEmpty)
                  _Section(
                    title: 'Dịp sử dụng',
                    child: _ChipWrap(
                      options: _occasions,
                      selected: _f.occasions,
                      onTap: (v) => _update(
                        _f.copyWith(occasions: toggleIn(_f.occasions, v)),
                      ),
                    ),
                  ),
                if (_materials.isNotEmpty)
                  _Section(
                    title: 'Chất liệu',
                    child: _ChipWrap(
                      options: _materials,
                      selected: _f.materials,
                      onTap: (v) => _update(
                        _f.copyWith(materials: toggleIn(_f.materials, v)),
                      ),
                    ),
                  ),
                _Section(
                  title: 'Khoảng giá',
                  trailing:
                      '${formatPrice(_priceValues.start.round())} – '
                      '${formatPrice(_priceValues.end.round())}',
                  child: RangeSlider(
                    values: _priceValues,
                    min: _bounds.start,
                    max: _bounds.end,
                    divisions: priceDivisions(_bounds),
                    activeColor: AppColors.rose,
                    inactiveColor: AppColors.blush,
                    labels: RangeLabels(
                      shortPrice(_priceValues.start),
                      shortPrice(_priceValues.end),
                    ),
                    onChanged: (r) {
                      final full = r.start <= _bounds.start &&
                          r.end >= _bounds.end;
                      _update(
                        full
                            ? _f.copyWith(clearPrice: true)
                            : _f.copyWith(price: r),
                      );
                    },
                  ),
                ),
                _SwitchRow(
                  label: 'Đang giảm giá',
                  value: _f.saleOnly,
                  onChanged: (v) => _update(_f.copyWith(saleOnly: v)),
                ),
                _SwitchRow(
                  label: 'Hàng mới',
                  value: _f.newOnly,
                  onChanged: (v) => _update(_f.copyWith(newOnly: v)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context, _f),
                child: Text(
                  count == 0 ? 'Không có kết quả' : 'Xem $count kết quả',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Các khối nhỏ ─────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null)
                Flexible(
                  child: Text(
                    trailing!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.rose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.options,
    required this.selected,
    required this.onTap,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          _Pill(
            label: o,
            selected: selected.contains(o),
            onTap: () => onTap(o),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.rose : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.rose : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _SizeBox extends StatelessWidget {
  const _SizeBox({
    required this.label,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 42,
        decoration: BoxDecoration(
          color: selected ? AppColors.rose : AppColors.card,
          borderRadius: radius,
          border: Border.all(color: selected ? AppColors.rose : AppColors.line),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!enabled) CustomPaint(painter: _StripePainter()),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : enabled
                        ? AppColors.ink
                        : AppColors.muted.withValues(alpha: 0.6),
                    decoration: enabled ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 2;
    for (double x = -size.height; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.family,
    required this.selected,
    required this.onTap,
  });

  final ColorFamily family;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = family.swatch.computeLuminance() > 0.6;
    return Tooltip(
      message: family.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.rose : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: family.swatch,
              shape: BoxShape.circle,
              border: light ? Border.all(color: AppColors.line) : null,
            ),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: light ? AppColors.roseDark : Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}