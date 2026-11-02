import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../filter/filter_results_screen.dart';
import '../home/demo_data.dart';
import '../product_detail/product_route.dart';
import 'search_history.dart';
import 'search_suggestions.dart';

/// MH-07 · Tìm kiếm
/// - Tìm theo tên sản phẩm (cả loại giày, chất liệu), gợi ý từ khoá khi gõ.
/// - Lịch sử tìm kiếm: bấm để tìm lại, × để xóa từng mục.
/// - Bấm tìm thì mở trang kết quả của Bộ lọc (Uyên) kèm từ khoá,
///   ở đó lọc 8 nhóm, sắp xếp, đổi lưới / danh sách.
/// - Nút quét mã trong ô tìm kiếm (HT-07).
/// Chạy được cả khi là tab của MainShell lẫn khi được push (có nút ←).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    loadSearchHistory();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _search(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.text = q;
    addSearch(q);
    openFilterResults(context, title: 'Tìm kiếm', query: q);
  }

  void _openProduct(Product p) {
    FocusManager.instance.primaryFocus?.unfocus();
    addSearch(_controller.text);
    openProductDetail(context, p, heroTag: 'search-${p.id}');
  }

  @override
  Widget build(BuildContext context) {
    final pushed = Navigator.canPop(context);
    final products = productsOf(context.watch<ProductProvider>());
    final query = _controller.text;
    final keywords = popularKeywords(products);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pushed ? 4 : 16, 8, 16, 8),
              child: Row(
                children: [
                  if (pushed)
                    IconButton(
                      tooltip: 'Quay lại',
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: pushed,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _search,
                      decoration: InputDecoration(
                        hintText: 'Tìm giày cao gót, sneaker…',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        suffixIcon: query.isEmpty
                            ? IconButton(
                                tooltip: 'Quét mã sản phẩm',
                                icon: const Icon(Icons.qr_code_scanner),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.scan,
                                ),
                              )
                            : IconButton(
                                tooltip: 'Xóa',
                                icon: const Icon(Icons.close),
                                onPressed: _controller.clear,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.rose,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final q = query.trim();
                        if (q.isNotEmpty) addSearch(q);
                        openFilterResults(
                          context,
                          title: 'Tìm kiếm',
                          query: q,
                          openSheet: true,
                        );
                      },
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.filter_list, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.trim().isEmpty
                  ? SearchStart(keywords: keywords, onSearch: _search)
                  : SearchSuggestions(
                      query: query,
                      products: products
                          .where((p) => matchesQuery(p, query))
                          .toList(),
                      keywords: keywords,
                      onSearch: _search,
                      onOpenProduct: _openProduct,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
