import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../cart/cart_item_tile.dart';
import '../cart/cart_summary.dart';
import '../pin_location/delivery_address.dart';
import 'address_step.dart';

/// HT-01 · Bước 3: xem lại người nhận, địa chỉ, cách trả tiền, sản phẩm, tổng.
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    required this.onEditAddress,
    required this.onEditPayment,
  });

  final String name;
  final String phone;
  final DeliveryAddress address;
  final String payment;
  final VoidCallback onEditAddress;
  final VoidCallback onEditPayment;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SectionLabel(
          'Giao tới $name · $phone',
          trailing: _EditButton(onTap: onEditAddress),
        ),
        AddressCard(address: address),
        const SizedBox(height: 18),
        SectionLabel('Thanh toán', trailing: _EditButton(onTap: onEditPayment)),
        Text(payment),
        const SizedBox(height: 18),
        SectionLabel('Sản phẩm (${cart.count})'),
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                ProductThumb(
                  url: item.product.image,
                  category: item.product.category,
                  size: 52,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Size ${item.size} · ${item.color} · ×${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatPrice(item.total),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const CartSummary(showFreeShipHint: false),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.rose,
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Sửa'),
    );
  }
}
