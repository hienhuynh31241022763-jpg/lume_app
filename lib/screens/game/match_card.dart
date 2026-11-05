import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../home/adaptive_image.dart';
import '../home/category_emoji.dart';
import '../product_detail/color_names.dart';
import 'game_rules.dart';

/// Ảnh mặt sau thẻ: nền hoa đã xoá chữ, để trong assets/images/.
const cardBackAsset = 'assets/images/game_card_back.jpg';

/// Một thẻ trên bàn chơi: lật 3D, rắc kim tuyến khi mở, rung khi ghép sai.
class MatchCardView extends StatefulWidget {
  const MatchCardView({super.key, required this.card, required this.onTap});

  final MatchCard card;
  final VoidCallback onTap;

  @override
  State<MatchCardView> createState() => _MatchCardViewState();
}

class _MatchCardViewState extends State<MatchCardView>
    with TickerProviderStateMixin {
  late final _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final _glitter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  List<_Sparkle> _sparkles = const [];
  bool _wasOpen = false;
  int _lastShake = 0;

  bool get _isOpen => widget.card.open || widget.card.done;

  @override
  void initState() {
    super.initState();
    _wasOpen = _isOpen;
    if (_wasOpen) _flip.value = 1;
  }

  @override
  void didUpdateWidget(covariant MatchCardView old) {
    super.didUpdateWidget(old);
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (_isOpen != _wasOpen) {
      _wasOpen = _isOpen;
      if (_isOpen) {
        reduce ? _flip.value = 1 : _flip.forward();
        if (!reduce) {
          _sparkles = _Sparkle.burst(Random());
          _glitter.forward(from: 0);
        }
      } else {
        reduce ? _flip.value = 0 : _flip.reverse();
      }
    }
    if (widget.card.shakeTick != _lastShake) {
      _lastShake = widget.card.shakeTick;
      if (!reduce) _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _glitter.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _isOpen ? widget.card.pair.product.name : 'Hộp giày úp',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_flip, _shake]),
                  builder: (context, _) {
                    final angle = Curves.easeOutCubic.transform(_flip.value) * pi;
                    final front = angle > pi / 2;
                    final s = _shake.value;
                    final dx = s == 0 || s == 1 ? 0.0 : sin(s * pi * 4) * 5 * (1 - s);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(angle),
                        child: front
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(pi),
                                child: _Front(card: widget.card),
                              )
                            : const CardBack(),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _glitter,
                    builder: (context, _) => _glitter.isAnimating
                        ? CustomPaint(
                            painter: _GlitterPainter(_sparkles, _glitter.value),
                          )
                        : const SizedBox.shrink(),
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

// ───────────────────────────── Mặt sau ─────────────────────────────

/// Mặt sau thẻ: nền hoa, viền đôi (chỉ trắng + chỉ đứt nét hồng), chữ Lumé dập nổi.
class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                cardBackAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: AppColors.blush),
              ),
              Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: CustomPaint(painter: _DashedBorderPainter()),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lumé',
                      style: GoogleFonts.pinyonScript(
                        fontSize: w * 0.2,
                        height: 1,
                        color: const Color(0xFFB4637B),
                        shadows: const [
                          Shadow(color: Color(0xF2FFFFFF), offset: Offset(-1, -1)),
                          Shadow(
                            color: Color(0x59782D44),
                            offset: Offset(1, 1),
                            blurRadius: 1,
                          ),
                          Shadow(
                            color: Color(0x2E782D44),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: w * 0.03),
                    Container(
                      width: w * 0.22,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00A9536C),
                            Color(0x80A9536C),
                            Color(0x00A9536C),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x66A9536C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      );
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 3.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────────────── Mặt trước ─────────────────────────────

class _Front extends StatelessWidget {
  const _Front({required this.card});

  final MatchCard card;

  @override
  Widget build(BuildContext context) {
    final color = colorFromName(card.pair.color);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        foregroundDecoration: card.done
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.rose, width: 2),
              )
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HalfShoeImage(pair: card.pair, left: card.left),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40000000), blurRadius: 3),
                  ],
                ),
              ),
            ),
            if (card.done)
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.rose,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final Map<String, double> _aspectCache = {};

/// Đọc tỉ lệ rộng/cao của ảnh (tải 1 lần, nhớ lại theo link). Lỗi thì coi như ảnh vuông.
Future<double> loadImageAspect(String url) async {
  if (url.isEmpty) return 1;
  final cached = _aspectCache[url];
  if (cached != null) return cached;
  final done = Completer<double>();
  final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      final img = info.image;
      if (!done.isCompleted) {
        done.complete(img.height == 0 ? 1 : img.width / img.height);
      }
      stream.removeListener(listener);
    },
    onError: (_, _) {
      if (!done.isCompleted) done.complete(1);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  final aspect = await done.future.timeout(
    const Duration(seconds: 6),
    onTimeout: () => 1,
  );
  _aspectCache[url] = aspect;
  return aspect;
}

/// Nửa trái hoặc nửa phải của ảnh đôi giày, PHỦ KÍN thẻ (không chừa viền).
///
/// Cách cắt: phóng ảnh gốc (đúng tỉ lệ thật) sao cho một nửa ảnh phủ kín thẻ,
/// rồi đặt đường giữa ảnh trùng mép thẻ:
/// - thẻ trái: đường giữa ảnh nằm ở MÉP PHẢI thẻ,
/// - thẻ phải: đường giữa ảnh nằm ở MÉP TRÁI thẻ,
/// - cả hai căn giữa theo chiều dọc như nhau.
/// → Đặt 2 thẻ cạnh nhau là liền thành ảnh gốc, không lệch lên xuống.
class HalfShoeImage extends StatelessWidget {
  const HalfShoeImage({super.key, required this.pair, required this.left});

  final PairKey pair;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final aspect = pair.aspect <= 0 ? 1.0 : pair.aspect;
    return LayoutBuilder(
      builder: (context, c) {
        final cw = c.maxWidth, ch = c.maxHeight;
        final dpr = MediaQuery.devicePixelRatioOf(context);
        // Ảnh hiện ra cao fh, rộng fw = fh * aspect; cần fw/2 >= cw và fh >= ch.
        final fh = max(ch, 2 * cw / aspect);
        final fw = fh * aspect;
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: left ? cw - fw / 2 : -fw / 2,
                top: (ch - fh) / 2,
                width: fw,
                height: fh,
                child: FullShoeImage(pair: pair, cacheWidth: (fw * dpr).round()),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Cả ảnh đôi giày, khung tự lấy màu nền ảnh.
class FullShoeImage extends StatelessWidget {
  const FullShoeImage({super.key, required this.pair, this.cacheWidth, this.onColor});

  final PairKey pair;
  final int? cacheWidth;
  final ValueChanged<Color>? onColor;

  @override
  Widget build(BuildContext context) {
    return AdaptiveImage(
      url: pair.image,
      cacheWidth: cacheWidth,
      onColor: onColor,
      fallbackColor: AppColors.blush,
      placeholder: Container(
        color: AppColors.blush,
        alignment: Alignment.center,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              emojiForCategory(pair.product.category),
              style: const TextStyle(fontSize: 64),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Kim tuyến ─────────────────────────────

class _Sparkle {
  _Sparkle(this.start, this.move, this.size, this.color, this.delay, this.round);

  final Offset start; // vị trí xuất phát, tính theo tỉ lệ khung (-0.25..0.25)
  final Offset move; // hướng bay, tính theo bề rộng thẻ
  final double size;
  final Color color;
  final double delay; // 0..0.16 thời gian
  final bool round;

  static const _colors = [
    Color(0xFFF3D58A),
    Color(0xFFFFFFFF),
    Color(0xFFE8A0B4),
    Color(0xFFF9E6B0),
    AppColors.rose,
  ];

  static List<_Sparkle> burst(Random rng) => List.generate(16, (_) {
    final a = rng.nextDouble() * pi * 2;
    final d = 0.45 + rng.nextDouble() * 0.55;
    return _Sparkle(
      Offset((rng.nextDouble() - .5) * .5, (rng.nextDouble() - .5) * .5),
      Offset(cos(a) * d, sin(a) * d),
      3 + rng.nextDouble() * 4,
      _colors[rng.nextInt(_colors.length)],
      rng.nextDouble() * .16,
      rng.nextDouble() < .35,
    );
  });
}

class _GlitterPainter extends CustomPainter {
  _GlitterPainter(this.sparkles, this.t);

  final List<_Sparkle> sparkles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final s in sparkles) {
      final local = ((t - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final e = Curves.easeOutCubic.transform(local);
      final opacity = local < .15 ? local / .15 : 1 - (local - .15) / .85;
      final pos = center +
          Offset(s.start.dx * size.width, s.start.dy * size.height) +
          s.move * size.width * e;
      final paint = Paint()..color = s.color.withValues(alpha: opacity.clamp(0, 1));
      final r = s.size * (.2 + .8 * e);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(pi / 4 + e * 3);
      if (s.round) {
        canvas.drawCircle(Offset.zero, r / 2, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r, height: r), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GlitterPainter old) => old.t != t;
}