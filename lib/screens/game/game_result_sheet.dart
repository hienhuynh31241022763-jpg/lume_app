import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../home/home_product_card.dart';
import '../product_detail/product_route.dart';
import 'game_rules.dart';
import 'game_storage.dart';
import 'lucky_wheel.dart';

/// Kết quả ván chơi. Trả về true nếu người chơi bấm "Chơi lại".
Future<bool?> showGameResult(
  BuildContext context, {
  required bool won,
  required int stars,
  required bool rewarded,
  required int donePairs,
  required int totalPairs,
  required int playsLeft,
  required List<PairKey> pairs,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ResultSheet(
      won: won,
      stars: stars,
      rewarded: rewarded,
      donePairs: donePairs,
      totalPairs: totalPairs,
      playsLeft: playsLeft,
      pairs: pairs,
    ),
  );
}

class _ResultSheet extends StatefulWidget {
  const _ResultSheet({
    required this.won,
    required this.stars,
    required this.rewarded,
    required this.donePairs,
    required this.totalPairs,
    required this.playsLeft,
    required this.pairs,
  });

  final bool won;
  final int stars;
  final bool rewarded;
  final int donePairs;
  final int totalPairs;
  final int playsLeft;
  final List<PairKey> pairs;

  @override
  State<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<_ResultSheet> {
  Prize? _prize;

  bool get _canSpin => widget.won && widget.rewarded;
  bool get _gold => widget.stars == 3;

  Future<void> _onPrize(Prize p) async {
    await GameStorage.addPrize(p);
    if (p.kind == PrizeKind.extraPlay) await GameStorage.addPlay();
    if (mounted) setState(() => _prize = p);
  }

  String get _title {
    if (!widget.won) return 'Hết giờ mất rồi';
    return _gold ? 'Xuất sắc, 3 sao!' : 'Đủ đôi rồi!';
  }

  String get _note {
    if (!widget.won) {
      return 'Ghép được ${widget.donePairs}/${widget.totalPairs} đôi. '
          'Còn ${widget.playsLeft} lượt chơi hôm nay.';
    }
    if (!widget.rewarded) return 'Hôm nay đã hết lượt nhận quà, bạn vẫn chơi được nhé';
    return _gold ? 'Bạn mở được vòng quay 3 sao, quà lớn dễ ra hơn' : 'Bạn nhận 1 lượt quay quà';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showShelf = !_canSpin || _prize != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: i < widget.stars ? AppColors.gold : AppColors.line,
                ),
            ],
          ),
          Text(
            _note,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          if (_canSpin) ...[
            const SizedBox(height: 18),
            LuckyWheel(gold: _gold, onResult: _onPrize),
          ],
          if (_prize != null) ...[
            const SizedBox(height: 14),
            _PrizeCard(prize: _prize!),
          ],
          if (showShelf) ...[
            const SizedBox(height: 16),
            _PairShelf(
              pairs: widget.pairs,
              tag: _prize?.kind == PrizeKind.pairDiscount ? _prize!.label : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_prize != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showPrizeBag(context),
                      child: const Text('Xem túi quà'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Chơi lại'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({required this.prize});

  final Prize prize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(prize.icon, color: AppColors.roseDark, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prize.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Text(
                  prize.detail,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Những đôi bạn vừa ghép": lướt ngang, bấm mở trang Chi tiết.
class _PairShelf extends StatelessWidget {
  const _PairShelf({required this.pairs, this.tag});

  final List<PairKey> pairs;

  /// Nhãn giảm giá khi trúng ô "-50K / -100K đôi vừa ghép".
  final String? tag;

  @override
  Widget build(BuildContext context) {
    const cardWidth = 140.0;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Những đôi bạn vừa ghép',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '${pairs.length} đôi',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: HomeProductCard.heightFor(cardWidth),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pairs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final k = pairs[i];
              final heroTag = 'game-${k.id}';
              return SizedBox(
                width: cardWidth,
                child: Stack(
                  children: [
                    HomeProductCard(
                      product: k.product,
                      heroTag: heroTag,
                      onTap: () => openProductDetail(context, k.product, heroTag: heroTag),
                    ),
                    if (tag != null)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.rose,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            tag!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Túi quà: các quà đã trúng.
Future<void> showPrizeBag(BuildContext context) async {
  final bag = await GameStorage.bag();
  if (!context.mounted) return;
  final textTheme = Theme.of(context).textTheme;
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Túi quà', textAlign: TextAlign.center, style: textTheme.titleLarge),
          Text(
            'Quà dùng ở bước Thanh toán',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          if (bag.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Chưa có quà nào. Thắng một ván để nhận lượt quay nhé.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: bag.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.line),
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(bag[i].icon, color: AppColors.roseDark, size: 20),
                  ),
                  title: Text(bag[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(bag[i].detail),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}