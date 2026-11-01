import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// HT-07 · Khung ngắm: làm tối phần ngoài khung, 4 góc hồng,
/// vạch quét chạy lên xuống (tắt khi máy bật giảm chuyển động).
class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key, required this.window, required this.found});

  final Rect window;

  /// Đã quét được mã: viền chuyển xanh, dừng vạch quét.
  final bool found;

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = widget.found || MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _line,
        builder: (_, _) => CustomPaint(
          size: Size.infinite,
          painter: _OverlayPainter(
            window: widget.window,
            color: widget.found ? AppColors.success : AppColors.rose,
            line: still ? null : _line.value,
          ),
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.window, required this.color, this.line});

  final Rect window;
  final Color color;
  final double? line;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(window, const Radius.circular(18));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(hole),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    final corner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 26.0;
    final r = window;
    for (final (p, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy + dy * len)
          ..lineTo(p.dx, p.dy + dy * 8)
          ..quadraticBezierTo(p.dx, p.dy, p.dx + dx * 8, p.dy)
          ..lineTo(p.dx + dx * len, p.dy),
        corner,
      );
    }

    final t = line;
    if (t != null) {
      final y = r.top + 12 + (r.height - 24) * t;
      canvas.drawLine(
        Offset(r.left + 14, y),
        Offset(r.right - 14, y),
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.window != window || old.color != color || old.line != line;
}
