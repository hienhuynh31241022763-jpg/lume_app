import 'package:flutter/material.dart';

/// HT-19 (Hạo): ảnh giày bay theo đường cong từ [from] vào biểu tượng giỏ [to].
/// Bật "giảm chuyển động" trong máy, hoặc chưa đo được vị trí, thì bỏ qua.
void flyToCart(
  BuildContext context, {
  required GlobalKey from,
  required GlobalKey to,
  required Widget child,
  double size = 64,
}) {
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
  final fromBox = from.currentContext?.findRenderObject() as RenderBox?;
  final toBox = to.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null ||
      overlayBox == null ||
      fromBox == null ||
      toBox == null ||
      !fromBox.attached ||
      !toBox.attached) {
    return;
  }

  final start = fromBox.localToGlobal(
    fromBox.size.center(Offset.zero),
    ancestor: overlayBox,
  );
  final end = toBox.localToGlobal(
    toBox.size.center(Offset.zero),
    ancestor: overlayBox,
  );

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Flyer(
      start: start,
      end: end,
      size: size,
      onDone: entry.remove,
      child: child,
    ),
  );
  overlay.insert(entry);
}

class _Flyer extends StatefulWidget {
  const _Flyer({
    required this.start,
    required this.end,
    required this.size,
    required this.onDone,
    required this.child,
  });

  final Offset start;
  final Offset end;
  final double size;
  final VoidCallback onDone;
  final Widget child;

  @override
  State<_Flyer> createState() => _FlyerState();
}

class _FlyerState extends State<_Flyer> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.start;
    final b = widget.end;
    // Điểm điều khiển ở giữa, nhấc cao hơn 40px để đường bay cong lên.
    final c = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - 40);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) {
          final t = _t.value;
          final u = 1 - t;
          final p = a * (u * u) + c * (2 * u * t) + b * (t * t);
          final scale = 1.4 + (0.2 - 1.4) * t;
          final opacity = 1 - 0.6 * t;
          return Stack(
            children: [
              Positioned(
                left: p.dx - widget.size / 2,
                top: p.dy - widget.size / 2,
                width: widget.size,
                height: widget.size,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(scale: scale, child: child),
                ),
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
