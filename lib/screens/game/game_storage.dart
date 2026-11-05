import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_rules.dart';

/// Ghép Đôi LUMÉ · lưu lượt chơi trong ngày và túi quà (shared_preferences).
/// Tắt app mở lại vẫn còn. Sang ngày mới thì lượt chơi về lại [maxPlays].
class GameStorage {
  GameStorage._();

  static const maxPlays = 5;
  static const _dayKey = 'game_day';
  static const _playsKey = 'game_plays';
  static const _bagKey = 'game_bag';

  /// Số quà trong túi, để nút túi quà cập nhật ngay.
  static final bagCount = ValueNotifier<int>(0);

  static String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// Lượt chơi còn lại hôm nay.
  static Future<int> playsLeft() async {
    final prefs = await _prefs();
    if (prefs == null) return maxPlays;
    if (prefs.getString(_dayKey) != _today()) {
      await prefs.setString(_dayKey, _today());
      await prefs.setInt(_playsKey, maxPlays);
      return maxPlays;
    }
    return prefs.getInt(_playsKey) ?? maxPlays;
  }

  /// Trừ 1 lượt khi bắt đầu ván. Trả về true nếu ván này có quà.
  static Future<bool> usePlay() async {
    var left = await playsLeft();
    // Chạy thử bằng F5 (debug): hết lượt thì tự nạp lại, để demo luôn có vòng quay.
    // Bản phát hành (release) vẫn giới hạn lượt chơi mỗi ngày như bình thường.
    if (left <= 0 && kDebugMode) {
      await resetPlays();
      left = maxPlays;
    }
    if (left <= 0) return false;
    final prefs = await _prefs();
    await prefs?.setInt(_playsKey, left - 1);
    return true;
  }

  /// Trúng ô "Thêm lượt chơi".
  static Future<void> addPlay() async {
    final left = await playsLeft();
    final prefs = await _prefs();
    await prefs?.setInt(_playsKey, left + 1);
  }

  /// Chỉ dùng khi demo: trả lại đủ lượt chơi hôm nay.
  static Future<void> resetPlays() async {
    final prefs = await _prefs();
    await prefs?.setString(_dayKey, _today());
    await prefs?.setInt(_playsKey, maxPlays);
  }

  /// Quà đã trúng, mới nhất đứng đầu.
  static Future<List<Prize>> bag() async {
    final prefs = await _prefs();
    final ids = prefs?.getStringList(_bagKey) ?? const <String>[];
    final list = [
      for (final id in ids)
        if (prizeById(id) != null) prizeById(id)!,
    ];
    bagCount.value = list.length;
    return list;
  }

  // ───────────── Xu + điểm danh ─────────────

  static const _coinsKey = 'game_coins';
  static const _ciDayKey = 'checkin_day';
  static const _ciStreakKey = 'checkin_streak';

  /// Số xu hiện có, để ô xu cập nhật ngay.
  static final coins = ValueNotifier<int>(0);

  static String _dayString(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static Future<int> loadCoins() async {
    final prefs = await _prefs();
    coins.value = prefs?.getInt(_coinsKey) ?? 0;
    return coins.value;
  }

  static Future<void> addCoins(int n) async {
    final prefs = await _prefs();
    final next = (prefs?.getInt(_coinsKey) ?? coins.value) + n;
    await prefs?.setInt(_coinsKey, next);
    coins.value = next;
  }

  /// Tình trạng điểm danh: [done] là số ngày đã xong trong chuỗi (0–7),
  /// [checkedToday] là hôm nay đã bấm chưa. Bỏ lỡ 1 ngày thì chuỗi về 0.
  static Future<({int done, bool checkedToday})> checkInState() async {
    final prefs = await _prefs();
    final last = prefs?.getString(_ciDayKey);
    final streak = prefs?.getInt(_ciStreakKey) ?? 0;
    final now = DateTime.now();
    if (last == _dayString(now)) return (done: streak, checkedToday: true);
    final yesterday = _dayString(now.subtract(const Duration(days: 1)));
    if (last == yesterday && streak < checkInCoins.length) {
      return (done: streak, checkedToday: false);
    }
    return (done: 0, checkedToday: false);
  }

  /// Điểm danh hôm nay. Trả về số xu nhận được (0 nếu đã điểm danh rồi).
  static Future<int> checkIn() async {
    final state = await checkInState();
    if (state.checkedToday) return 0;
    final prefs = await _prefs();
    final reward = checkInCoins[state.done];
    final done = state.done + 1;
    await prefs?.setString(_ciDayKey, _dayString(DateTime.now()));
    await prefs?.setInt(_ciStreakKey, done);
    await addCoins(reward);
    if (done == checkInCoins.length) await addPrize(checkInGift);
    return reward;
  }

  /// Đổi xu lấy quà. Trả về false nếu không đủ xu.
  static Future<bool> redeem(ShopItem item) async {
    final have = await loadCoins();
    if (have < item.cost) return false;
    await addCoins(-item.cost);
    await addPrize(item.prize);
    return true;
  }

  static Future<void> addPrize(Prize prize) async {
    final prefs = await _prefs();
    final ids = [prize.id, ...?prefs?.getStringList(_bagKey)];
    await prefs?.setStringList(_bagKey, ids);
    bagCount.value = ids.length;
  }
}