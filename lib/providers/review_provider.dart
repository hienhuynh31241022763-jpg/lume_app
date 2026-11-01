import 'package:flutter/foundation.dart';

import '../screens/product_detail/product_reviews.dart';

class ReviewProvider extends ChangeNotifier {
  final List<ProductReview> _reviews = [...productReviews];

  List<ProductReview> forProduct(String productId) => List.unmodifiable([
    for (final review in _reviews)
      if (review.productId == productId) review,
  ]);

  bool hasReviewForOrderItem(String orderId, String productId) => _reviews.any(
    (review) => review.orderId == orderId && review.productId == productId,
  );

  ProductReview submit({
    required String productId,
    required String author,
    required int rating,
    required String fit,
    required String comment,
    required int imageCount,
    required String orderId,
    String enteredBy = 'Bạn',
  }) {
    final now = DateTime.now();
    final review = ProductReview(
      id: now.microsecondsSinceEpoch,
      productId: productId,
      author: author.trim().isEmpty ? 'Khách hàng' : author.trim(),
      rating: rating,
      fit: fit,
      comment: comment.trim(),
      date:
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/${now.year}',
      enteredBy: enteredBy,
      imageCount: imageCount,
      orderId: orderId,
    );
    _reviews.insert(0, review);
    notifyListeners();
    return review;
  }
}
