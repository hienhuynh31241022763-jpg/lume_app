import 'package:shared_preferences/shared_preferences.dart';

/// HT-01 · Nhớ họ tên và số điện thoại người nhận cho lần đặt sau.

const _nameKey = 'checkout_name';
const _phoneKey = 'checkout_phone';

Future<(String, String)> loadCustomerInfo() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_nameKey) ?? '', prefs.getString(_phoneKey) ?? '');
  } catch (_) {
    return ('', '');
  }
}

Future<void> saveCustomerInfo(String name, String phone) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
  } catch (_) {
    // Không lưu được thì lần sau nhập lại, không ảnh hưởng đơn hiện tại.
  }
}

/// Số di động Việt Nam: 10 số, bắt đầu bằng 0.
String? validatePhone(String? value) {
  final v = (value ?? '').replaceAll(' ', '');
  if (v.isEmpty) return 'Nhập số điện thoại người nhận';
  if (!RegExp(r'^0\d{9}$').hasMatch(v)) {
    return 'Số điện thoại gồm 10 số, bắt đầu bằng 0';
  }
  return null;
}
