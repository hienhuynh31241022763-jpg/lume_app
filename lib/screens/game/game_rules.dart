import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/product.dart';

/// Ghép Đôi LUMÉ · luật chơi (chỉ có logic, không có giao diện).
/// - Mỗi đôi giày bị cắt thành 2 nửa ảnh (trái / phải), lật tìm 2 nửa khớp.
/// - Từ mức Vừa có "đôi giả": cùng mẫu nhưng khác màu, ghép nhầm không tính.
/// - Thắng thì được 1 lượt quay. 3 sao được vòng quay 3 sao (tỉ lệ quà tốt hơn).

// ───────────────────────────── Độ khó ─────────────────────────────

class GameLevel {
  const GameLevel(this.label, this.pairs, this.seconds, this.traps);

  final String label;
  final int pairs;
  final int seconds;

  /// Số mẫu bị lấy 2 màu (mỗi mẫu tạo thêm 1 "đôi giả").
  final int traps;

  /// Lật sai tối đa bao nhiêu lần thì vẫn được 3 sao.
  int get threeStarMistakes => pairs ~/ 2;
}

const gameLevels = [
  GameLevel('Dễ', 3, 35, 0),
  GameLevel('Vừa', 6, 60, 1),
  GameLevel('Khó', 8, 75, 2),
];

// ───────────────────────────── Thẻ ─────────────────────────────

/// Một đôi trong ván: 1 sản phẩm + 1 màu.
class PairKey {
  PairKey(this.product, this.color);

  final Product product;
  final String color;

  /// Ảnh của đúng màu này, điền sau khi tải ảnh theo màu.
  String image = '';

  /// Tỉ lệ rộng/cao của ảnh gốc, để cắt đúng một nửa ảnh dù ảnh to nhỏ khác nhau.
  double aspect = 1;

  String get id => '${product.id}|$color';
}

/// Một thẻ trên bàn: nửa trái hoặc nửa phải của một đôi.
class MatchCard {
  MatchCard(this.pair, {required this.left});

  final PairKey pair;
  final bool left;
  bool open = false;
  bool done = false;

  /// Tăng lên mỗi lần ghép sai để thẻ rung.
  int shakeTick = 0;
}

/// Chọn các đôi cho ván chơi. Mẫu có từ 2 màu được ưu tiên làm "đôi giả".
List<PairKey> pickPairs(List<Product> products, GameLevel level, Random rng) {
  final pool = [...products]..shuffle(rng);
  final pairs = <PairKey>[];

  final multi = pool.where((p) => p.colors.length > 1).take(level.traps);
  for (final p in multi) {
    pairs
      ..add(PairKey(p, p.colors[0]))
      ..add(PairKey(p, p.colors[1]));
  }

  final used = pairs.map((k) => k.product.id).toSet();
  for (final p in pool) {
    if (pairs.length >= level.pairs) break;
    if (used.contains(p.id)) continue;
    final color = p.colors.isEmpty ? '' : p.colors[rng.nextInt(p.colors.length)];
    pairs.add(PairKey(p, color));
    used.add(p.id);
  }
  return pairs.take(level.pairs).toList();
}

/// Mỗi đôi thành 2 thẻ (nửa trái, nửa phải) rồi trộn.
List<MatchCard> buildDeck(List<PairKey> pairs, Random rng) {
  return [
    for (final k in pairs) ...[
      MatchCard(k, left: true),
      MatchCard(k, left: false),
    ],
  ]..shuffle(rng);
}

/// 0 sao khi thua. Thắng: 3 sao nếu ít lần lật sai, 2 sao, rồi 1 sao.
int starsFor({
  required bool won,
  required int mistakes,
  required GameLevel level,
}) {
  if (!won) return 0;
  if (mistakes <= level.threeStarMistakes) return 3;
  if (mistakes <= level.pairs) return 2;
  return 1;
}

// ───────────────────────────── Vòng quay ─────────────────────────────

enum PrizeKind { voucher, freeship, pairDiscount, extraPlay, gift }

class Prize {
  const Prize({
    required this.id,
    required this.title,
    required this.label,
    required this.detail,
    required this.icon,
    required this.tone,
    required this.kind,
    required this.weight,
    required this.goldWeight,
    this.value = 0,
  });

  final String id;

  /// Tên đầy đủ (túi quà, thẻ trúng thưởng).
  final String title;

  /// Chữ ngắn trên ô vòng quay.
  final String label;
  final String detail;
  final IconData icon;

  /// Màu ô: 0 hồng nhạt · 1 kem · 2 hồng đậm · 3 vàng.
  final int tone;
  final PrizeKind kind;

  /// Trọng số ở vòng quay thường / vòng quay 3 sao (mỗi cột cộng lại = 100).
  final int weight;
  final int goldWeight;

  /// % giảm hoặc số tiền giảm (₫), tuỳ loại quà.
  final int value;
}

const prizes = [
  Prize(
    id: 'v10',
    title: 'Giảm 10%',
    label: '10%',
    detail: 'Mã GHEPDOI10, tối đa 100.000₫ cho đơn tiếp theo',
    icon: Icons.confirmation_number_outlined,
    tone: 0,
    kind: PrizeKind.voucher,
    weight: 22,
    goldWeight: 14,
    value: 10,
  ),
  Prize(
    id: 'ship',
    title: 'Freeship',
    label: 'Freeship',
    detail: 'Miễn phí giao hàng cho 1 đơn',
    icon: Icons.local_shipping_outlined,
    tone: 1,
    kind: PrizeKind.freeship,
    weight: 22,
    goldWeight: 14,
  ),
  Prize(
    id: 'pair50',
    title: '-50K đôi vừa ghép',
    label: '-50K',
    detail: 'Giảm 50.000₫ cho 1 trong các đôi bạn vừa ghép',
    icon: Icons.sell_outlined,
    tone: 2,
    kind: PrizeKind.pairDiscount,
    weight: 16,
    goldWeight: 18,
    value: 50000,
  ),
  Prize(
    id: 'play',
    title: 'Thêm lượt chơi',
    label: '+1 lượt',
    detail: 'Chơi thêm 1 ván hôm nay',
    icon: Icons.replay_rounded,
    tone: 1,
    kind: PrizeKind.extraPlay,
    weight: 18,
    goldWeight: 10,
  ),
  Prize(
    id: 'v15',
    title: 'Giảm 15%',
    label: '15%',
    detail: 'Mã GHEPDOI15, tối đa 150.000₫',
    icon: Icons.confirmation_number_outlined,
    tone: 0,
    kind: PrizeKind.voucher,
    weight: 10,
    goldWeight: 14,
    value: 15,
  ),
  Prize(
    id: 'gift',
    title: 'Quà bất ngờ',
    label: 'Quà bí mật',
    detail: 'Tặng túi vải LUMÉ kèm đơn tiếp theo',
    icon: Icons.card_giftcard_rounded,
    tone: 3,
    kind: PrizeKind.gift,
    weight: 6,
    goldWeight: 12,
  ),
  Prize(
    id: 'pair100',
    title: '-100K đôi vừa ghép',
    label: '-100K',
    detail: 'Giảm 100.000₫ cho 1 trong các đôi bạn vừa ghép',
    icon: Icons.sell_outlined,
    tone: 2,
    kind: PrizeKind.pairDiscount,
    weight: 5,
    goldWeight: 12,
    value: 100000,
  ),
  Prize(
    id: 'v25',
    title: 'Giảm 25%',
    label: '25%',
    detail: 'Mã GHEPDOI25, tối đa 300.000₫',
    icon: Icons.diamond_outlined,
    tone: 3,
    kind: PrizeKind.voucher,
    weight: 1,
    goldWeight: 6,
    value: 25,
  ),
];

/// Chọn ô trúng theo trọng số. Trả về vị trí trong [prizes].
/// App thật nên để máy chủ quay hộ, tránh người dùng sửa kết quả.
int pickPrize({required bool gold, required Random rng}) {
  final total = prizes.fold<int>(
    0,
    (s, p) => s + (gold ? p.goldWeight : p.weight),
  );
  var r = rng.nextInt(total);
  for (var i = 0; i < prizes.length; i++) {
    r -= gold ? prizes[i].goldWeight : prizes[i].weight;
    if (r < 0) return i;
  }
  return 0;
}

Prize? prizeById(String id) {
  for (final p in prizes) {
    if (p.id == id) return p;
  }
  for (final item in shopItems) {
    if (item.prize.id == id) return item.prize;
  }
  if (id == checkInGift.id) return checkInGift;
  return null;
}

// ─────────────────────── Điểm danh + Đổi xu ───────────────────────

/// Xu nhận được theo từng ngày trong chuỗi 7 ngày điểm danh.
const checkInCoins = [10, 10, 15, 15, 20, 20, 50];

/// Quà nhỏ tặng thêm khi điểm danh đủ ngày thứ 7.
const checkInGift = Prize(
  id: 'ci_gift',
  title: 'Quà chuỗi 7 ngày',
  label: 'Quà',
  detail: 'Tặng móc khoá LUMÉ kèm đơn tiếp theo',
  icon: Icons.card_giftcard_rounded,
  tone: 3,
  kind: PrizeKind.gift,
  weight: 0,
  goldWeight: 0,
);

class ShopItem {
  const ShopItem(this.prize, this.cost, {required this.stubTop, this.stubMain, this.stubIcon});

  final Prize prize;
  final int cost;

  /// Chữ nhỏ trên cuống vé (GIẢM, FREE, QUÀ).
  final String stubTop;

  /// Chữ to trên cuống vé (20K, 10%, SHIP). Null thì dùng [stubIcon].
  final String? stubMain;
  final IconData? stubIcon;

  bool get isGift => prize.kind == PrizeKind.gift;
}

const shopItems = [
  ShopItem(
    Prize(
      id: 'x_ship',
      title: 'Freeship',
      label: 'Freeship',
      detail: 'Miễn phí giao 1 đơn · HSD 30 ngày',
      icon: Icons.local_shipping_outlined,
      tone: 1,
      kind: PrizeKind.freeship,
      weight: 0,
      goldWeight: 0,
    ),
    80,
    stubTop: 'FREE',
    stubMain: 'SHIP',
  ),
  ShopItem(
    Prize(
      id: 'x_v10',
      title: 'Giảm 10%',
      label: '10%',
      detail: 'Tối đa 50.000₫ · HSD 30 ngày',
      icon: Icons.confirmation_number_outlined,
      tone: 0,
      kind: PrizeKind.voucher,
      weight: 0,
      goldWeight: 0,
      value: 10,
    ),
    100,
    stubTop: 'GIẢM',
    stubMain: '10%',
  ),
  ShopItem(
    Prize(
      id: 'x_50k',
      title: 'Giảm 50.000₫',
      label: '-50K',
      detail: 'Đơn từ 500.000₫ · HSD 30 ngày',
      icon: Icons.confirmation_number_outlined,
      tone: 0,
      kind: PrizeKind.voucher,
      weight: 0,
      goldWeight: 0,
      value: 50000,
    ),
    200,
    stubTop: 'GIẢM',
    stubMain: '50K',
  ),
  ShopItem(
    Prize(
      id: 'x_sock',
      title: 'Tất cotton LUMÉ',
      label: 'Tất',
      detail: 'Tặng kèm đơn tiếp theo',
      icon: Icons.checkroom_outlined,
      tone: 3,
      kind: PrizeKind.gift,
      weight: 0,
      goldWeight: 0,
    ),
    300,
    stubTop: 'QUÀ',
    stubIcon: Icons.checkroom_outlined,
  ),
  ShopItem(
    Prize(
      id: 'x_tote',
      title: 'Túi vải LUMÉ',
      label: 'Túi',
      detail: 'Tặng kèm đơn tiếp theo',
      icon: Icons.shopping_bag_outlined,
      tone: 3,
      kind: PrizeKind.gift,
      weight: 0,
      goldWeight: 0,
    ),
    500,
    stubTop: 'QUÀ',
    stubIcon: Icons.shopping_bag_outlined,
  ),
  ShopItem(
    Prize(
      id: 'x_v25',
      title: 'Giảm 25%',
      label: '25%',
      detail: 'Tối đa 300.000₫ · HSD 30 ngày',
      icon: Icons.diamond_outlined,
      tone: 3,
      kind: PrizeKind.voucher,
      weight: 0,
      goldWeight: 0,
      value: 25,
    ),
    800,
    stubTop: 'GIẢM',
    stubMain: '25%',
  ),
];