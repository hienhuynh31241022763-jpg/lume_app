import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lume_app/providers/notification_provider.dart';
import 'package:lume_app/providers/product_provider.dart';
import 'package:lume_app/routes/app_routes.dart';
import 'package:lume_app/screens/about/about_screen.dart';
import 'package:lume_app/screens/help/help_screen.dart';
import 'package:lume_app/screens/news/news_screen.dart';
import 'package:lume_app/screens/notifications/notifications_screen.dart';

void main() {
  testWidgets('notifications filter workbook data and mark items read', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final provider = NotificationProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đơn hàng đã được xác nhận'), findsOneWidget);
    expect(find.text('Giảm 20% toàn bộ sandal'), findsOneWidget);
    expect(provider.unreadCount, 10);

    await tester.tap(find.text('Khuyến mãi'));
    await tester.pumpAndSettle();
    expect(find.text('Giảm 20% toàn bộ sandal'), findsOneWidget);
    expect(find.text('Đơn hàng đã được xác nhận'), findsNothing);

    await tester.tap(find.text('Giảm 20% toàn bộ sandal'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(
          'Săn ngay sandal mùa hè với ưu đãi giảm 20%, áp dụng đến hết tuần này.',
        ),
      ),
      findsOneWidget,
    );
    expect(provider.unreadCount, 9);
    Navigator.of(tester.element(find.byType(BottomSheet))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đọc tất cả'));
    await tester.pumpAndSettle();
    expect(provider.unreadCount, 0);
    expect(find.text('Đọc tất cả'), findsNothing);
  });

  testWidgets('news topics filter articles and reader shows related products', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProductProvider(),
        child: const MaterialApp(home: NewsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BÀI NỔI BẬT'), findsOneWidget);
    await tester.tap(find.text('Chăm sóc'));
    await tester.pumpAndSettle();
    expect(find.text('Bí quyết chăm sóc giày để luôn như mới'), findsOneWidget);
    expect(
      find.text('Sandal nào phù hợp cho những chuyến đi cuối tuần?'),
      findsNothing,
    );

    await tester.tap(find.text('Bí quyết chăm sóc giày để luôn như mới'));
    await tester.pumpAndSettle();
    expect(find.text('Gợi ý dành cho bạn'), findsOneWidget);
  });

  testWidgets('unanswered help search opens contact tab in About LUME', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: const HelpScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.about) {
            return MaterialPageRoute<void>(
              builder: (_) => AboutScreen(
                initialTab: settings.arguments is int
                    ? settings.arguments! as int
                    : 0,
              ),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Làm thế nào để tôi chọn được size giày vừa vặn nhất tại LUMÉ?',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Thời gian giao hàng mất bao lâu và phí vận chuyển tính thế nào?',
      ),
      findsOneWidget,
    );
    expect(find.text('Size và sản phẩm'), findsWidgets);
    await tester.enterText(
      find.byType(TextField).first,
      'cau hoi khong ton tai',
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa tìm thấy câu trả lời phù hợp?'), findsOneWidget);
    await tester.tap(find.text('Chuyển đến tab Liên hệ'));
    await tester.pumpAndSettle();

    expect(find.text('Hotline hỗ trợ'), findsOneWidget);
    expect(find.textContaining('1900 1234'), findsOneWidget);
    expect(find.textContaining('thông tin mẫu'), findsNothing);
    expect(find.text('Gửi câu hỏi cho LUMÉ'), findsOneWidget);
  });

  testWidgets('exchange request validates fields and confirms demo request', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(TabBar).first,
            matching: find.text('Đổi trả'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tạo yêu cầu đổi size'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi yêu cầu'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập mã đơn hàng'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ORD-123');
    await tester.enterText(find.byType(TextFormField).at(1), '0900000000');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đổi size').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gửi yêu cầu'));
    await tester.tap(find.text('Gửi yêu cầu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Đã ghi nhận yêu cầu EX-'), findsOneWidget);
  });

  testWidgets('About LUME contact form reports required fields', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: AboutScreen(initialTab: 1)),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      isEmpty,
    );
    await tester.ensureVisible(find.text('Gửi câu hỏi'));
    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.tap(find.text('Gửi câu hỏi'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập nội dung câu hỏi'), findsOneWidget);
  });

  testWidgets('About story presents the promised brand information', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Chuẩn size'), findsOneWidget);
    expect(find.text('Đổi trả 7 ngày'), findsOneWidget);
    expect(find.text('120+'), findsOneWidget);
    expect(find.text('35–40'), findsOneWidget);
    await tester.tap(find.text('Liên hệ với LUMÉ'));
    await tester.pumpAndSettle();
    expect(find.text('LUMÉ luôn sẵn sàng hỗ trợ bạn'), findsOneWidget);
    expect(find.text('cskh@lume.vn'), findsOneWidget);
    expect(find.text('LUMÉ Official'), findsOneWidget);
    expect(find.text('12 Đường số 5, Q.1'), findsOneWidget);
  });
}
