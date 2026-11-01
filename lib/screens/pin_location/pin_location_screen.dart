import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_colors.dart';
import 'delivery_address.dart';
import 'lume_stores.dart';
import 'pin_address_panel.dart';
import 'saved_address.dart';

/// HT-11 · Ghim vị trí giao hàng
/// - Mở từ nút "Đổi" ở Thanh toán (nhận lại [DeliveryAddress] khi pop),
///   hoặc từ "Sổ địa chỉ" ở Tài khoản (chỉ lưu).
/// - Kéo bản đồ, ghim luôn nằm giữa; dừng kéo thì tự đổi ra địa chỉ.
/// - Nút định vị đưa về chỗ đang đứng; báo cửa hàng LUMÉ gần nhất.
/// - Ghi chú cho shipper, lưu nhãn Nhà riêng / Công ty / Khác.
class PinLocationScreen extends StatefulWidget {
  const PinLocationScreen({super.key});

  @override
  State<PinLocationScreen> createState() => _PinLocationScreenState();
}

class _PinLocationScreenState extends State<PinLocationScreen> {
  /// Chưa ghim lần nào thì mở ở Quận 10, TP.HCM.
  static const _defaultCenter = LatLng(10.7626, 106.6669);

  final _map = MapController();
  final _note = TextEditingController();
  final _search = TextEditingController();
  final _geocoding = Geocoding(locale: const Locale('vi', 'VN'));

  LatLng _center = _defaultCenter;
  String _label = DeliveryAddress.labels.first;
  String _line1 = '';
  String _line2 = '';
  bool _moving = false;
  bool _resolving = true;
  bool _locating = false;
  Timer? _settle;
  int _lookup = 0; // bỏ kết quả địa chỉ cũ khi bản đồ đã dời tiếp

  @override
  void initState() {
    super.initState();
    final saved = savedAddress.value;
    if (saved != null) {
      // Đã có địa chỉ: mở bản đồ ngay tại đó.
      _center = LatLng(saved.lat, saved.lng);
      _fill(saved);
      return;
    }
    loadSavedAddress().then((_) {
      final loaded = savedAddress.value;
      if (!mounted) return;
      if (loaded == null) {
        _resolve(_center);
        return;
      }
      setState(() => _fill(loaded));
      _map.move(LatLng(loaded.lat, loaded.lng), 17);
    });
  }

  void _fill(DeliveryAddress saved) {
    _note.text = saved.note;
    _label = saved.label;
    _line1 = saved.line1;
    _line2 = saved.line2;
    _resolving = false;
  }

  @override
  void dispose() {
    _settle?.cancel();
    _map.dispose();
    _note.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    final center = event.camera.center;
    if (center == _center) return;
    _center = center;
    if (!_moving) setState(() => _moving = true);
    _settle?.cancel();
    _settle = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _moving = false);
      _resolve(_center);
    });
  }

  Future<void> _resolve(LatLng point) async {
    final id = ++_lookup;
    setState(() => _resolving = true);
    var line1 = 'Vị trí đã ghim';
    var line2 =
        '${point.latitude.toStringAsFixed(5)}, '
        '${point.longitude.toStringAsFixed(5)}';
    try {
      final places = await _geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      final p = places.firstOrNull;
      if (p != null) {
        final street = [
          p.subThoroughfare,
          p.thoroughfare,
        ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
        line1 = [
          street,
          p.street,
          p.name,
        ].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => line1)!;
        line2 = [p.subLocality, p.subAdministrativeArea, p.administrativeArea]
            .whereType<String>()
            .where((s) => s.isNotEmpty && !line1.contains(s))
            .join(', ');
      }
    } catch (_) {
      // Máy không có dịch vụ đổi địa chỉ hoặc mất mạng: giữ tọa độ.
    }
    if (!mounted || id != _lookup) return;
    setState(() {
      _line1 = line1;
      _line2 = line2;
      _resolving = false;
    });
  }

  Future<void> _locateMe() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast('Hãy bật định vị (GPS) trên máy');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _toast('LUMÉ chưa được phép dùng vị trí của bạn');
        return;
      }
      setState(() => _locating = true);
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          // Android: đọc GPS trực tiếp, không bắt bật "Location Accuracy"
          // của Google Play Services.
          locationSettings: defaultTargetPlatform == TargetPlatform.android
              ? AndroidSettings(
                  accuracy: LocationAccuracy.high,
                  forceLocationManager: true,
                  timeLimit: const Duration(seconds: 10),
                )
              : const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  timeLimit: Duration(seconds: 10),
                ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) throw StateError('no position');
      _map.move(LatLng(pos.latitude, pos.longitude), 17);
    } catch (_) {
      _toast('Không lấy được vị trí, thử lại sau nhé');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _searchAddress(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    try {
      final found = await _geocoding.locationFromAddress(q);
      final first = found.firstOrNull;
      if (first == null) throw StateError('empty');
      _map.move(LatLng(first.latitude, first.longitude), 17);
    } catch (_) {
      _toast('Không tìm thấy "$q", thử ghi rõ hơn nhé');
    }
  }

  Future<void> _confirm() async {
    final address = DeliveryAddress(
      label: _label,
      line1: _line1,
      line2: _line2,
      lat: _center.latitude,
      lng: _center.longitude,
      note: _note.text.trim(),
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await saveAddress(address);
    messenger.showSnackBar(
      const SnackBar(content: Text('Đã lưu địa chỉ giao hàng')),
    );
    navigator.pop(address);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final (store, meters) = nearestStore(_center);
    final busy = _moving || _resolving;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 16,
                    minZoom: 4,
                    maxZoom: 19,
                    onMapEvent: _onMapEvent,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.lume_app',
                    ),
                    MarkerLayer(
                      markers: [
                        for (final s in lumeStores)
                          Marker(
                            point: s.location,
                            width: 34,
                            height: 34,
                            child: Tooltip(
                              message: s.name,
                              child: const CircleAvatar(
                                backgroundColor: AppColors.roseDark,
                                child: Icon(
                                  Icons.storefront,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const RichAttributionWidget(
                      alignment: AttributionAlignment.bottomLeft,
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                _CenterPin(lifted: _moving),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        _RoundButton(
                          icon: Icons.arrow_back_ios_new,
                          tooltip: 'Quay lại',
                          onTap: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Material(
                            color: AppColors.card,
                            elevation: 2,
                            borderRadius: BorderRadius.circular(24),
                            child: TextField(
                              controller: _search,
                              textInputAction: TextInputAction.search,
                              onSubmitted: _searchAddress,
                              decoration: const InputDecoration(
                                hintText: 'Tìm địa chỉ, tòa nhà…',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _RoundButton(
                    icon: Icons.my_location,
                    tooltip: 'Về vị trí của tôi',
                    loading: _locating,
                    onTap: _locating ? null : _locateMe,
                  ),
                ),
              ],
            ),
          ),
          PinAddressPanel(
            line1: _line1,
            line2: _line2,
            resolving: busy,
            store: store,
            storeMeters: meters,
            noteController: _note,
            label: _label,
            onLabel: (l) => setState(() => _label = l),
            onConfirm: busy ? null : _confirm,
          ),
        ],
      ),
    );
  }
}

/// Ghim cố định giữa bản đồ, nhấc lên khi đang kéo.
class _CenterPin extends StatelessWidget {
  const _CenterPin({required this.lifted});

  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Bóng ở đúng điểm ghim.
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: lifted ? 10 : 16,
              height: lifted ? 4 : 6,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: lifted ? 0.15 : 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Đầu nhọn của icon nằm đúng điểm giữa.
            AnimatedSlide(
              duration: const Duration(milliseconds: 150),
              offset: Offset(0, lifted ? -0.75 : -0.46),
              child: const Icon(
                Icons.location_on,
                size: 52,
                color: AppColors.rose,
                shadows: [Shadow(color: Color(0x33000000), blurRadius: 6)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: AppColors.ink, size: 20),
      ),
    );
  }
}
