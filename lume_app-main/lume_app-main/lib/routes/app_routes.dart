import 'package:flutter/material.dart';

import '../screens/about/about_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/main_shell.dart';
import '../screens/news/news_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/pin_location/pin_location_screen.dart';
import '../screens/product_detail/product_detail_screen.dart';
import '../screens/review/review_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/size_guide/size_guide_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const shell = '/shell';
  static const productDetail = '/product-detail';
  static const sizeGuide = '/size-guide';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orders = '/orders';
  static const review = '/review';
  static const scan = '/scan';
  static const pinLocation = '/pin-location';
  static const notifications = '/notifications';
  static const news = '/news';
  static const help = '/help';
  static const about = '/about';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      splash => const SplashScreen(),
      onboarding => const OnboardingScreen(),
      login => const LoginScreen(),
      register => const RegisterScreen(),
      shell => const MainShell(),
      productDetail => ProductDetailScreen(
        productId: settings.arguments as String,
      ),
      sizeGuide => const SizeGuideScreen(),
      checkout => const CheckoutScreen(),
      orderSuccess => const OrderSuccessScreen(),
      orders => const OrdersScreen(),
      review => const ReviewScreen(),
      scan => const ScanScreen(),
      pinLocation => const PinLocationScreen(),
      notifications => const NotificationsScreen(),
      news => const NewsScreen(),
      help => const HelpScreen(),
      about => const AboutScreen(),
      _ => const MainShell(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
