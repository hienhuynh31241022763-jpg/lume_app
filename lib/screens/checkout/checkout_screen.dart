import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _paymentMethod = 'Thanh toán khi nhận hàng';
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<AuthProvider>().name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    setState(() => _placingOrder = true);
    final order = await context.read<OrderProvider>().place(
      cart: cart,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
    );
    if (!mounted) return;
    setState(() => _placingOrder = false);

    if (order == null) {
      final message =
          context.read<OrderProvider>().error ?? 'Không thể đặt hàng';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.orderSuccess,
      arguments: order,
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập $label';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: 12),
                  const Text('Giỏ hàng đang trống'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  const _SectionTitle('Thông tin nhận hàng'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => _required(value, 'họ và tên'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      final error = _required(value, 'số điện thoại');
                      if (error != null) return error;
                      final digits = value!.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 9 || digits.length > 11) {
                        return 'Số điện thoại chưa hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ nhận hàng',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) => _required(value, 'địa chỉ'),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Phương thức thanh toán'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final method in const [
                        'Thanh toán khi nhận hàng',
                        'Chuyển khoản ngân hàng',
                      ])
                        ChoiceChip(
                          label: Text(method),
                          selected: _paymentMethod == method,
                          onSelected: (_) =>
                              setState(() => _paymentMethod = method),
                          selectedColor: AppColors.blush,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Đơn hàng'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          for (final item in cart.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} · Size ${item.size}'
                                      ' × ${item.quantity}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PriceText(item.total),
                                ],
                              ),
                            ),
                          const Divider(height: 20),
                          _PriceLine(label: 'Tạm tính', amount: cart.subtotal),
                          _PriceLine(
                            label: 'Phí giao hàng',
                            amount: cart.shipping,
                          ),
                          if (cart.discount > 0)
                            _PriceLine(
                              label: 'Giảm giá',
                              amount: -cart.discount,
                            ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Tổng thanh toán',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              PriceText(cart.total),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _placingOrder ? null : _placeOrder,
                    child: _placingOrder
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đặt hàng'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          PriceText(amount),
        ],
      ),
    );
  }
}
