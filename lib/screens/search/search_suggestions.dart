import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../cart/cart_item_tile.dart';
import '../filter/filter_results_screen.dart';
import 'search_history.dart';

/// Từ khoá gợi ý sẵn. Chỉ hiện từ nào có ít nhất 1 sản phẩm khớp.
const _popularKeywords = [
  'Cao gót',
  'Sneaker',
  'Sandal',
  'Boots',
  'Búp bê',
  'Mules',
  'Da lộn',
  'Satin',
  'Da bò',
];

List<String> popularKeywords(List<Product> products) => [
  for (final k in _popularKeywords)
    if (products.any((p) => matchesQuery(p, k))) k,
];

/// MH-07 · Lúc chưa gõ: tìm kiếm gần đây và từ khoá phổ biến.
class SearchStart extends StatelessWidget {
  const SearchStart({
    super.key,
    required this.keywords,
    required this.onSearch,
  });

  final List<String> keywords;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ValueListenableBuilder<List<String>>(
      valueListenable: searchHistory,
      builder: (context, history, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          if (history.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text('Tìm kiếm gần đây', style: textTheme.titleSmall),
                ),
                TextButton(
                  onPressed: clearSearchHistory,
                  style: TextButton.styleFrom(foregroundColor: AppColors.rose),
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
            for (final q in history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.history, color: AppColors.muted),
                title: Text(q),
                trailing: IconButton(
                  tooltip: 'Xóa khỏi lịch sử',
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.muted,
                  onPressed: () => removeSearch(q),
                ),
                onTap: () => onSearch(q),
              ),
            const SizedBox(height: 12),
          ],
          Text('Từ khoá phổ biến', style: textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in keywords)
                ActionChip(
                  avatar: const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.rose,
                  ),
                  label: Text(k),
                  onPressed: () => onSearch(k),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// MH-07 · Đang gõ: gợi ý từ khoá và sản phẩm khớp, phần khớp in đậm.
class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({
    super.key,
    required this.query,
    required this.products,
    required this.keywords,
    required this.onSearch,
    required this.onOpenProduct,
  });

  final String query;

  /// Sản phẩm đã lọc theo [query].
  final List<Product> products;
  final List<String> keywords;
  final ValueChanged<String> onSearch;
  final ValueChanged<Product> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final words = [
      for (final k in {...keywords, ...searchHistory.value})
        if (k.toLowerCase().contains(q) && k.toLowerCase() != q) k,
    ].take(3);

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        for (final w in words)
          ListTile(
            dense: true,
            leading: const Icon(Icons.search, color: AppColors.muted),
            title: _Highlight(text: w, query: q),
            trailing: const Icon(Icons.north_west, size: 16),
            onTap: () => onSearch(w),
          ),
        for (final p in products.take(5))
          ListTile(
            leading: ProductThumb(url: p.image, category: p.category, size: 44),
            title: _Highlight(text: p.name, query: q),
            subtitle: Text(
              formatPrice(p.price),
              style: const TextStyle(color: AppColors.roseDark),
            ),
            onTap: () => onOpenProduct(p),
          ),
        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Chưa có sản phẩm nào khớp "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          )
        else
          ListTile(
            leading: const Icon(Icons.arrow_forward, color: AppColors.rose),
            title: Text(
              'Xem tất cả ${products.length} kết quả cho "${query.trim()}"',
              style: const TextStyle(
                color: AppColors.rose,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => onSearch(query),
          ),
      ],
    );
  }
}

/// In đậm phần khớp [query] (không phân biệt hoa thường).
class _Highlight extends StatelessWidget {
  const _Highlight({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final start = text.toLowerCase().indexOf(query);
    if (query.isEmpty || start < 0) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    final end = start + query.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
