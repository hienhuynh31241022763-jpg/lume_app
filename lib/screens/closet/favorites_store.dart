import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Danh sách giày yêu thích (Tủ giày), lưu trên máy bằng shared_preferences.
/// Tắt app mở lại vẫn còn. Chưa gắn với tài khoản.
class FavoritesStore {
  FavoritesStore._();

  static const _key = 'favorite_ids';

  /// id sản phẩm theo thứ tự cất vào tủ (cũ trước, mới sau).
  static final ids = ValueNotifier<List<String>>(const []);

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      ids.value = prefs.getStringList(_key) ?? const [];
    } catch (_) {
      // Không đọc được thì coi như tủ trống.
    }
  }

  static bool contains(String id) => ids.value.contains(id);

  /// Thả tim / bỏ tim. Trả về true nếu vừa cất vào tủ.
  static Future<bool> toggle(String id) async {
    final list = [...ids.value];
    final added = !list.remove(id);
    if (added) list.add(id);
    ids.value = list;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, list);
    } catch (_) {}
    return added;
  }
}
