import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../routes/app_routes.dart';
import 'product_detail_screen.dart';

/// HT-18 · Mở Chi tiết sản phẩm với hiệu ứng chuyển trang:
/// - Ảnh trên thẻ phóng to mượt sang khung ảnh của Chi tiết (Hero).
/// - Phần còn lại của trang mờ dần hiện lên và trượt nhẹ từ dưới lên.
///
/// [heroTag] phải khác nhau giữa các mục trên cùng một màn
/// (VD: cùng 1 đôi nằm ở cả Hàng mới và Bán chạy), nên truyền kèm tên mục.
Future<void> openProductDetail(
  BuildContext context,
  Product product, {
  required String heroTag,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      // Giữ tên route như AppRoutes để nhóm theo dõi điều hướng vẫn đúng.
      settings: RouteSettings(
        name: AppRoutes.productDetail,
        arguments: product.id,
      ),
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) =>
          ProductDetailScreen(productId: product.id, heroTag: heroTag),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Bọc ảnh sản phẩm để bay giữa 2 màn. Material trong suốt giúp chữ
/// (emoji giữ chỗ) không bị gạch chân vàng trong lúc bay.
class ProductHero extends StatelessWidget {
  const ProductHero({super.key, required this.tag, required this.child});

  final String? tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (tag == null) return child;
    return Hero(
      tag: tag!,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}