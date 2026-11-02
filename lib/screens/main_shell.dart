import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const homeTab = 0;

  /// Tab đang chọn. Màn khác muốn chuyển tab thì gọi [selectTab]
  /// (VD: Đặt hàng thành công → "Tiếp tục mua sắm" về Trang chủ).
  static final _tab = ValueNotifier<int>(homeTab);

  static void selectTab(int index) => _tab.value = index;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = MainShell.homeTab;

  @override
  void initState() {
    super.initState();
    MainShell._tab.value = MainShell.homeTab;
    MainShell._tab.addListener(_syncTab);
  }

  @override
  void dispose() {
    MainShell._tab.removeListener(_syncTab);
    super.dispose();
  }

  void _syncTab() => setState(() => _index = MainShell._tab.value);

  static const _pages = [
    HomeScreen(),
    SearchScreen(),
    SizedBox.shrink(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    if (i == 2) {
      Navigator.pushNamed(context, AppRoutes.scan);
      return;
    }
    MainShell._tab.value = i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          // HT-07: nút Quét mã tròn ở giữa thanh điều hướng.
          BottomNavigationBarItem(icon: _ScanButton(), label: 'Quét mã'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton();

  @override
  Widget build(BuildContext context) {
    // Chiếm chỗ bằng icon thường (24) để nhãn thẳng hàng, nút tròn nổi lên trên.
    return SizedBox(
      width: 46,
      height: 24,
      child: OverflowBox(
        maxHeight: 46,
        alignment: Alignment.bottomCenter,
        child: _circle(),
      ),
    );
  }

  Widget _circle() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: AppColors.rose,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x40D4728A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.qr_code_scanner, color: Colors.white),
    );
  }
}
