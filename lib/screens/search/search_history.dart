import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MH-07 · Lịch sử tìm kiếm: tối đa 10 từ khoá, mới nhất đứng đầu.
/// Lưu bằng shared_preferences nên tắt app vẫn còn.
final ValueNotifier<List<String>> searchHistory = ValueNotifier(const []);

const _key = 'search_history';
const _max = 10;
bool _loaded = false;

Future<void> loadSearchHistory() async {
  if (_loaded) return;
  _loaded = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.value = prefs.getStringList(_key) ?? const [];
  } catch (_) {
    // Không đọc được thì bắt đầu với lịch sử trống.
  }
}

/// Đưa từ khoá lên đầu; trùng (không phân biệt hoa thường) thì bỏ bản cũ.
void addSearch(String query) {
  final q = query.trim();
  if (q.isEmpty) return;
  _save(
    [
      q,
      ...searchHistory.value.where((s) => s.toLowerCase() != q.toLowerCase()),
    ].take(_max).toList(),
  );
}

void removeSearch(String query) =>
    _save(searchHistory.value.where((s) => s != query).toList());

void clearSearchHistory() => _save(const []);

Future<void> _save(List<String> list) async {
  searchHistory.value = list;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, list);
  } catch (_) {
    // Không lưu được xuống máy thì vẫn giữ trong lúc app chạy.
  }
}
