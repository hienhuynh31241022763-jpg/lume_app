import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../home/demo_data.dart';
import '../home/home_product_card.dart';
import '../product_detail/product_route.dart';
import 'filter_sheet.dart';
import 'product_filter.dart';

/// MH-06 / MH-09 · Trang kết quả lọc
/// Mở từ Trang chủ: bấm danh mục, "Xem tất cả", hoặc nút lọc.
/// Có chip đang chọn (bấm × để bỏ), đếm kết quả, sắp xếp,
/// đổi kiểu lưới / danh sách.
Future<void> openFilterResults(
  BuildContext context, {
  String title = 'Tất cả sản phẩm',
  ProductFilter filter = const ProductFilter(),
  SortOption sort = SortOption.popular,
  bool openSheet = false,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FilterResultsScreen(
        title: title,
        initialFilter: filter,
        initialSort: sort,
        openSheetOnStart: openSheet,
      ),
    ),
  );
}

class FilterResultsScreen extends StatefulWidget {
  const FilterResultsScreen({
    super.key,
    this.title = 'Tất cả sản phẩm',
    this.initialFilter = const ProductFilter(),
    this.initialSort = SortOption.popular,
    this.openSheetOnStart = false,
  });

  final String title;
  final ProductFilter initialFilter;
  final SortOption initialSort;
  final bool openSheetOnStart;

  @override
  State<FilterResultsScreen> createState() => _FilterResultsScreenState();
}

class _FilterResultsScreenState extends State<FilterResultsScreen> {
  late ProductFilter _filter = widget.initialFilter;
  late SortOption _sort = widget.initialSort;
  bool _grid = true;

  @override
  void initState() {
    super.initState();
    if (widget.openSheetOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openSheet());
    }
  }

  Future<void> _openSheet() async {
    final products = productsOf(context.read<ProductProvider>());
    final result = await showFilterSheet(
      context,
      products: products,
      initial: _filter,
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  void _open(Product p) =>
      openProductDetail(context, p, heroTag: 'filter-${p.id}');

  @override
  Widget build(BuildContext context) {
    final products = productsOf(context.watch<ProductProvider>());
    final results = _filter.apply(products, _sort);
    final chips = _filter.chips;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Đầu trang: quay lại, tiêu đề, nút lọc có số bộ lọc ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  _FilterButton(
                    count: _filter.activeCount,
                    onTap: _openSheet,
                  ),
                ],
              ),
            ),

            // ── Chip đang chọn ──
            if (chips.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  itemCount: chips.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i == chips.length) {
                      return TextButton(
                        onPressed: () =>
                            setState(() => _filter = const ProductFilter()),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.rose,
                        ),
                        child: const Text('Xoá hết'),
                      );
                    }
                    final chip = chips[i];
                    return InputChip(
                      label: Text(chip.label),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      backgroundColor: AppColors.roseDark,
                      side: BorderSide.none,
                      deleteIconColor: Colors.white,
                      onDeleted: () =>
                          setState(() => _filter = chip.withoutIt),
                    );
                  },
                ),
              ),

            // ── Đếm kết quả, sắp xếp, đổi kiểu hiển thị ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${results.length} sản phẩm',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  PopupMenuButton<SortOption>(
                    initialValue: _sort,
                    onSelected: (s) => setState(() => _sort = s),
                    itemBuilder: (_) => [
                      for (final s in SortOption.values)
                        PopupMenuItem(value: s, child: Text(s.label)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swap_vert,
                            size: 18,
                            color: AppColors.rose,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _sort.label,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.rose,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _grid ? 'Xem dạng danh sách' : 'Xem dạng lưới',
                    icon: Icon(
                      _grid ? Icons.view_agenda_outlined : Icons.grid_view,
                      color: AppColors.ink,
                    ),
                    onPressed: () => setState(() => _grid = !_grid),
                  ),
                ],
              ),
            ),

            // ── Kết quả ──
            Expanded(
              child: results.isEmpty
                  ? _EmptyView(
                      onReset: () =>
                          setState(() => _filter = const ProductFilter()),
                    )
                  : _grid
                  ? _ResultGrid(products: results, onTap: _open)
                  : _ResultList(products: results, onTap: _open),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.rose,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.filter_list, color: Colors.white),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResultGrid extends StatelessWidget {
  const _ResultGrid({required this.products, required this.onTap});

  final List<Product> products;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const gap = 12.0;
        final cellWidth = (constraints.maxWidth - padding * 2 - gap) / 2;
        // GridView.builder chỉ dựng thẻ đang hiện → ảnh tải dần (lazy load).
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(padding, 4, padding, 24),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: HomeProductCard.heightFor(cellWidth),
          ),
          itemBuilder: (context, i) => HomeProductCard(
            product: products[i],
            heroTag: 'filter-${products[i].id}',
            onTap: () => onTap(products[i]),
          ),
        );
      },
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.products, required this.onTap});

  final List<Product> products;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => HomeProductTile(
        product: products[i],
        heroTag: 'filter-${products[i].id}',
        onTap: () => onTap(products[i]),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥿', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'Chưa có đôi nào khớp bộ lọc',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Thử bỏ bớt vài lựa chọn nhé',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            child: OutlinedButton(
              onPressed: onReset,
              child: const Text('Đặt lại bộ lọc'),
            ),
          ),
        ],
      ),
    );
  }
}