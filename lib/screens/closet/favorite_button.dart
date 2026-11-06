import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'favorites_store.dart';
import 'shoe_closet_screen.dart';

/// Nút trái tim: thả tim để cất giày vào Tủ giày, bấm lần nữa để lấy ra.
/// Dùng ở góc ảnh thẻ sản phẩm và cạnh tên giày ở trang Chi tiết.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 34});

  final String productId;
  final double size;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    FavoritesStore.load();
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final added = await FavoritesStore.toggle(widget.productId);
    if (!mounted) return;
    if (added && !MediaQuery.disableAnimationsOf(context)) _pop.forward(from: 0);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(added ? 'Đã cất vào Tủ giày' : 'Đã lấy khỏi Tủ giày'),
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          action: added
              ? SnackBarAction(
                  label: 'Xem tủ',
                  textColor: AppColors.blush,
                  onPressed: () => openShoeCloset(context),
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return ValueListenableBuilder<List<String>>(
      valueListenable: FavoritesStore.ids,
      builder: (context, ids, _) {
        final on = ids.contains(widget.productId);
        return Semantics(
          button: true,
          toggled: on,
          label: on ? 'Bỏ khỏi Tủ giày' : 'Cất vào Tủ giày',
          child: Material(
            color: Colors.white.withValues(alpha: .9),
            shape: const CircleBorder(),
            elevation: 1,
            shadowColor: Colors.black12,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _toggle,
              child: SizedBox(
                width: s,
                height: s,
                child: AnimatedBuilder(
                  animation: _pop,
                  builder: (context, child) {
                    final t = _pop.value;
                    // nảy: 0.6 → 1.3 → 1
                    final scale = t == 0
                        ? 1.0
                        : t < .6
                        ? .6 + .7 * Curves.easeOut.transform(t / .6)
                        : 1.3 - .3 * Curves.easeIn.transform((t - .6) / .4);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (t > 0 && t < 1)
                          Container(
                            width: s * (.6 + t),
                            height: s * (.6 + t),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.rose.withValues(alpha: (1 - t) * .8),
                                width: 2,
                              ),
                            ),
                          ),
                        Transform.scale(scale: scale, child: child),
                      ],
                    );
                  },
                  child: Icon(
                    on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: s * .55,
                    color: on ? AppColors.rose : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Nút tròn trái tim ở đầu Trang chủ (cạnh chuông), có số đôi trong tủ.
class ClosetHeaderButton extends StatefulWidget {
  const ClosetHeaderButton({super.key});

  @override
  State<ClosetHeaderButton> createState() => _ClosetHeaderButtonState();
}

class _ClosetHeaderButtonState extends State<ClosetHeaderButton> {
  @override
  void initState() {
    super.initState();
    FavoritesStore.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: FavoritesStore.ids,
      builder: (context, ids, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          Tooltip(
            message: 'Tủ giày',
            child: Material(
              color: AppColors.card,
              shape: const CircleBorder(),
              elevation: 1,
              shadowColor: Colors.black12,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => openShoeCloset(context),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.favorite_border_rounded, color: AppColors.ink, size: 22),
                ),
              ),
            ),
          ),
          if (ids.isNotEmpty)
            Positioned(
              right: -2,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.rose,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
                child: Text(
                  '${ids.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
