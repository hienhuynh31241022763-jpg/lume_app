/// Tiếp thị liên kết: mã giới thiệu, mức giảm và hoa hồng.
class Referral {
  Referral._();

  /// Người được giới thiệu mua hàng thì giảm 5%.
  static const discountRate = 0.05;

  /// Người giới thiệu nhận 5% giá trị đơn đã giao.
  static const commissionRate = 0.05;

  static const _prefix = 'LUME';
  static final _format = RegExp(r'^LUME[A-Z0-9]{5}$');

  /// Mã của mỗi người = LUME + 5 ký tự đầu của mã người dùng Firebase.
  static String codeFor(String uid) {
    if (uid.length < 5) return '';
    return '$_prefix${uid.substring(0, 5).toUpperCase()}';
  }

  static bool isValidFormat(String code) => _format.hasMatch(code);
}
