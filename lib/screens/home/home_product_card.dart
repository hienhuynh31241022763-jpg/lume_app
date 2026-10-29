import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../product_detail/product_route.dart';
import 'category_emoji.dart';

/// Thẻ sản phẩm theo prototype Trang chủ: ảnh trong khung xám nhạt,
/// nhãn "Mới" / "-x%", tên, giá, số sao.
/// Dùng cho Trang chủ và kết quả Bộ lọc (phần của Uyên),
/// không đụng tới ProductCard dùng chung của nhóm.
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.heroTag,
  });

  final Product product;
  final VoidCallback? onTap;

  /// HT-18: tag để ảnh bay sang trang Chi tiết. Phải trùng với tag
  /// truyền vào openProductDetail.
  final String? heroTag;

  static const double _pad = 8;
  static const double _imageRatio = 4 / 3; // rộng : cao của khung ảnh
  static const double _textHeight = 96; // tên + giá + sao + khoảng cách

  /// Chiều cao thẻ khi biết chiều rộng, để lưới / danh sách ngang
  /// đặt đúng kích thước, không bị tràn.
  static double heightFor(double width) =>
      _pad + (width - _pad * 2) / _imageRatio + _textHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: _imageRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductHero(
                        tag: heroTag,
                        child: _LazyImage(
                          url: product.image,
                          category: product.category,
                        ),
                      ),
                      if (product.isNew || product.hasDiscount)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _Badge(
                            text: product.isNew
                                ? 'Mới'
                                : '-${product.discountPercent}%',
                            color: product.isNew
                                ? AppColors.ink
                                : AppColors.rose,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    PriceText(product.price),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating > 0
                              ? product.rating.toStringAsFixed(1)
                              : 'Chưa có',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dạng danh sách (ảnh nhỏ bên trái) cho trang kết quả Bộ lọc.
class HomeProductTile extends StatelessWidget {
  const HomeProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.heroTag,
  });

  final Product product;
  final VoidCallback? onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ProductHero(
                    tag: heroTag,
                    child: _LazyImage(
                      url: product.image,
                      category: product.category,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.category,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        if (product.isNew || product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          _Badge(
                            text: product.isNew
                                ? 'Mới'
                                : '-${product.discountPercent}%',
                            color: product.isNew
                                ? AppColors.ink
                                : AppColors.rose,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        PriceText(product.price),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            formatPrice(product.oldPrice),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        Text(
                          product.rating > 0
                              ? product.rating.toStringAsFixed(1)
                              : '–',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Ảnh tải từ mạng: chỉ tải khi thẻ được dựng (thẻ hiện trên màn hình),
/// giải mã đúng kích thước khung cho nhẹ máy, hiện mờ dần khi tải xong.
class _LazyImage extends StatelessWidget {
  const _LazyImage({required this.url, required this.category});

  final String url;
  final String category;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1EFF1);
    final placeholder = Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        emojiForCategory(category),
        style: const TextStyle(fontSize: 52),
      ),
    );
    if (url.isEmpty) return placeholder;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        return Container(
          color: bg,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            cacheWidth: (constraints.maxWidth * dpr).round(),
            errorBuilder: (_, _, _) => placeholder,
            frameBuilder: (context, child, frame, wasSync) {
              if (wasSync) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}