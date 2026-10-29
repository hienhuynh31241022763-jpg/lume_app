import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'saved_size.dart';

/// HT-06 · Tìm size chuẩn (theo prototype màn 06)
/// Hình hướng dẫn đo chân, kéo chọn chiều dài bàn chân → gợi ý size,
/// bảng quy đổi EU/VN – US – UK, lưu size vào hồ sơ.
///
/// Mở từ Chi tiết sản phẩm thì bấm Lưu sẽ quay lại và chọn sẵn size đó.

class SizeRow {
  const SizeRow(this.eu, this.us, this.uk, this.footCm);

  final String eu;
  final String us;
  final String uk;
  final double footCm; // chiều dài chân tối đa vừa size này
}

/// Bảng size chuẩn của LUMÉ (giống prototype).
const sizeTable = [
  SizeRow('35', '5', '2.5', 22.5),
  SizeRow('36', '6', '3.5', 23.0),
  SizeRow('37', '6.5', '4', 23.5),
  SizeRow('38', '7.5', '5', 24.0),
  SizeRow('39', '8', '6', 24.5),
  SizeRow('40', '9', '6.5', 25.0),
];

/// Size nhỏ nhất mà chân vẫn vừa (làm tròn lên, chân 23.2cm → size 37).
/// Chân dài hơn bảng thì trả về null.
String? suggestSize(double footCm) {
  for (final row in sizeTable) {
    if (footCm <= row.footCm + 0.001) return row.eu;
  }
  return null;
}

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  static const _min = 21.5;
  static const _max = 26.0;

  double _cm = savedFootLength.value ?? 23.5;

  void _setCm(double v) {
    // Làm tròn 0.1 cm, giữ trong khoảng cho phép.
    final rounded = (v.clamp(_min, _max) * 10).round() / 10;
    setState(() => _cm = rounded);
  }

  void _save(String size) {
    savedShoeSize.value = size;
    savedFootLength.value = _cm;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Đã lưu size $size vào hồ sơ')));
    // Trả size về cho màn đã mở (VD: Chi tiết sản phẩm chọn sẵn size này).
    Navigator.maybePop(context, size);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = suggestSize(_cm);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Đầu trang ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: AppColors.card,
                    shape: const CircleBorder(),
                    elevation: 1,
                    shadowColor: Colors.black12,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.maybePop(context),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Tìm size chuẩn', style: textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _FootIllustration(cm: _cm, min: _min, max: _max),
                  const SizedBox(height: 12),
                  Text(
                    'Đặt gót chân sát tường, đo từ gót đến đầu ngón chân '
                    'dài nhất.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Chọn chiều dài bàn chân ──
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chiều dài bàn chân',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${_cm.toStringAsFixed(1)} cm',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.rose,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _StepButton(
                        icon: Icons.remove,
                        onTap: () => _setCm(_cm - 0.1),
                      ),
                      Expanded(
                        child: Slider(
                          value: _cm,
                          min: _min,
                          max: _max,
                          activeColor: AppColors.rose,
                          inactiveColor: AppColors.ink,
                          onChanged: _setCm,
                        ),
                      ),
                      _StepButton(
                        icon: Icons.add,
                        onTap: () => _setCm(_cm + 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Size gợi ý ──
                  _SuggestionCard(size: size),
                  const SizedBox(height: 20),

                  // ── Bảng quy đổi ──
                  _SizeTable(highlight: size),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: size == null ? null : () => _save(size),
                  child: Text(
                    size == null
                        ? 'Chưa có size phù hợp'
                        : 'Lưu size $size vào hồ sơ',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── Hình hướng dẫn đo chân ─────────────────────

class _FootIllustration extends StatelessWidget {
  const _FootIllustration({
    required this.cm,
    required this.min,
    required this.max,
  });

  final double cm;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Bàn chân dài ra / ngắn lại theo thanh kéo.
          final t = ((cm - min) / (max - min)).clamp(0.0, 1.0);
          final footWidth = constraints.maxWidth * (0.5 + 0.45 * t);
          const anim = Duration(milliseconds: 200);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: anim,
                width: footWidth,
                child: Column(
                  children: [
                    Text(
                      '${cm.toStringAsFixed(1)} cm',
                      style: const TextStyle(
                        color: AppColors.roseDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 2,
                      width: double.infinity,
                      child: CustomPaint(painter: _DashPainter()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: anim,
                width: footWidth,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1C9AE),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(22),
                    right: Radius.circular(30),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 22,
                width: double.infinity,
                child: CustomPaint(painter: _RulerPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.roseDark
      ..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 4).clamp(0, size.width).toDouble(), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFE5C98F));
    final tick = Paint()
      ..color = const Color(0xFF9C7A3C)
      ..strokeWidth = 1.2;
    var i = 0;
    for (double x = 6; x < size.width - 4; x += 8, i++) {
      final h = i % 5 == 0 ? size.height * 0.8 : size.height * 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, h), tick);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────────── Nút −/+ 0.1 cm ─────────────────────────

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: AppColors.roseDark),
        ),
      ),
    );
  }
}

// ───────────────────────── Thẻ size gợi ý ─────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.size});

  final String? size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.rose, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                size ?? '40+',
                key: ValueKey(size),
                style: const TextStyle(
                  color: AppColors.roseDark,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  size == null ? 'Chưa có size vừa' : 'Size gợi ý cho bạn',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  size == null
                      ? 'Chân dài hơn bảng size LUMÉ (tối đa 25 cm). '
                            'Bạn liên hệ shop để được tư vấn nhé.'
                      : 'Theo bảng size chuẩn của LUMÉ',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Bảng quy đổi ─────────────────────────

class _SizeTable extends StatelessWidget {
  const _SizeTable({required this.highlight});

  final String? highlight;

  @override
  Widget build(BuildContext context) {
    Widget cell(String text, {bool bold = false, Color? color}) => Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: color ?? AppColors.ink,
        ),
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              cell('EU/VN', color: AppColors.muted),
              cell('US', color: AppColors.muted),
              cell('UK', color: AppColors.muted),
              cell('Chân (cm)', color: AppColors.muted),
            ],
          ),
        ),
        const Divider(),
        for (final row in sizeTable) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: row.eu == highlight ? AppColors.blush : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                for (final value in [
                  row.eu,
                  row.us,
                  row.uk,
                  row.footCm.toStringAsFixed(1),
                ])
                  cell(
                    value,
                    bold: row.eu == highlight,
                    color: row.eu == highlight ? AppColors.roseDark : null,
                  ),
              ],
            ),
          ),
          const Divider(),
        ],
      ],
    );
  }
}