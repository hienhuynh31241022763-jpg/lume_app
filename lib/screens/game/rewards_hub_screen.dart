import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'game_result_sheet.dart';
import 'game_rules.dart';
import 'game_storage.dart';
import 'match_card.dart';
import 'shoe_match_screen.dart';

/// Trang Ưu đãi LUMÉ (mở từ bong bóng nổi ở Trang chủ):
/// 1. Điểm danh mỗi ngày nhận xu (chuỗi 7 ngày).
/// 2. Khối game Ghép Đôi: bấm vào là chơi.
/// 3. Đổi xu lấy quà, quà vào chung Túi quà.
class RewardsHubScreen extends StatefulWidget {
  const RewardsHubScreen({super.key});

  @override
  State<RewardsHubScreen> createState() => _RewardsHubScreenState();
}

class _RewardsHubScreenState extends State<RewardsHubScreen> {
  int _done = 0;
  bool _checkedToday = false;
  bool _justChecked = false;
  int _playsLeft = GameStorage.maxPlays;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await GameStorage.loadCoins();
    await GameStorage.bag();
    final state = await GameStorage.checkInState();
    final plays = await GameStorage.playsLeft();
    if (!mounted) return;
    setState(() {
      _done = state.done;
      _checkedToday = state.checkedToday;
      _playsLeft = plays;
    });
  }

  Future<void> _checkIn() async {
    if (_checkedToday || _busy) return;
    _busy = true;
    final got = await GameStorage.checkIn();
    _busy = false;
    if (!mounted) return;
    setState(() {
      _done++;
      _checkedToday = true;
      _justChecked = true;
    });
    _toast(_done == checkInCoins.length
        ? '+$got xu và 1 quà chuỗi 7 ngày!'
        : '+$got xu, giữ chuỗi nhé!');
  }

  Future<void> _redeem(ShopItem item) async {
    if (_busy) return;
    _busy = true;
    final ok = await GameStorage.redeem(item);
    _busy = false;
    if (!mounted) return;
    setState(() {});
    _toast(ok ? 'Đã đổi ${item.prize.title}, xem trong Túi quà' : 'Chưa đủ xu');
  }

  Future<void> _openGame() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShoeMatchScreen()),
    );
    _load(); // quay lại thì cập nhật lượt chơi + túi quà
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: 'Ưu đãi ',
            children: [
              TextSpan(text: 'LUMÉ', style: TextStyle(color: AppColors.rose)),
            ],
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: GameStorage.coins,
            builder: (context, n, _) => GestureDetector(
              // Chạy thử (debug): nhấn giữ ô xu để cộng 100 xu khi demo.
              onLongPress: kDebugMode
                  ? () async {
                      await GameStorage.addCoins(100);
                      if (mounted) setState(() {});
                      _toast('+100 xu (chế độ demo)');
                    }
                  : null,
              child: _HeaderPill(
                leading: const CoinIcon(size: 16),
                label: '$n',
              ),
            ),
          ),
          const SizedBox(width: 6),
          ValueListenableBuilder<int>(
            valueListenable: GameStorage.bagCount,
            builder: (context, n, _) => _HeaderPill(
              leading: const Icon(
                Icons.card_giftcard_rounded,
                size: 16,
                color: AppColors.roseDark,
              ),
              label: '$n',
              onTap: () => showPrizeBag(context),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.rose,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            Text(
              'Điểm danh mỗi ngày lấy xu, chơi game săn quà, gom xu đổi ưu đãi.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            _CheckInBlock(
              done: _done,
              checkedToday: _checkedToday,
              justChecked: _justChecked,
              onCheckIn: _checkIn,
            ),
            const SizedBox(height: 12),
            _GameBlock(playsLeft: _playsLeft, onTap: _openGame),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: GameStorage.coins,
              builder: (context, coins, _) =>
                  _ShopBlock(coins: coins, onRedeem: _redeem),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Khối chung ─────────────────────────────

class _Block extends StatelessWidget {
  const _Block({required this.title, this.trailing, required this.child});

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Đồng xu vàng có chữ L, dùng chung cho cả trang.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9C77B),
        border: Border.all(color: const Color(0xFFC9A24F), width: size * .06),
      ),
      child: Text(
        'L',
        style: GoogleFonts.pinyonScript(
          fontSize: size * .62,
          height: 1,
          color: const Color(0xFF8A6A2C),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.leading, required this.label, this.onTap});

  final Widget leading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blush,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── 1. Điểm danh ─────────────────────────────

class _CheckInBlock extends StatelessWidget {
  const _CheckInBlock({
    required this.done,
    required this.checkedToday,
    required this.justChecked,
    required this.onCheckIn,
  });

  final int done;
  final bool checkedToday;
  final bool justChecked;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final today = checkedToday ? done - 1 : done;
    return _Block(
      title: 'Điểm danh mỗi ngày',
      trailing: 'Chuỗi $done/${checkInCoins.length} ngày',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < checkInCoins.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(
                  child: _DayTile(
                    index: i,
                    coins: checkInCoins[i],
                    done: i < done,
                    today: i == today,
                    stamp: justChecked && i == today,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          checkedToday
              ? OutlinedButton(
                  onPressed: null,
                  child: const Text('Đã điểm danh, mai quay lại nhé'),
                )
              : ElevatedButton(
                  onPressed: onCheckIn,
                  child: Text('Điểm danh nhận +${checkInCoins[today]} xu'),
                ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.index,
    required this.coins,
    required this.done,
    required this.today,
    required this.stamp,
  });

  final int index;
  final int coins;
  final bool done;
  final bool today;
  final bool stamp;

  @override
  Widget build(BuildContext context) {
    final last = index == checkInCoins.length - 1;
    final active = today && !done;
    final tile = Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: active ? AppColors.card : AppColors.background,
        gradient: last && !done
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3E3BC), AppColors.card],
              )
            : null,
        border: Border.all(
          color: active ? AppColors.rose : AppColors.line,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          last
              ? const Icon(Icons.card_giftcard_rounded, size: 16, color: AppColors.roseDark)
              : const CoinIcon(size: 16),
          const SizedBox(height: 3),
          Text(
            '+$coins',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          Text(
            today ? 'Nay' : 'N${index + 1}',
            style: TextStyle(
              fontSize: 10.5,
              color: active ? AppColors.roseDark : AppColors.muted,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
    if (!done) return tile;

    // Đã điểm danh: phủ hồng + dấu ✓ (ngày vừa bấm thì dấu ✓ đóng xuống).
    final check = Container(
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check_rounded, color: AppColors.roseDark, size: 22),
    );
    return Stack(
      children: [
        tile,
        Positioned.fill(
          child: stamp && !MediaQuery.disableAnimationsOf(context)
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.6, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  builder: (context, s, child) => Opacity(
                    opacity: ((1.6 - s) / .6).clamp(0.0, 1.0),
                    child: Transform.scale(scale: s, child: child),
                  ),
                  child: check,
                )
              : check,
        ),
      ],
    );
  }
}

// ───────────────────────────── 2. Khối game ─────────────────────────────

class _GameBlock extends StatelessWidget {
  const _GameBlock({required this.playsLeft, required this.onTap});

  final int playsLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blush, Color(0xFFF7EBD6)],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            child: Row(
              children: [
                const _CardFan(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GAME HÔM NAY',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .8,
                          color: AppColors.roseDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ghép Đôi LUMÉ',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lật hộp, ghép 2 nửa đôi giày. Thắng là được quay quà.',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: 'Còn ',
                          children: [
                            TextSpan(
                              text: '$playsLeft/${GameStorage.maxPlays}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: ' lượt hôm nay'),
                          ],
                        ),
                        style: textTheme.bodySmall?.copyWith(color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.rose,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Chơi ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3 thẻ hoa xoè ra như quạt bài.
class _CardFan extends StatelessWidget {
  const _CardFan();

  @override
  Widget build(BuildContext context) {
    Widget card(double angle, double dx) => Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 50,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x40B45A73), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: const CardBack(),
        ),
      ),
    );
    return SizedBox(
      width: 80,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          card(-.26, -6),
          card(.26, 6),
          card(0, 0),
        ],
      ),
    );
  }
}

// ───────────────────────────── 3. Đổi xu ─────────────────────────────

class _ShopBlock extends StatelessWidget {
  const _ShopBlock({required this.coins, required this.onRedeem});

  final int coins;
  final ValueChanged<ShopItem> onRedeem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Không bọc khung trắng: vé trắng nằm trên nền trang cho rõ khuyết vé.
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Đổi xu lấy voucher',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            'Mỗi voucher dùng một lần, áp ở Giỏ hàng.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          for (final item in shopItems) ...[
            _VoucherTicket(item: item, coins: coins, onRedeem: () => onRedeem(item)),
            if (item != shopItems.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Voucher dạng vé: cuống màu bên trái (GIẢM / 20K), thân trắng bên phải,
/// 2 khuyết tròn ở chỗ nối như vé xé.
class _VoucherTicket extends StatelessWidget {
  const _VoucherTicket({required this.item, required this.coins, required this.onRedeem});

  final ShopItem item;
  final int coins;
  final VoidCallback onRedeem;

  static const _stubW = 78.0;
  static const _h = 86.0;

  @override
  Widget build(BuildContext context) {
    final lack = item.cost - coins;
    final canRedeem = lack <= 0;
    final stubColor = item.isGift ? const Color(0xFFC9A96E) : AppColors.rose;

    return PhysicalShape(
      clipper: const _TicketClipper(notchX: _stubW, radius: 7),
      // Cắt cả nội dung (cuống màu) theo hình vé, nếu không góc sẽ vuông.
      clipBehavior: Clip.antiAlias,
      color: AppColors.card,
      elevation: 1.5,
      shadowColor: const Color(0x33B45A73),
      child: SizedBox(
        height: _h,
        child: Row(
          children: [
            // cuống vé
            Container(
              width: _stubW,
              color: stubColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.stubTop,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .85),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (item.stubMain != null)
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          item.stubMain!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(item.stubIcon, color: Colors.white, size: 26),
                ],
              ),
            ),
            // thân vé
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.prize.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.prize.detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Material(
                          color: canRedeem ? AppColors.rose : AppColors.blush,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: canRedeem ? onRedeem : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CoinIcon(size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    canRedeem ? 'Đổi ${item.cost}' : '${item.cost}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: canRedeem ? Colors.white : const Color(0xFF94722F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          canRedeem ? 'Đủ xu để đổi' : 'Còn thiếu $lack xu',
                          style: TextStyle(
                            fontSize: 11,
                            color: canRedeem ? AppColors.roseDark : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hình vé: bo góc, có 2 khuyết nửa tròn ở trên và dưới tại chỗ nối cuống.
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({required this.notchX, required this.radius});

  final double notchX;
  final double radius;

  @override
  Path getClip(Size size) {
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(notchX, 0), radius: radius))
      ..addOval(Rect.fromCircle(center: Offset(notchX, size.height), radius: radius));
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(covariant _TicketClipper old) =>
      old.notchX != notchX || old.radius != radius;
}