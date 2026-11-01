import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lume_app/screens/product_detail/product_reviews.dart';
import 'package:lume_app/screens/product_detail/product_reviews_screen.dart';

void main() {
  const reviews = [
    ProductReview(
      id: 1,
      productId: '1',
      author: 'Lan',
      rating: 5,
      fit: 'Vừa chân',
      comment: 'Mang rất vừa.',
      date: '20/10/2026',
      enteredBy: 'Giang',
    ),
    ProductReview(
      id: 2,
      productId: '1',
      author: 'Mai',
      rating: 4,
      fit: 'Hơi chật',
      comment: 'Phần mũi hơi chật.',
      date: '21/10/2026',
      enteredBy: 'Giang',
    ),
    ProductReview(
      id: 3,
      productId: '1',
      author: 'Vy',
      rating: 4,
      fit: 'Vừa chân',
      comment: 'Đúng size.',
      date: '22/10/2026',
      enteredBy: 'Giang',
    ),
  ];

  test('fit percentages are calculated from this product reviews', () {
    expect(reviewFitCount(reviews, 'Vừa chân'), 2);
    expect(reviewFitPercent(reviews, 'Vừa chân'), 67);
    expect(reviewFitPercent(reviews, 'Hơi chật'), 33);
    expect(reviewFitPercent(reviews, 'Hơi rộng'), 0);
    expect(reviewFitPercent(const [], 'Vừa chân'), 0);
  });

  testWidgets('all button fit filters reviews and returns to all', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductReviewsScreen(productName: 'Giày mẫu', reviews: reviews),
      ),
    );

    expect(find.text('67% thấy vừa chân'), findsOneWidget);
    expect(find.text('Lan'), findsOneWidget);
    expect(find.text('Mai'), findsOneWidget);
    expect(find.text('Vy'), findsOneWidget);

    final tightFilter = find.text('Hơi chật (1)');
    await tester.ensureVisible(tightFilter);
    await tester.tap(tightFilter);
    await tester.pumpAndSettle();

    expect(find.text('Mai'), findsOneWidget);
    expect(find.text('Lan'), findsNothing);
    expect(find.text('Vy'), findsNothing);

    final allFilter = find.text('Tất cả (3)');
    await tester.ensureVisible(allFilter);
    await tester.tap(allFilter);
    await tester.pumpAndSettle();

    expect(find.text('Lan'), findsOneWidget);
    expect(find.text('Mai'), findsOneWidget);
    expect(find.text('Vy'), findsOneWidget);
  });
}
