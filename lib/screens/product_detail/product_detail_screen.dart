import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../cart/cart_screen.dart';
import '../home/category_emoji.dart';
import '../home/demo_data.dart';
import '../size_guide/saved_size.dart';
import 'color_names.dart';
import 'product_route.dart';

/// Chi tiết sản phẩm (theo prototype màn 05)
/// - MH-10 (Uyên): tên, đánh giá, giá, % giảm, nhãn, mô tả, thanh nút dưới.
/// - MH-12 (Uyên): chọn màu, chọn size, size hết hàng bị khóa.
/// - MH-13 (Uyên): bắt buộc chọn size, thêm vào giỏ, Mua ngay.
/// - HT-18 (Uyên): ảnh bay từ thẻ sang (Hero), xem product_route.dart.
///
/// Làm sau:
/// - MH-14 (Giang): đánh giá.
/// - HT-19 (Hạo): hiệu ứng giày bay vào giỏ, gọi trong [_addToCart].
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroTag,
  });

  final String productId;

  /// Có khi mở từ thẻ sản phẩm bằng openProductDetail (HT-18).
  /// Mở bằng AppRoutes.productDetail thì null, không có hiệu ứng bay.
  final String? heroTag;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  /// Size của cả hãng. Size không có trong product.sizes = hết hàng.
  static const allSizes = ['35', '36', '37', '38', '39', '40'];

  String? _color;
  String? _size;
  String? _soldOutTapped; // size hết hàng vừa bấm, để hiện "Báo khi có hàng"
  bool _sizeError = false; // bấm Thêm vào giỏ khi chưa chọn size
  bool _appliedSavedSize = false;

  /// HT-06: mở Tìm size chuẩn, lưu xong thì chọn sẵn size vừa lưu.
  Future<void> _openSizeGuide(Product product) async {
    final result = await Navigator.pushNamed(context, AppRoutes.sizeGuide);
    if (!mounted || result is! String) return;
    setState(() {
      if (product.sizes.contains(result)) {
        _size = result;
        _sizeError = false;
        _soldOutTapped = null;
      } else {
        _soldOutTapped = result; // size gợi ý đã hết hàng → hiện "Báo khi có hàng"
      }
    });
  }

  /// MH-13: bắt buộc chọn size → thêm vào CartProvider → báo cho người dùng.
  /// [buyNow] = true thì thêm xong mở luôn màn Thanh toán.
  void _addToCart(Product product, {bool buyNow = false}) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    if (_size == null) {
      setState(() => _sizeError = true);
      messenger.showSnackBar(
        const SnackBar(content: Text('Bạn chọn size trước nhé')),
      );
      return;
    }

    context.read<CartProvider>().add(
      product,
      size: _size!,
      color: _color ?? '',
    );

    if (buyNow) {
      Navigator.pushNamed(context, AppRoutes.checkout);
      return;
    }

    // TODO (HT-19 · Hạo): chạy hiệu ứng giày bay vào biểu tượng giỏ ở đây.
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm vào giỏ · Size $_size'
          '${_color != null ? ' · $_color' : ''}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = productById(provider, widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: provider.isLoading
              ? const CircularProgressIndicator(color: AppColors.rose)
              : const Text('Không tìm thấy sản phẩm'),
        ),
      );
    }

    // Mặc định chọn màu đầu tiên.
    _color ??= product.colors.isNotEmpty ? product.colors.first : null;

    // HT-06: đã lưu size trong Tìm size chuẩn thì chọn sẵn nếu còn hàng.
    if (!_appliedSavedSize) {
      _appliedSavedSize = true;
      final saved = savedShoeSize.value;
      if (saved != null && product.sizes.contains(saved)) _size = saved;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _MediaArea(product: product, heroTag: widget.heroTag),
                ),
                SliverToBoxAdapter(
                  child: _ColorPicker(
                    colors: product.colors,
                    selected: _color,
                    // TODO (MH-12): đổi ảnh theo màu khi
                    // dữ liệu có ảnh riêng cho từng màu.
                    onSelect: (c) => setState(() => _color = c),
                  ),
                ),
                SliverToBoxAdapter(child: _InfoSection(product: product)),
                SliverToBoxAdapter(
                  child: _SizePicker(
                    sizes: allSizes,
                    available: product.sizes,
                    selected: _size,
                    soldOutTapped: _soldOutTapped,
                    showError: _sizeError,
                    onOpenSizeGuide: () => _openSizeGuide(product),
                    onSelect: (s) => setState(() {
                      _size = s;
                      _soldOutTapped = null;
                      _sizeError = false;
                    }),
                    onSoldOutTap: (s) => setState(() => _soldOutTapped = s),
                  ),
                ),
                SliverToBoxAdapter(child: _TagRow(product: product)),
                SliverToBoxAdapter(child: _Description(product: product)),
                // TODO (MH-14 · Giang): phần Đánh giá đặt ở đây.
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
          _BottomBar(
            onBuyNow: () => _addToCart(product, buyNow: true),
            onAddToCart: () => _addToCart(product),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Khung ảnh trên cùng + nút quay lại, giỏ ───────────────

class _MediaArea extends StatelessWidget {
  const _MediaArea({required this.product, required this.heroTag});

  final Product product;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      height: 300 + topInset,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF6DDE3), Color(0xFFFBEFF2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            top: topInset + 56,
            bottom: 12,
            child: ProductHero(
              tag: heroTag,
              child: _ProductImage(
                url: product.image,
                category: product.category,
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _RoundButton(
                  icon: Icons.arrow_back_ios_new,
                  tooltip: 'Quay lại',
                  onTap: () => Navigator.maybePop(context),
                ),
                const Spacer(),
                _RoundButton(
                  icon: Icons.share_outlined,
                  tooltip: 'Chia sẻ',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép link sản phẩm')),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _RoundButton(
                      icon: Icons.shopping_bag_outlined,
                      tooltip: 'Giỏ hàng',
                      // Mở màn Giỏ hàng của Hạo đè lên trên, bấm ← là quay lại
                      // Chi tiết. Không cần sửa MainShell.
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: -4,
                      child: _CountBadge(count: cartCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url, required this.category});

  final String url;
  final String category;

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(
      child: Text(
        emojiForCategory(category),
        style: const TextStyle(fontSize: 150),
      ),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: CircularProgressIndicator(color: AppColors.rose),
            ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.card,
        shape: const CircleBorder(),
        elevation: 1,
        shadowColor: Colors.black12,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 20, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.rose,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ───────────────────────── MH-12 · Chọn màu ─────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  final List<String> colors;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox(height: 4);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final name in colors)
                  _Swatch(
                    color: colorFromName(name),
                    selected: name == selected,
                    tooltip: name,
                    onTap: () => onSelect(name),
                  ),
              ],
            ),
          ),
          if (selected != null)
            Text(
              'Màu: $selected',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = isLightColor(color);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
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
              color: color,
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

// ───────────────────────── Tên, đánh giá, giá ─────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
              const SizedBox(width: 2),
              Text(
                product.rating > 0
                    ? product.rating.toStringAsFixed(1)
                    : 'Chưa có đánh giá',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                // TODO (MH-14): đổi thành "x đánh giá" khi có dữ liệu reviews.
                ' · ${product.category}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PriceText(
                product.price,
                style: textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              if (product.hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  formatPrice(product.oldPrice),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${product.discountPercent}%',
                    style: const TextStyle(
                      color: AppColors.roseDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── MH-12 · Chọn size ─────────────────────────

class _SizePicker extends StatelessWidget {
  const _SizePicker({
    required this.sizes,
    required this.available,
    required this.selected,
    required this.soldOutTapped,
    required this.showError,
    required this.onOpenSizeGuide,
    required this.onSelect,
    required this.onSoldOutTap,
  });

  final List<String> sizes;
  final List<String> available;
  final String? selected;
  final String? soldOutTapped;
  final bool showError;
  final VoidCallback onOpenSizeGuide;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onSoldOutTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chọn size',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onOpenSizeGuide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.straighten,
                        size: 16,
                        color: AppColors.rose,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tìm size chuẩn',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.rose,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < sizes.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SizeBox(
                    label: sizes[i],
                    soldOut: !available.contains(sizes[i]),
                    selected: sizes[i] == selected,
                    onTap: () => available.contains(sizes[i])
                        ? onSelect(sizes[i])
                        : onSoldOutTap(sizes[i]),
                  ),
                ),
              ],
            ],
          ),
          if (showError) ...[
            const SizedBox(height: 8),
            Text(
              'Vui lòng chọn size trước khi thêm vào giỏ',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          // TODO (MH-12): hiện "Size x chỉ còn y đôi" khi dữ liệu có tồn kho
          // theo từng size (hiện API chỉ có danh sách size còn hàng).
          if (soldOutTapped != null) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'LUMÉ sẽ báo bạn khi size $soldOutTapped có hàng',
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 18,
                      color: AppColors.rose,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Size $soldOutTapped hết hàng · Báo khi có hàng',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.rose,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SizeBox extends StatelessWidget {
  const _SizeBox({
    required this.label,
    required this.soldOut,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool soldOut;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? AppColors.rose : AppColors.card,
          borderRadius: radius,
          border: Border.all(
            color: selected ? AppColors.rose : AppColors.line,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (soldOut) CustomPaint(painter: _StripePainter()),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : soldOut
                        ? AppColors.muted.withValues(alpha: 0.6)
                        : AppColors.ink,
                    decoration: soldOut ? TextDecoration.lineThrough : null,
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

/// Sọc chéo mờ cho ô size hết hàng (giống prototype).
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 2;
    for (double x = -size.height; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────── Nhãn thông tin: gót, chất liệu, dịp ───────────────────

class _TagRow extends StatelessWidget {
  const _TagRow({required this.product});

  final Product product;

  String get _heelLabel {
    final h = product.heelHeight;
    if (h <= 0) return 'Đế bệt';
    final text = h == h.roundToDouble() ? h.toInt().toString() : '$h';
    return 'Gót ${text}cm';
  }

  @override
  Widget build(BuildContext context) {
    final tags = [
      _heelLabel,
      if (product.material.isNotEmpty) product.material,
      ...product.occasions,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final tag in tags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────── Mô tả ────────────────────────────────

class _Description extends StatelessWidget {
  const _Description({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.description.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            product.description,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Thanh nút dưới: Mua ngay / Thêm vào giỏ ─────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onBuyNow, required this.onAddToCart});

  final VoidCallback onBuyNow;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: shape,
                  side: const BorderSide(color: AppColors.rose, width: 1.5),
                ),
                onPressed: onBuyNow,
                child: const Text('Mua ngay'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: shape,
                ),
                onPressed: onAddToCart,
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: const Text('Thêm vào giỏ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}