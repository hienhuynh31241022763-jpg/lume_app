import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'product_reviews.dart';

const reviewFitOptions = ['Vừa chân', 'Hơi chật', 'Hơi rộng'];

int reviewFitCount(List<ProductReview> reviews, String fit) =>
    reviews.where((review) => review.fit == fit).length;

int reviewFitPercent(List<ProductReview> reviews, String fit) {
  if (reviews.isEmpty) return 0;
  return (reviewFitCount(reviews, fit) * 100 / reviews.length).round();
}

class ProductReviewCard extends StatelessWidget {
  const ProductReviewCard({required this.review, super.key});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.author,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                review.date,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
              const SizedBox(width: 8),
              Text(
                review.fit,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          if (review.imageCount > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: AppColors.roseDark,
                    size: 22,
                  ),
                  SizedBox(height: 3),
                  Text('Ảnh', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({
    required this.productName,
    required this.reviews,
    super.key,
  });

  final String productName;
  final List<ProductReview> reviews;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  String? _selectedFit;

  @override
  Widget build(BuildContext context) {
    final reviews = widget.reviews;
    final visibleReviews = _selectedFit == null
        ? reviews
        : reviews.where((review) => review.fit == _selectedFit).toList();
    final rating = averageRatingOf(reviews);

    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá sản phẩm')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating?.toStringAsFixed(1) ?? '—',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${reviews.length} đánh giá',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProductFitSummary(reviews: reviews),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FitFilterChip(
                  label: 'Tất cả',
                  count: reviews.length,
                  selected: _selectedFit == null,
                  onTap: () => setState(() => _selectedFit = null),
                ),
                for (final fit in reviewFitOptions)
                  _FitFilterChip(
                    label: fit,
                    count: reviewFitCount(reviews, fit),
                    selected: _selectedFit == fit,
                    onTap: () => setState(() => _selectedFit = fit),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visibleReviews.isEmpty
                ? Center(
                    child: Text(
                      reviews.isEmpty
                          ? 'Sản phẩm chưa có đánh giá'
                          : 'Chưa có đánh giá theo lựa chọn này',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    children: [
                      for (final review in visibleReviews)
                        ProductReviewCard(review: review),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class ProductFitSummary extends StatelessWidget {
  const ProductFitSummary({required this.reviews, super.key});

  final List<ProductReview> reviews;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final justRightPercent = reviewFitPercent(reviews, 'Vừa chân');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten, size: 18, color: AppColors.roseDark),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Độ vừa chân',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$justRightPercent% thấy vừa chân',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final fit in reviewFitOptions) ...[
            if (fit != reviewFitOptions.first) const SizedBox(height: 9),
            _FitBar(reviews: reviews, fit: fit),
          ],
        ],
      ),
    );
  }
}

class _FitBar extends StatelessWidget {
  const _FitBar({required this.reviews, required this.fit});

  final List<ProductReview> reviews;
  final String fit;

  @override
  Widget build(BuildContext context) {
    final count = reviewFitCount(reviews, fit);
    final percent = reviewFitPercent(reviews, fit);

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            fit,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: reviews.isEmpty ? 0 : count / reviews.length,
              minHeight: 6,
              backgroundColor: AppColors.line,
              color: AppColors.rose,
            ),
          ),
        ),
        SizedBox(
          width: 54,
          child: Text(
            '$percent% ($count)',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _FitFilterChip extends StatelessWidget {
  const _FitFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.blush,
        side: BorderSide(color: selected ? AppColors.rose : AppColors.line),
        labelStyle: TextStyle(
          color: selected ? AppColors.roseDark : AppColors.ink,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
