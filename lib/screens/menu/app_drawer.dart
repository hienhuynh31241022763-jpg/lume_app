import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../filter/filter_results_screen.dart';
import '../filter/product_filter.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _openRoute(BuildContext context, String route) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(route);
  }

  void _openFlashSale(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const FilterResultsScreen(
          title: 'Flash sale',
          initialFilter: ProductFilter(saleOnly: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;
    final name = isLoggedIn && auth.name.isNotEmpty ? auth.name : 'Khách';

    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.82).clamp(280.0, 340.0),
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _AccountHeader(
              name: name,
              email: auth.email,
              isLoggedIn: isLoggedIn,
              onTap: isLoggedIn
                  ? null
                  : () => _openRoute(context, AppRoutes.login),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: [
                  const _GroupLabel('MUA SẮM'),
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    title: 'Trang chủ',
                    selected: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _DrawerItem(
                    icon: Icons.bolt,
                    title: 'Flash sale',
                    badge: 'HOT',
                    onTap: () => _openFlashSale(context),
                  ),
                  _DrawerItem(
                    icon: Icons.qr_code_scanner,
                    title: 'Quét mã sản phẩm',
                    onTap: () => _openRoute(context, AppRoutes.scan),
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    title: 'Sổ địa chỉ',
                    onTap: () => _openRoute(context, AppRoutes.pinLocation),
                  ),
                  const SizedBox(height: 12),
                  const _GroupLabel('KHÁM PHÁ'),
                  _DrawerItem(
                    icon: Icons.article_outlined,
                    title: 'Tin tức & xu hướng',
                    badge: 'MỚI',
                    onTap: () => _openRoute(context, AppRoutes.news),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    title: 'Về LUMÉ',
                    onTap: () => _openRoute(context, AppRoutes.about),
                  ),
                  const SizedBox(height: 12),
                  const _GroupLabel('HỖ TRỢ'),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    title: 'Trung tâm hỗ trợ',
                    onTap: () => _openRoute(context, AppRoutes.help),
                  ),
                ],
              ),
            ),
            const _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.name,
    required this.email,
    required this.isLoggedIn,
    required this.onTap,
  });

  final String name;
  final String email;
  final bool isLoggedIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blush,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.blush, AppColors.background],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.rose,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn
                          ? (email.isEmpty ? 'Thành viên Vàng · 1.250 xu' : email)
                          : 'Đăng nhập để xem tài khoản',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoggedIn)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.roseDark : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AppColors.blush : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.rose,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  if (title == 'Quét mã sản phẩm' || title == 'Sổ địa chỉ')
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: const Row(
        children: [
          Text(
            'Hotline ',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          Text(
            '1900 1234',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          Text(
            'LUMÉ v1.0',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
