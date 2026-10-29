import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi LUMÉ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderCount = context.watch<OrderProvider>().orders.length;
    final topPadding = MediaQuery.of(context).padding.top;

    final name = auth.isLoggedIn && auth.name.isNotEmpty ? auth.name : 'Khách';
    final email = auth.isLoggedIn
        ? '${auth.email} · Thành viên Vàng'
        : 'Bạn chưa đăng nhập';
    final initial = name.characters.first.toUpperCase();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Đầu trang: nền hồng nhạt kéo lên tận mép trên, avatar, tên, email
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPadding + 28, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.blush, AppColors.background],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.rose,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                if (!auth.isLoggedIn) ...[
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ],
            ),
          ),

          // 2. Thống kê nhanh: 3 ô có vạch ngăn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _Stat(value: '$orderCount', label: 'Đơn hàng'),
                  const _StatDivider(),
                  const _Stat(value: '1.250', label: 'Xu'),
                  const _StatDivider(),
                  const _Stat(value: '3', label: 'Voucher'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Danh sách chức năng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Đơn hàng của tôi',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Sổ địa chỉ',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.pinLocation),
                  ),
                  _MenuItem(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Kho voucher',
                    badge: '3 mới',
                    onTap: () => _toast(
                      context,
                      'Bạn có 3 voucher: LUME10, FREESHIP, LUME50K',
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.straighten,
                    title: 'Size của tôi',
                    badge: '37',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.sizeGuide),
                  ),
                  _MenuItem(
                    icon: Icons.history,
                    title: 'Xem gần đây',
                    onTap: () => _toast(
                      context,
                      'Danh sách sản phẩm xem gần đây đang được phát triển',
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none,
                    title: 'Cài đặt thông báo',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Trung tâm hỗ trợ',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.help),
                    isLast: !auth.isLoggedIn,
                  ),
                  if (auth.isLoggedIn)
                    _MenuItem(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      color: AppColors.error,
                      showArrow: false,
                      isLast: true,
                      onTap: () => _confirmLogout(context),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.line);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final Color color;
  final bool showArrow;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.color = AppColors.ink,
    this.showArrow = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (badge != null)
              Text(
                badge!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.rose,
                ),
              ),
            if (showArrow && badge == null)
              const Icon(Icons.chevron_right, size: 22, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
