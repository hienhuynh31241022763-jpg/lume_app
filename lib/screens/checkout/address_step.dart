import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../pin_location/delivery_address.dart';
import 'customer_info.dart';

/// HT-01 · Bước 1: người nhận và địa chỉ giao hàng.
/// Bấm "Đổi" mở Ghim vị trí (HT-11).
class AddressStep extends StatelessWidget {
  const AddressStep({
    super.key,
    required this.formKey,
    required this.name,
    required this.phone,
    required this.address,
    required this.onPickAddress,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final DeliveryAddress? address;
  final VoidCallback onPickAddress;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      // Đã báo lỗi thì sửa tới đâu kiểm tra lại tới đó.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const SectionLabel('Người nhận'),
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Nhập họ tên người nhận' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              hintText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: validatePhone,
          ),
          const SizedBox(height: 20),
          const SectionLabel('Địa chỉ giao hàng'),
          if (address == null)
            OutlinedButton.icon(
              onPressed: onPickAddress,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Chọn vị trí trên bản đồ'),
            )
          else
            AddressCard(address: address!, onChange: onPickAddress),
        ],
      ),
    );
  }
}

/// Thẻ địa chỉ: nhãn, 2 dòng địa chỉ, ghi chú, nút "Đổi".
class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, this.onChange});

  final DeliveryAddress address;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on, color: AppColors.rose),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roseDark,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(address.line1, style: textTheme.titleSmall),
                if (address.line2.isNotEmpty)
                  Text(
                    address.line2,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                if (address.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Ghi chú: ${address.note}',
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onChange != null)
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(foregroundColor: AppColors.rose),
              child: const Text('Đổi'),
            ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleSmall),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
