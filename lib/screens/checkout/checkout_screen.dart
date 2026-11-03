import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../pin_location/delivery_address.dart';
import '../pin_location/saved_address.dart';
import 'address_step.dart';
import 'customer_info.dart';
import 'order_success_screen.dart';
import 'payment_step.dart';
import 'review_step.dart';
import 'step_bar.dart';

/// HT-01 · Thanh toán
/// - Thanh tiến trình 3 bước: Địa chỉ → Thanh toán → Xác nhận.
/// - Địa chỉ lấy từ Sổ địa chỉ; "Đổi" mở Ghim vị trí (HT-11).
/// - COD, chuyển khoản, ví điện tử (mô phỏng).
/// - "Đặt hàng" tạo đơn qua OrderProvider (tự làm trống giỏ) rồi sang
///   Đặt hàng thành công (HT-02), truyền thẳng đơn vừa tạo.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  int _step = 0;
  DeliveryAddress? _address = savedAddress.value;
  PaymentChoice _payment = PaymentChoice.cod;
  String _wallet = PaymentChoice.wallets.first;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _name.text = context.read<AuthProvider>().name;
    loadCustomerInfo().then((info) {
      final (name, phone) = info;
      if (!mounted) return;
      if (name.isNotEmpty) _name.text = name;
      if (_phone.text.isEmpty) _phone.text = phone;
    });
    loadSavedAddress().then((_) {
      if (mounted && _address == null) {
        setState(() => _address = savedAddress.value);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    FocusScope.of(context).unfocus();
    // Route chung trả MaterialPageRoute<dynamic>, nên nhận Object? rồi kiểm tra kiểu.
    final result = await Navigator.pushNamed(context, AppRoutes.pinLocation);
    if (result is DeliveryAddress && mounted) {
      setState(() => _address = result);
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      final ok = _formKey.currentState?.validate() ?? false;
      if (!ok) return;
      if (_address == null) {
        _toast('Hãy chọn địa chỉ giao hàng trên bản đồ');
        return;
      }
      saveCustomerInfo(_name.text.trim(), _phone.text.trim());
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    setState(() => _placing = true);
    final order = await orders.place(
      cart: cart,
      customerName: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address!.orderText,
      paymentMethod: _payment.orderName(_wallet),
    );
    if (!mounted) return;
    if (order == null) {
      setState(() => _placing = false);
      _toast(orders.error ?? 'Chưa đặt được hàng, thử lại nhé');
      return;
    }
    // Bỏ Thanh toán (và Giỏ hàng, Chi tiết nếu có) khỏi ngăn xếp,
    // để bấm quay lại ở màn thành công là về app chính.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.orderSuccess),
        builder: (_) => OrderSuccessScreen(order: order),
      ),
      (route) => route.isFirst,
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    // Chưa tick món nào thì không có gì để thanh toán.
    if (!cart.hasSelection && !_placing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: _EmptyCheckout(empty: cart.isEmpty),
      );
    }

    return PopScope(
      canPop: _step == 0 && !_placing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_placing && _step > 0) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: Column(
          children: [
            StepBar(current: _step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    0 => AddressStep(
                      formKey: _formKey,
                      name: _name,
                      phone: _phone,
                      address: _address,
                      onPickAddress: _pickAddress,
                    ),
                    1 => PaymentStep(
                      choice: _payment,
                      wallet: _wallet,
                      phone: _phone.text.trim(),
                      onChoice: (c) => setState(() => _payment = c),
                      onWallet: (w) => setState(() => _wallet = w),
                    ),
                    _ => ReviewStep(
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                      address: _address!,
                      payment: _payment.orderName(_wallet),
                      onEditAddress: () => setState(() => _step = 0),
                      onEditPayment: () => setState(() => _step = 1),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton(
            onPressed: _placing ? null : _next,
            child: _placing
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _step < 2
                        ? 'Tiếp tục'
                        : 'Đặt hàng · ${formatPrice(cart.selectedTotal)}',
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout({required this.empty});

  /// Giỏ rỗng hẳn, hay chỉ là chưa tick món nào.
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.rose,
            ),
            const SizedBox(height: 12),
            Text(
              empty ? 'Giỏ hàng đang trống' : 'Bạn chưa chọn sản phẩm nào',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Quay lại'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
