import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'delivery_address.dart';
import 'lume_stores.dart';

/// HT-11 · Bảng dưới bản đồ: địa chỉ của ghim, cửa hàng gần nhất,
/// ghi chú cho shipper, nhãn địa chỉ, nút xác nhận.
class PinAddressPanel extends StatelessWidget {
  const PinAddressPanel({
    super.key,
    required this.line1,
    required this.line2,
    required this.resolving,
    required this.store,
    required this.storeMeters,
    required this.noteController,
    required this.label,
    required this.onLabel,
    required this.onConfirm,
  });

  final String line1;
  final String line2;
  final bool resolving;
  final LumeStore store;
  final double storeMeters;
  final TextEditingController noteController;
  final String label;
  final ValueChanged<String> onLabel;

  /// null = đang tìm địa chỉ, chưa cho xác nhận.
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.rose),
              const SizedBox(width: 8),
              Expanded(
                child: resolving
                    ? Text(
                        'Đang tìm địa chỉ…',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line1, style: textTheme.titleSmall),
                          if (line2.isNotEmpty)
                            Text(
                              line2,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.blush.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 18,
                  color: AppColors.roseDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Cửa hàng gần nhất: ${store.name} · cách ',
                      children: [
                        TextSpan(
                          text: formatDistance(storeMeters),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Ghi chú cho shipper: số nhà, tầng, cổng…',
              prefixIcon: Icon(Icons.edit_note),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final l in DeliveryAddress.labels)
                ChoiceChip(
                  label: Text(l),
                  selected: l == label,
                  onSelected: (_) => onLabel(l),
                  selectedColor: AppColors.blush,
                  side: BorderSide(
                    color: l == label ? AppColors.rose : AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Xác nhận vị trí này'),
          ),
        ],
      ),
    );
  }
}
