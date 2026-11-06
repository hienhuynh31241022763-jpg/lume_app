import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'game_rules.dart';

/// Bảng màu vòng quay kiểu đồ chơi màu hồng: ô hồng xen kem, viền hồng, chấm kem.
/// Thắng 3 sao vẫn màu hồng, chỉ khác chấm viền ánh vàng và tỉ lệ quà tốt hơn.
class WheelPalette {
  const WheelPalette({
    required this.rim,
    required this.rimDark,
    required this.bolt,
    required this.hub,
    required this.tones,
    required this.inks,
  });

  final Color rim, rimDark, bolt, hub;
  final List<Color> tones; // nền ô theo Prize.tone
  final List<Color> inks; // màu icon + chữ theo Prize.tone

  static const pink = WheelPalette(
    rim: Color(0xFFF2BFCB),
    rimDark: Color(0xFFE4A0B2),
    bolt: Color(0xFFF8E8C2),
    hub: Color(0xFFFFF8F2),
    tones: [Color(0xFFF6CDD7), Color(0xFFFCF3EC), Color(0xFFF3BFCC), Color(0xFFFAE3E9)],
    inks: [Color(0xFF8A3F55), Color(0xFF7E5560), Color(0xFF8A3F55), Color(0xFF9A4A62)],
  );

  /// Thắng 3 sao: vẫn hồng, chấm viền + bông hoa trên kim màu vàng nhạt.
  static const gold = WheelPalette(
    rim: Color(0xFFF2BFCB),
    rimDark: Color(0xFFE4A0B2),
    bolt: Color(0xFFF3D98F),
    hub: Color(0xFFFFF8F2),
    tones: [Color(0xFFF6CDD7), Color(0xFFFCF3EC), Color(0xFFF3BFCC), Color(0xFFFAE3E9)],
    inks: [Color(0xFF8A3F55), Color(0xFF7E5560), Color(0xFF8A3F55), Color(0xFF9A4A62)],
  );
}

/// Vòng quay may mắn. Bấm "Quay ngay" → quay ~4 giây → gọi [onResult].
class LuckyWheel extends StatefulWidget {
  const LuckyWheel({super.key, required this.gold, required this.onResult});

  final bool gold;
  final ValueChanged<Prize> onResult;

  @override
  State<LuckyWheel> createState() => _LuckyWheelState();
}

class _LuckyWheelState extends State<LuckyWheel>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  late Animation<double> _angle = const AlwaysStoppedAnimation(0);
  bool _spun = false;
  bool _finished = false;

  WheelPalette get _p => widget.gold ? WheelPalette.gold : WheelPalette.pink;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_spun) return;
    setState(() => _spun = true);
    final rng = Random();
    final i = pickPrize(gold: widget.gold, rng: rng);
    final seg = 2 * pi / prizes.length;
    final jitter = (rng.nextDouble() - .5) * seg * .6;
    // Ô i nằm ở góc i*seg + seg/2 tính từ đỉnh. Quay 6 vòng rồi dừng sao cho ô đó dưới kim.
    final target = 2 * pi * 6 + (2 * pi - (i * seg + seg / 2)) + jitter;
    _angle = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart),
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = 1;
    } else {
      await _ctrl.forward();
    }
    if (!mounted) return;
    setState(() => _finished = true);
    widget.onResult(prizes[i]);
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    return LayoutBuilder(
      builder: (context, c) {
        final size = min(c.maxWidth * .8, 280.0);
        return Column(
          children: [
            SizedBox(
              width: size,
              height: size * 1.12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // chân đế
                  Positioned(
                    top: size * .82,
                    child: CustomPaint(
                      size: Size(size * .34, size * .22),
                      painter: _NeckPainter(p.rim),
                    ),
                  ),
                  Positioned(
                    top: size * 1.0,
                    child: Container(
                      width: size * .7,
                      height: size * .11,
                      decoration: BoxDecoration(
                        color: p.rim,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                          bottom: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(color: p.rimDark, offset: const Offset(0, 4)),
                          const BoxShadow(
                            color: Color(0x33B45A73),
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // vòng quay
                  SizedBox(
                    width: size,
                    height: size,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, child) =>
                          Transform.rotate(angle: _angle.value, child: child),
                      child: _WheelFace(palette: p, size: size),
                    ),
                  ),
                  // tâm
                  Positioned(
                    top: size / 2 - size * .095,
                    child: Container(
                      width: size * .19,
                      height: size * .19,
                      decoration: BoxDecoration(
                        color: p.hub,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: p.rim, spreadRadius: 5),
                          BoxShadow(color: p.rimDark, spreadRadius: 7),
                          const BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                  // kim chỉ hình giọt nước có bông hoa
                  Positioned(
                    top: -size * .05,
                    child: SizedBox(
                      width: size * .12,
                      height: size * .12,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: -pi / 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: p.rimDark,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(99),
                                  topRight: Radius.circular(99),
                                  bottomRight: Radius.circular(99),
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                          ),
                          Text('✿', style: TextStyle(color: p.bolt, fontSize: size * .05)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.gold ? '★★★ Vòng quay 3 sao · quà lớn dễ ra hơn' : 'Vòng quay may mắn',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.roseDark,
              ),
            ),
            // Quay xong thì ẩn nút, thẻ quà hiện ngay bên dưới.
            if (!_finished) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: Colors.white,
                ),
                onPressed: _spun ? null : _spin,
                child: Text(_spun ? 'Đang quay…' : 'Quay ngay'),
              ),
            ),
            ],
          ],
        );
      },
    );
  }
}

/// Mặt vòng quay: viền + các ô + chấm tròn + icon và chữ (quay cùng nhau).
class _WheelFace extends StatelessWidget {
  const _WheelFace({required this.palette, required this.size});

  final WheelPalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final seg = 2 * pi / prizes.length;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _WheelPainter(palette))),
        for (var i = 0; i < prizes.length; i++)
          Positioned.fill(
            child: Transform.rotate(
              angle: i * seg + seg / 2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: size * .12),
                  child: SizedBox(
                    width: size * .2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          prizes[i].icon,
                          size: size * .09,
                          color: palette.inks[prizes[i].tone],
                        ),
                        SizedBox(height: size * .01),
                        Text(
                          prizes[i].label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: size * .04,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: palette.inks[prizes[i].tone],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.p);

  final WheelPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final n = prizes.length;
    final seg = 2 * pi / n;

    // viền + bóng dưới
    canvas.drawCircle(
      c + const Offset(0, 6),
      r,
      Paint()
        ..color = const Color(0x40B45A73)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(c, r, Paint()..color = p.rim);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 2),
      0.15,
      pi - 0.3,
      false,
      Paint()
        ..color = p.rimDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // các ô (bắt đầu từ đỉnh, đi theo chiều kim đồng hồ)
    final inner = Rect.fromCircle(center: c, radius: r * .86);
    for (var i = 0; i < n; i++) {
      canvas.drawArc(
        inner,
        -pi / 2 + i * seg,
        seg,
        true,
        Paint()..color = p.tones[prizes[i].tone],
      );
    }

    // chấm tròn trên viền, ở ranh giới các ô
    final bolt = Paint()..color = p.bolt;
    for (var i = 0; i < n; i++) {
      final a = -pi / 2 + i * seg;
      canvas.drawCircle(c + Offset(cos(a), sin(a)) * r * .93, r * .045, bolt);
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => old.p != p;
}

class _NeckPainter extends CustomPainter {
  _NeckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .18, 0)
      ..lineTo(size.width * .82, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NeckPainter old) => old.color != color;
}