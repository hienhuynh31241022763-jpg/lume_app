import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// HT-01 · Thanh tiến trình 3 bước: Địa chỉ → Thanh toán → Xác nhận.
/// Bước đã qua có dấu ✓, bước hiện tại tô hồng.
class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.current});

  static const steps = ['Địa chỉ', 'Thanh toán', 'Xác nhận'];

  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: i <= current ? AppColors.rose : AppColors.line,
                ),
              ),
            _Dot(index: i, label: steps[i], current: current),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.label, required this.current});

  final int index;
  final String label;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    final color = done || active ? AppColors.rose : AppColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? AppColors.rose : AppColors.card,
            border: Border.all(color: color, width: 1.5),
          ),
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.muted,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.ink : color,
          ),
        ),
      ],
    );
  }
}
