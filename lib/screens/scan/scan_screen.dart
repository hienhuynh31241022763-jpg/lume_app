import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_text.dart';
import '../cart/cart_item_tile.dart';
import '../home/demo_data.dart';
import 'product_code.dart';
import 'scan_history.dart';
import 'scan_overlay.dart';
import 'scan_result_card.dart';

/// HT-07 · Quét mã sản phẩm
/// - Mở từ nút tròn giữa thanh điều hướng, nút quét trong ô tìm kiếm.
/// - Quét QR trên hộp giày / tem / poster, hoặc chuyển sang mã vạch tem giá.
/// - Quét xong hiện sản phẩm, bấm "Xem chi tiết" mở trang Chi tiết.
/// - Chọn ảnh có mã từ thư viện, bật đèn flash, xem lịch sử đã quét.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

enum _Mode {
  qr('Mã QR', 'Đưa mã QR trên hộp giày hoặc tem sản phẩm vào khung', [
    BarcodeFormat.qrCode,
  ]),
  barcode('Mã vạch', 'Đưa mã vạch trên tem giá vào khung', [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.upcA,
    BarcodeFormat.code128,
  ]);

  const _Mode(this.label, this.tip, this.formats);

  final String label;
  final String tip;
  final List<BarcodeFormat> formats;
}

class _ScanScreenState extends State<ScanScreen> {
  // Nhận cả QR lẫn mã vạch, lọc theo chế độ đang chọn khi đọc được mã,
  // nhờ vậy đổi chế độ không phải khởi động lại camera.
  final _controller = MobileScannerController(
    formats: [for (final m in _Mode.values) ...m.formats],
  );

  _Mode _mode = _Mode.qr;
  String? _code;
  Product? _product;
  bool _reading = false;

  @override
  void initState() {
    super.initState();
    loadScanHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_code != null || _reading) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null || raw.isEmpty || !_mode.formats.contains(b.format)) {
        continue;
      }
      _show(raw);
      return;
    }
  }

  void _show(String raw) {
    final id = productIdFromCode(raw);
    final product = id == null
        ? null
        : productById(context.read<ProductProvider>(), id);
    if (product != null) addScan(product.id);
    HapticFeedback.mediumImpact();
    setState(() {
      _code = raw;
      _product = product;
    });
  }

  void _again() => setState(() {
    _code = null;
    _product = null;
  });

  void _openDetail(Product p) =>
      Navigator.pushNamed(context, AppRoutes.productDetail, arguments: p.id);

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() => _reading = true);
    try {
      final capture = await _controller.analyzeImage(
        file.path,
        formats: _mode.formats,
      );
      final raw = capture?.barcodes
          .map((b) => b.rawValue)
          .whereType<String>()
          .firstOrNull;
      if (!mounted) return;
      if (raw == null) {
        _toast('Không thấy ${_mode.label.toLowerCase()} trong ảnh này');
      } else {
        _show(raw);
      }
    } catch (_) {
      _toast('Không đọc được ảnh này, thử ảnh khác nhé');
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  void _showHistory() {
    final provider = context.read<ProductProvider>();
    final items = scanHistory.value
        .map((id) => productById(provider, id))
        .whereType<Product>()
        .toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Text(
                  'Bạn chưa quét sản phẩm nào',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'Đã quét gần đây',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final p in items)
                    ListTile(
                      leading: ProductThumb(
                        url: p.image,
                        category: p.category,
                        size: 44,
                      ),
                      title: Text(p.name, maxLines: 1),
                      subtitle: Text(
                        formatPrice(p.price),
                        style: const TextStyle(color: AppColors.roseDark),
                      ),
                      onTap: () {
                        Navigator.pop(sheet);
                        _openDetail(p);
                      },
                    ),
                ],
              ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final window = Rect.fromCenter(
              center: Offset(size.width / 2, size.height * 0.42),
              width: _mode == _Mode.qr ? 250 : (size.width - 48).clamp(0, 320),
              height: _mode == _Mode.qr ? 250 : 150,
            );
            final found = _code != null;

            return Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  scanWindow: window,
                  errorBuilder: (_, error) => _CameraError(error: error),
                ),
                ScanOverlay(window: window, found: found),
                SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Quay lại',
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Quét mã sản phẩm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _TorchButton(controller: _controller),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ModeSwitch(
                        mode: _mode,
                        onChanged: (m) => setState(() {
                          _mode = m;
                          _code = null;
                          _product = null;
                        }),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 32,
                  right: 32,
                  top: window.bottom + 20,
                  child: Text(
                    _reading
                        ? 'Đang đọc mã trong ảnh…'
                        : found
                        ? 'Đã quét được mã'
                        : _mode.tip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16 + bottomInset,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: found
                        ? ScanResultCard(
                            key: ValueKey(_code),
                            code: _code!,
                            product: _product,
                            onAgain: _again,
                            onOpen: () => _openDetail(_product!),
                          )
                        : Row(
                            key: const ValueKey('actions'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _PillButton(
                                icon: Icons.image_outlined,
                                label: 'Chọn ảnh',
                                onTap: _reading ? null : _pickImage,
                              ),
                              const SizedBox(width: 12),
                              _PillButton(
                                icon: Icons.history,
                                label: 'Lịch sử',
                                onTap: _showHistory,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final _Mode mode;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final m in _Mode.values)
            GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: m == mode ? AppColors.rose : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  m.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        // Máy không có đèn (VD máy ảo) thì ẩn nút, giữ chỗ cho cân.
        if (state.torchState == TorchState.unavailable) {
          return const SizedBox(width: 48);
        }
        final on = state.torchState == TorchState.on;
        return IconButton(
          tooltip: on ? 'Tắt đèn flash' : 'Bật đèn flash',
          color: on ? AppColors.gold : Colors.white,
          icon: Icon(on ? Icons.flash_on : Icons.flash_off),
          onPressed: controller.toggleTorch,
        );
      },
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            denied
                ? 'LUMÉ chưa được phép dùng camera.\n'
                      'Bạn vẫn có thể bấm "Chọn ảnh" để đọc mã trong ảnh.'
                : 'Không mở được camera.\n'
                      'Bạn vẫn có thể bấm "Chọn ảnh" để đọc mã trong ảnh.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
