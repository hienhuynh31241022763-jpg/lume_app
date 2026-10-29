import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HeartButton extends StatefulWidget {
  final bool initialValue;
  final double size;
  final ValueChanged<bool>? onChanged;

  const HeartButton({
    super.key,
    this.initialValue = false,
    this.size = 22,
    this.onChanged,
  });

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton>
    with SingleTickerProviderStateMixin {
  late bool _liked = widget.initialValue;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    // Phóng to 1.0 -> 1.35 rồi nảy về 1.0
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _liked = !_liked);
    if (_liked) _ctrl.forward(from: 0);
    widget.onChanged?.call(_liked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ScaleTransition(
          scale: _scale,
          child: Icon(
            _liked ? Icons.favorite : Icons.favorite_border,
            size: widget.size,
            color: _liked ? AppColors.rose : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
