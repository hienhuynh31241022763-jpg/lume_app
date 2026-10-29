import 'package:flutter/foundation.dart';

/// HT-06 · Size đã lưu "vào hồ sơ", giữ trong lúc app chạy.
/// - Chi tiết sản phẩm tự chọn sẵn size này nếu đôi đó còn hàng.
/// - Màn Tài khoản (Hiền, HT-08) muốn hiện "Size của tôi" thì đọc
///   `savedShoeSize.value`, không cần sửa gì ở đây.
///
/// TODO: nhóm chưa có gói lưu trữ (shared_preferences) nên tắt app là mất.
final ValueNotifier<String?> savedShoeSize = ValueNotifier<String?>(null);
final ValueNotifier<double?> savedFootLength = ValueNotifier<double?>(null);