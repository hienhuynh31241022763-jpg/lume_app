import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../home/adaptive_image.dart';
import '../home/category_emoji.dart';
import '../home/demo_data.dart';
import '../product_detail/product_route.dart';
import 'favorites_store.dart';

/// Mở trang Tủ giày (đè lên màn hiện tại, bấm ← để quay lại).
Future<void> openShoeCloset(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ShoeClosetScreen()),
  );
}

// Màu của chiếc tủ (vật thể nên đặt riêng ở đây).
const _lacquer = Color(0xFFF2C4CF);
const _lacquerDk = Color(0xFFDFA2B3);
const _lacquerLt = Color(0xFFF8DCE3);
const _inside = Color(0xFFFFF3EE);
const _birch = Color(0xFFEAD6C0);
const _birchDk = Color(0xFFD3B898);
const _brass = Color(0xFFC9A96E);

/// Tủ giày: các đôi đã thả tim được bày lên kệ trong chiếc tủ sơn hồng.
/// Vào trang là 2 cánh tủ mở ra, đèn dưới mỗi tầng sáng lên.
class ShoeClosetScreen extends StatefulWidget {
  const ShoeClosetScreen({super.key});

  @override
  State<ShoeClosetScreen> createState() => _ShoeClosetScreenState();
}

class _ShoeClosetScreenState extends State<ShoeClosetScreen>
    with SingleTickerProviderStateMixin {
  late final _doors = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  String _filter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    FavoritesStore.load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _doors.value = 1;
      } else {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _doors.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _doors.dispose();
    super.dispose();
  }

  void _toggleDoors() {
    if (_doors.value > .5) {
      _doors.reverse();
    } else {
      _doors.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final all = productsOf(context.watch<ProductProvider>());

    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: 'Tủ ',
            children: [
              TextSpan(text: 'giày', style: TextStyle(color: AppColors.rose)),
            ],
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _doors,
            builder: (context, _) => TextButton(
              onPressed: _toggleDoors,
              child: Text(_doors.value > .5 ? 'Đóng tủ' : 'Mở tủ'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: FavoritesStore.ids,
        builder: (context, ids, _) {
          // Giữ đúng thứ tự cất vào tủ.
          final byId = {for (final p in all) p.id: p};
          final fav = [
            for (final id in ids)
              if (byId[id] != null) byId[id]!,
          ];
          final cats = ['Tất cả', ...{for (final p in fav) p.category}];
          if (!cats.contains(_filter)) _filter = 'Tất cả';
          final shown = _filter == 'Tất cả'
              ? fav
              : fav.where((p) => p.category == _filter).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            children: [
              Text(
                fav.isEmpty
                    ? 'Chưa có đôi nào trong tủ.'
                    : '${fav.length} đôi đang được cất · bấm vào một đôi để xem nhanh',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              if (fav.isNotEmpty)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final c = cats[i];
                      final n = c == 'Tất cả'
                          ? fav.length
                          : fav.where((p) => p.category == c).length;
                      final on = c == _filter;
                      return ChoiceChip(
                        label: Text('$c  $n'),
                        selected: on,
                        showCheckmark: false,
                        selectedColor: AppColors.ink,
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(
                          color: on ? Colors.white : AppColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        side: BorderSide(color: on ? AppColors.ink : AppColors.line),
                        shape: const StadiumBorder(),
                        onSelected: (_) => setState(() => _filter = c),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _Cabinet(
                    doors: _doors,
                    products: shown,
                    onOpenShoe: (p) => _showQuickView(context, p),
                    onEmptySlot: () => Navigator.maybePop(context),
                  ),
                ),
              ),
              if (fav.isEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Thả tim ở góc ảnh sản phẩm để cất giày vào đây.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Center(
                  child: OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text('Đi chọn giày'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showQuickView(BuildContext context, Product p) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _ShoePhoto(product: p),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            PriceText(p.price),
                            if (p.hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                formatPrice(p.oldPrice),
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [p.category, if (p.colors.isNotEmpty) p.colors.join(', ')].join(' · '),
                          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        FavoritesStore.toggle(p.id);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Đã lấy khỏi Tủ giày'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                      child: const Text('Lấy khỏi tủ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        openProductDetail(context, p, heroTag: 'closet-${p.id}');
                      },
                      child: const Text('Xem chi tiết'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────────────── Chiếc tủ ─────────────────────────────

class _Cabinet extends StatelessWidget {
  const _Cabinet({
    required this.doors,
    required this.products,
    required this.onOpenShoe,
    required this.onEmptySlot,
  });

  final Animation<double> doors;
  final List<Product> products;
  final ValueChanged<Product> onOpenShoe;
  final VoidCallback onEmptySlot;

  static const _perShelf = 3;

  @override
  Widget build(BuildContext context) {
    // Luôn chừa ít nhất 1 ô trống để mời chọn thêm, tối thiểu 3 tầng.
    final tiers = max(3, ((products.length + 1) / _perShelf).ceil());

    return Column(
      children: [
        // nóc tủ có chữ Lumé
        Container(
          height: 40,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14), bottom: Radius.circular(4)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_lacquerLt, _lacquer],
            ),
            boxShadow: [BoxShadow(color: _lacquerDk, offset: Offset(0, 3))],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 22, height: 1, color: _brass),
              const SizedBox(width: 8),
              Text(
                'Lumé',
                style: GoogleFonts.pinyonScript(
                  fontSize: 26,
                  height: 1,
                  color: AppColors.roseDark,
                  shadows: const [Shadow(color: Colors.white70, offset: Offset(0, 1))],
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 22, height: 1, color: _brass),
            ],
          ),
        ),
        // thân tủ (hẹp hơn nóc một chút)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: _lacquer,
            boxShadow: [
              BoxShadow(color: Color(0x40965F6E), blurRadius: 24, offset: Offset(0, 14), spreadRadius: -10),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final doorW = c.maxWidth / 2;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // lòng tủ
                  Container(
                    decoration: BoxDecoration(
                      color: _inside,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Color(0x2E784B4B), blurRadius: 14, offset: Offset(0, 6), spreadRadius: -6),
                      ],
                    ),
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        for (var t = 0; t < tiers; t++)
                          _Tier(
                            glow: doors,
                            products: [
                              for (var s = 0; s < _perShelf; s++)
                                if (t * _perShelf + s < products.length) products[t * _perShelf + s],
                            ],
                            slots: _perShelf,
                            onOpenShoe: onOpenShoe,
                            onEmptySlot: onEmptySlot,
                          ),
                      ],
                    ),
                  ),
                  // 2 cánh tủ
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: doorW,
                    child: _Door(animation: doors, left: true),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: doorW,
                    child: _Door(animation: doors, left: false),
                  ),
                ],
              );
            },
          ),
        ),
        // chân đế
        Container(
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: _lacquerDk,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 2; i++)
                Container(
                  width: 22,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: _brass,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Door extends StatelessWidget {
  const _Door({required this.animation, required this.left});

  final Animation<double> animation;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final face = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_lacquerLt, _lacquer],
          stops: [0, .6],
        ),
        border: Border.all(color: _lacquerDk),
      ),
      child: Stack(
        children: [
          // ô pano viền trong
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: _lacquerDk.withValues(alpha: .7), width: 1.5),
              ),
            ),
          ),
          // tay nắm đồng
          Align(
            alignment: left ? const Alignment(.82, 0) : const Alignment(-.82, 0),
            child: Container(
              width: 8,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB89558), Color(0xFFEBD39B), Color(0xFFB89558)],
                ),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 2))],
              ),
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(animation.value);
        // Đóng hẳn thì không cần chặn bấm; mở thì cánh không che kệ.
        return IgnorePointer(
          ignoring: t > .5,
          child: Transform(
            alignment: left ? Alignment.centerLeft : Alignment.centerRight,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0012)
              ..rotateY((left ? -1 : 1) * 1.88 * t),
            child: child,
          ),
        );
      },
      child: face,
    );
  }
}

/// Một tầng kệ: đèn ấm phía trên, 3 ô giày, thanh gỗ bên dưới.
class _Tier extends StatelessWidget {
  const _Tier({
    required this.glow,
    required this.products,
    required this.slots,
    required this.onOpenShoe,
    required this.onEmptySlot,
  });

  final Animation<double> glow;
  final List<Product> products;
  final int slots;
  final ValueChanged<Product> onOpenShoe;
  final VoidCallback onEmptySlot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        children: [
          // đèn hắt xuống từ đáy tầng trên, sáng dần khi cánh mở
          Positioned(
            left: 10,
            right: 10,
            top: 0,
            height: 90,
            child: AnimatedBuilder(
              animation: glow,
              builder: (context, _) => Opacity(
                opacity: ((glow.value - .5) * 2).clamp(0.0, 1.0),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: .9,
                      colors: [Color(0x8CFFD696), Color(0x00FFD696)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < slots; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: i < products.length
                            ? _ShoeSlot(product: products[i], onTap: () => onOpenShoe(products[i]))
                            : _EmptySlot(onTap: onEmptySlot),
                      ),
                    ],
                  ],
                ),
              ),
              // thanh gỗ
              Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_birch, _birchDk],
                  ),
                  boxShadow: const [BoxShadow(color: Color(0x2E5A321E), blurRadius: 4, offset: Offset(0, 3))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Một đôi giày trên kệ: ảnh vuông bo góc đứng trên thanh gỗ, có bóng đổ.
class _ShoeSlot extends StatelessWidget {
  const _ShoeSlot({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: product.name,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          // Giày vừa vào tủ thì rơi nhẹ xuống kệ.
          tween: Tween(begin: 0, end: 1),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, t, child) => Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(offset: Offset(0, -20 * (1 - t)), child: child),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33503238), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -2),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: 'closet-${product.id}',
                    child: _ShoePhoto(product: product),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Đi chọn thêm giày',
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _DashedRRectPainter(color: AppColors.muted.withValues(alpha: .5)),
              child: const Center(
                child: Icon(Icons.add_rounded, color: AppColors.muted, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShoePhoto extends StatelessWidget {
  const _ShoePhoto({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.blush,
      alignment: Alignment.center,
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(emojiForCategory(product.category), style: const TextStyle(fontSize: 48)),
        ),
      ),
    );
    if (product.image.isEmpty) return placeholder;
    return LayoutBuilder(
      builder: (context, c) => AdaptiveImage(
        url: product.image,
        cacheWidth: (c.maxWidth * MediaQuery.devicePixelRatioOf(context)).round(),
        placeholder: placeholder,
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) => old.color != color;
}
