import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'delivery_address.dart';

/// HT-11 · "Sổ địa chỉ": nhóm chốt chỉ lưu 1 địa chỉ giao hàng.
/// - Ghim vị trí ghi vào đây khi bấm "Xác nhận vị trí này".
/// - Thanh toán (HT-01) đọc để điền sẵn địa chỉ.
/// - Màn Tài khoản (Hiền) muốn hiện địa chỉ thì đọc `savedAddress.value`
///   (gọi `loadSavedAddress()` một lần trước đó).
/// Lưu bằng shared_preferences nên tắt app vẫn còn.
final ValueNotifier<DeliveryAddress?> savedAddress =
    ValueNotifier<DeliveryAddress?>(null);

const _key = 'saved_address';
bool _loaded = false;

Future<void> loadSavedAddress() async {
  if (_loaded) return;
  _loaded = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || savedAddress.value != null) return;
    savedAddress.value = DeliveryAddress.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  } catch (_) {
    // Dữ liệu cũ hỏng thì bỏ qua, người dùng ghim lại là được.
  }
}

Future<void> saveAddress(DeliveryAddress address) async {
  savedAddress.value = address;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(address.toJson()));
  } catch (_) {
    // Không lưu được xuống máy thì vẫn giữ trong lúc app chạy.
  }
}
