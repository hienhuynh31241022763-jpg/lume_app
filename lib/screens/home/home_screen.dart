import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../menu/app_drawer.dart';
import '../filter/filter_results_screen.dart';
import '../filter/product_filter.dart';
import '../product_detail/product_route.dart';
import '../search/search_screen.dart';
import 'category_emoji.dart';
import 'demo_data.dart';
import 'home_product_card.dart';

/// MH-05 · Trang chủ: giao diện (theo prototype màn 03)
/// Lời chào + ☰ + chuông, thanh tìm kiếm có nút quét mã và bộ lọc,
/// banner flash sale đếm ngược, danh mục dạng icon,
/// Hàng mới (lướt ngang), Bán chạy (lưới 2 cột).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// HT-18: tag Hero theo mục, vì 1 đôi có thể nằm ở cả Hàng mới và Bán chạy.
  static String heroTagFor(String section, Product p) => 'home-$section-${p.id}';

  void _openProduct(BuildContext context, Product product, String section) {
    openProductDetail(
      context,
      product,
      heroTag: heroTagFor(section, product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = productsOf(provider);
    // Danh mục theo thứ tự như prototype (Cao gót, Sneaker, Sandal…),
    // loại lạ (nếu có) xếp cuối.
    final found = products.map((p) => p.category).toSet();
    final categories = [
      ...categoryOrder.where(found.contains),
      ...found.where((c) => !categoryOrder.contains(c)),
    ];

    // Hàng mới: các đôi isNew = true. Chưa có thì lấy 8 đôi đầu cho khỏi trống.
    final newArrivals = products.where((p) => p.isNew).toList();
    final newList = newArrivals.isEmpty
        ? products.take(8).toList()
        : newArrivals;

    // Bán chạy: chưa có trường số lượng bán nên tạm xếp theo đánh giá.
    final bestSellers = [...products]
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.rose,
          onRefresh: () => provider.load(force: true),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _HomeHeader()),
              const SliverToBoxAdapter(child: _SearchBox()),
              const SliverToBoxAdapter(child: _FlashSaleBanner()),
              SliverToBoxAdapter(
                child: _CategoryRow(categories: categories),
              ),
              if (provider.isLoading && products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.rose),
                  ),
                )
              else if (provider.error != null && products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    message: provider.error!,
                    onRetry: () => provider.load(force: true),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: _SectionTitle(
                    'Hàng mới',
                    onMore: () => openFilterResults(
                      context,
                      title: 'Hàng mới',
                      filter: const ProductFilter(newOnly: true),
                      sort: SortOption.newest,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _HorizontalProducts(
                    products: newList,
                    onTap: (p) => _openProduct(context, p, 'new'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionTitle(
                    'Bán chạy',
                    onMore: () => openFilterResults(
                      context,
                      title: 'Bán chạy',
                      sort: SortOption.bestSeller,
                    ),
                  ),
                ),
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    const padding = 16.0;
                    const gap = 12.0;
                    final cellWidth =
                        (constraints.crossAxisExtent - padding * 2 - gap) / 2;
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        padding,
                        0,
                        padding,
                        24,
                      ),
                      // .builder chỉ dựng thẻ đang hiện trên màn hình,
                      // nên ảnh được tải dần khi cuộn tới (lazy load).
                      sliver: SliverGrid.builder(
                        itemCount: bestSellers.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: gap,
                              mainAxisSpacing: gap,
                              mainAxisExtent: HomeProductCard.heightFor(
                                cellWidth,
                              ),
                            ),
                        itemBuilder: (context, i) => HomeProductCard(
                          product: bestSellers[i],
                          heroTag: heroTagFor('best', bestSellers[i]),
                          onTap: () =>
                              _openProduct(context, bestSellers[i], 'best'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Nút tròn trắng dùng lại ─────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

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
            child: Icon(icon, color: AppColors.ink, size: 22),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Lời chào + ☰ + chuông ─────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  // TODO: lấy số thông báo chưa đọc khi Giang làm xong Thông báo (HT-09).
  static const _unread = 3;

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().name;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.menu,
            tooltip: 'Menu',
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào,',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _CircleButton(
                icon: Icons.notifications_none,
                tooltip: 'Thông báo',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
              if (_unread > 0)
                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.rose,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      '$_unread',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────── Thanh tìm kiếm + nút quét mã + nút bộ lọc ───────────────

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  Widget _square({
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black12,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  // Mở thẳng màn Tìm kiếm của Hạo đè lên Trang chủ, bấm ← là
                  // quay lại. Khi Hiền cho đổi tab trong MainShell thì có thể
                  // đổi sang chuyển tab.
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.muted),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tìm giày, kiểu dáng…',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _square(
                icon: Icons.qr_code_scanner,
                bg: AppColors.blush,
                fg: AppColors.roseDark,
                onTap: () => Navigator.pushNamed(context, AppRoutes.scan),
              ),
              const SizedBox(width: 8),
              _square(
                icon: Icons.filter_list,
                bg: AppColors.rose,
                fg: Colors.white,
                // MH-06: mở trang kết quả và bật luôn bảng Bộ lọc.
                onTap: () => openFilterResults(context, openSheet: true),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────── Banner flash sale + đếm ngược ─────────────────────

class _FlashSaleBanner extends StatelessWidget {
  const _FlashSaleBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFC97A8E), AppColors.roseDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ảnh nền banner: assets/images/anhnentrangchu.jpg
          // (thư mục assets/images/ đã khai báo sẵn trong pubspec.yaml).
          // Ảnh phủ kín khung, canh phải để chiếc giày luôn nằm bên phải.
          // Chưa có file ảnh thì tạm hiện emoji, app không bị lỗi.
          Positioned.fill(
            child: Image.asset(
              'assets/images/anhnentrangchu.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, _, _) => const Align(
                alignment: Alignment.bottomRight,
                child: Text('👠', style: TextStyle(fontSize: 120)),
              ),
            ),
          ),
          // Lớp hồng mờ dần từ trái sang phải để chữ trắng dễ đọc.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.roseDark.withValues(alpha: 0.92),
                    AppColors.rose.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.45, 0.8],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FLASH SALE',
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Giảm đến 50%',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const _Countdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Đồng hồ đếm ngược tới 0h đêm nay, chạy thật mỗi giây.
class _Countdown extends StatefulWidget {
  const _Countdown();

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day + 1);
    setState(() => _left = end.difference(now));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _box(int value) {
    return Container(
      width: 34,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value.toString().padLeft(2, '0'),
        style: const TextStyle(
          color: AppColors.roseDark,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colon = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _box(_left.inHours),
        colon,
        _box(_left.inMinutes % 60),
        colon,
        _box(_left.inSeconds % 60),
      ],
    );
  }
}

// ───────────────────────── Danh mục dạng icon ─────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox(height: 12);
    final labelStyle = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      // Chia đều bề ngang cho tất cả danh mục để không mục nào bị tràn
      // ra ngoài màn hình. Vòng tròn tự nhỏ lại nếu màn hình hẹp.
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 6.0;
          final n = categories.length;
          final itemWidth = (constraints.maxWidth - gap * (n - 1)) / n;
          final circle = itemWidth.clamp(40.0, 58.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < n; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    // MH-06: bấm danh mục thì mở kết quả lọc sẵn theo loại này.
                    onTap: () => openFilterResults(
                      context,
                      title: categories[i],
                      filter: ProductFilter(categories: {categories[i]}),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: circle,
                          height: circle,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                          ),
                          child: CategoryIcon(
                            category: categories[i],
                            size: circle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shortCategoryLabel(categories[i]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle?.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────── Tiêu đề mỗi mục ────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.onMore});

  final String title;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onMore,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.rose,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Xem tất cả'),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Hàng mới (lướt ngang) ─────────────────────────

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts({required this.products, required this.onTap});

  final List<Product> products;
  final ValueChanged<Product> onTap;

  static const double _cardWidth = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeProductCard.heightFor(_cardWidth),
      // ListView.separated chỉ dựng thẻ đang hiện → lazy load khi lướt.
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(
          width: _cardWidth,
          child: HomeProductCard(
            product: products[i],
            heroTag: HomeScreen.heroTagFor('new', products[i]),
            onTap: () => onTap(products[i]),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────── Báo lỗi tải ──────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }
}