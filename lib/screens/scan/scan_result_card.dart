import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../cart/cart_item_tile.dart';

/// HT-07 · Thẻ kết quả sau khi quét: sản phẩm tìm được, hoặc báo mã lạ.
class ScanResultCard extends StatelessWidget {
  const ScanResultCard({
    super.key,
    required this.code,
    required this.product,
    required this.onAgain,
    required this.onOpen,
  });

  /// Nội dung mã đọc được.
  final String code;

  /// null = mã không phải của LUMÉ hoặc không có sản phẩm này.
  final Product? product;
  final VoidCallback onAgain;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 18)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (p != null)
                ProductThumb(url: p.image, category: p.category, size: 64)
              else
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.blush,
                  child: Icon(Icons.search_off, color: AppColors.roseDark),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã nhận diện mã $code',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      p?.name ?? 'Không tìm thấy sản phẩm',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    if (p != null)
                      PriceText(p.price)
                    else
                      Text(
                        'Mã này không phải mã sản phẩm LUMÉ',
                        style: textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAgain,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                  ),
                  child: const Text('Quét lại'),
                ),
              ),
              if (p != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpen,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                    child: const Text('Xem chi tiết'),
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
