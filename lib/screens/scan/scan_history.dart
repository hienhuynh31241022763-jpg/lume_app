import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HT-07 · Id các sản phẩm đã quét gần đây (tối đa 10, mới nhất đứng đầu).
final ValueNotifier<List<String>> scanHistory = ValueNotifier(const []);

const _key = 'scan_history';
const _max = 10;
bool _loaded = false;

Future<void> loadScanHistory() async {
  if (_loaded) return;
  _loaded = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    scanHistory.value = prefs.getStringList(_key) ?? const [];
  } catch (_) {
    // Không đọc được thì bắt đầu với lịch sử trống.
  }
}

Future<void> addScan(String productId) async {
  final list = [
    productId,
    ...scanHistory.value.where((id) => id != productId),
  ].take(_max).toList();
  scanHistory.value = list;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, list);
  } catch (_) {
    // Không lưu được xuống máy thì vẫn giữ trong lúc app chạy.
  }
}
