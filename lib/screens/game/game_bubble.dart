import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'match_card.dart';
import 'rewards_hub_screen.dart';

/// Bong bóng game nổi trên Trang chủ (kiểu Shopee):
/// - Kéo đi đâu cũng được, thả ra thì tự dạt vào mép trái/phải gần nhất.
/// - Bấm vào: mở trang Ưu đãi LUMÉ (điểm danh, game, đổi xu).
/// - Bấm X: ẩn bong bóng tới lần mở app sau.
///
/// Dùng: bọc phần body của màn hình, ví dụ `body: GameBubbleLayer(child: SafeArea(...))`.
class GameBubbleLayer extends StatefulWidget {
  const GameBubbleLayer({super.key, required this.child});

  final Widget child;

  /// Đã bấm X trong lần mở app này chưa (đổi tab rồi quay lại vẫn ẩn).
  static bool _closed = false;

  @override
  State<GameBubbleLayer> createState() => _GameBubbleLayerState();
}

class _GameBubbleLayerState extends State<GameBubbleLayer>
    with SingleTickerProviderStateMixin {
  static const _w = 66.0;
  static const _h = 78.0;
  static const _margin = 8.0;

  /// Nhớ vị trí khi đổi tab rồi quay lại Trang chủ.
  static Offset? _savedPos;

  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  bool _dragging = false;

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _open() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RewardsHubScreen()),
    );
  }

  void _close() => setState(() => GameBubbleLayer._closed = true);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final topMin = MediaQuery.paddingOf(context).top + 64;

    return LayoutBuilder(
      builder: (context, c) {
        final maxX = c.maxWidth - _w - _margin;
        final maxY = c.maxHeight - _h - _margin;
        Offset clampPos(Offset p) => Offset(
          p.dx.clamp(_margin, maxX).toDouble(),
          p.dy.clamp(topMin, maxY < topMin ? topMin : maxY).toDouble(),
        );
        final pos = clampPos(_savedPos ?? Offset(maxX, maxY - 40));

        return Stack(
          children: [
            widget.child,
            if (!GameBubbleLayer._closed)
              AnimatedPositioned(
                duration: _dragging || reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                left: pos.dx,
                top: pos.dy,
                child: GestureDetector(
                  onTap: _open,
                  onPanStart: (_) => setState(() {
                    _dragging = true;
                    _savedPos = pos;
                  }),
                  onPanUpdate: (d) => setState(() {
                    _savedPos = clampPos(_savedPos! + d.delta);
                  }),
                  onPanEnd: (_) => setState(() {
                    _dragging = false;
                    final p = _savedPos!;
                    final toLeft = p.dx + _w / 2 < c.maxWidth / 2;
                    _savedPos = Offset(toLeft ? _margin : maxX, p.dy);
                  }),
                  child: AnimatedBuilder(
                    animation: _float,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        0,
                        _dragging || reduceMotion ? 0 : (_float.value - .5) * 6,
                      ),
                      child: child,
                    ),
                    child: _Bubble(dragging: _dragging, onClose: _close),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.dragging, required this.onClose});

  final bool dragging;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    const size = 58.0;
    return Semantics(
      button: true,
      label: 'Mở trang Ưu đãi LUMÉ',
      child: AnimatedScale(
        scale: dragging ? 1.08 : 1,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          width: _GameBubbleLayerState._w,
          height: _GameBubbleLayerState._h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // hình tròn: ảnh hoa mặt thẻ + chữ Lumé
              Positioned(
                top: 4,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40B45A73),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(cardBackAsset, fit: BoxFit.cover),
                        const Center(
                          child: Text(
                            '✿',
                            style: TextStyle(
                              fontSize: 22,
                              color: AppColors.roseDark,
                              shadows: [Shadow(color: Colors.white, blurRadius: 6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // nhãn dưới hình tròn
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.rose,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Text(
                    'Ghép Đôi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // nút X
              Positioned(
                top: -2,
                right: -2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClose,
                  child: Semantics(
                    button: true,
                    label: 'Ẩn game',
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xB3463B3F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}