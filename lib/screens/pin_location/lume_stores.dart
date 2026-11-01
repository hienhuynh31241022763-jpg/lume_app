import 'package:latlong2/latlong.dart';

/// Cửa hàng LUMÉ (giả định, nhóm chốt 2026-11-01): 3 ở TP.HCM, 1 ở Hà Nội.
/// Ghim vị trí dùng để báo cửa hàng gần nhất. Màn Về LUMÉ / Trợ giúp
/// muốn liệt kê cửa hàng thì dùng lại [lumeStores].
class LumeStore {
  const LumeStore(this.name, this.address, this.location);

  final String name;
  final String address;
  final LatLng location;
}

const lumeStores = [
  LumeStore(
    'LUMÉ Quận 1',
    '65 Lê Lợi, Bến Nghé, Quận 1, TP.HCM',
    LatLng(10.7743, 106.7009),
  ),
  LumeStore(
    'LUMÉ Quận 10',
    '468 Nguyễn Chí Thanh, Phường 7, Quận 10, TP.HCM',
    LatLng(10.7598, 106.6668),
  ),
  LumeStore(
    'LUMÉ Thủ Đức',
    '216 Võ Văn Ngân, Bình Thọ, TP. Thủ Đức, TP.HCM',
    LatLng(10.8505, 106.7716),
  ),
  LumeStore(
    'LUMÉ Hà Nội',
    '30 Tràng Tiền, Hoàn Kiếm, Hà Nội',
    LatLng(21.0245, 105.8553),
  ),
];

const _distance = Distance();

/// Cửa hàng gần [point] nhất và khoảng cách (mét).
(LumeStore, double) nearestStore(LatLng point) {
  var best = lumeStores.first;
  var bestMeters = _distance(point, best.location);
  for (final s in lumeStores.skip(1)) {
    final m = _distance(point, s.location);
    if (m < bestMeters) {
      best = s;
      bestMeters = m;
    }
  }
  return (best, bestMeters);
}

/// 850 → "850 m", 1700 → "1,7 km"
String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  final km = meters / 1000;
  final s = km >= 100 ? km.round().toString() : km.toStringAsFixed(1);
  return '${s.replaceAll('.', ',')} km';
}
