import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../home/demo_data.dart';
import '../product_detail/product_images.dart';
import 'game_result_sheet.dart';
import 'game_rules.dart';
import 'game_storage.dart';
import 'match_card.dart';

/// Ghép Đôi LUMÉ: lật hộp, ghép 2 nửa ảnh của cùng một đôi giày.
/// Thắng thì quay vòng quay quà. Mở từ banner ở Trang chủ.
class ShoeMatchScreen extends StatefulWidget {
  const ShoeMatchScreen({super.key});

  @override
  State<ShoeMatchScreen> createState() => _ShoeMatchScreenState();
}

class _ShoeMatchScreenState extends State<ShoeMatchScreen>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late final _join = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  int _levelIndex = 0;
  bool _loading = true;
  List<PairKey> _pairs = [];
  List<MatchCard> _deck = [];
  final List<int> _open = [];
  bool _lock = false;
  int _done = 0;
  int _misses = 0;
  bool _started = false;
  bool _rewarded = false;
  double _timeLeft = 0;
  Timer? _timer;
  int _playsLeft = GameStorage.maxPlays;
  PairKey? _joining;

  GameLevel get _level => gameLevels[_levelIndex];

  @override
  void initState() {
    super.initState();
    GameStorage.bag();
    WidgetsBinding.instance.addPostFrameCallback((_) => _newGame());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _join.dispose();
    super.dispose();
  }

  Future<void> _newGame() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _open.clear();
      _lock = false;
      _done = 0;
      _misses = 0;
      _started = false;
      _timeLeft = _level.seconds.toDouble();
      _joining = null;
    });
    final plays = await GameStorage.playsLeft();
    if (!mounted) return;
    final all = productsOf(context.read<ProductProvider>());
    // Màn Dễ: chỉ lấy giày búp bê + giày cao gót cho ván đầu thật xinh.
    // Không đủ mẫu thì lấy tất cả.
    final featured = all.where((p) {
      final c = p.category.toLowerCase();
      return c.contains('búp bê') || c.contains('cao gót');
    }).toList();
    final products = _levelIndex == 0 && featured.length >= _level.pairs + 2
        ? featured
        : all;

    // Chọn đôi, rồi loại mẫu có ảnh không hợp để cắt đôi (ảnh dọc, ảnh lỗi).
    // Ảnh dọc cắt ra mỗi nửa rất hẹp, phóng to lên thẻ sẽ vỡ và khó nhìn.
    final excluded = <String>{};
    var pairs = <PairKey>[];
    for (var attempt = 0; attempt < 4; attempt++) {
      final pool = products.where((p) => !excluded.contains(p.id)).toList();
      pairs = pickPairs(pool.length >= _level.pairs ? pool : products, _level, _rng);
      // Lấy đúng ảnh của màu được chọn (mảng `images` trên API), không có thì dùng ảnh chính.
      await Future.wait(
        pairs.map((k) async {
          final list = await fetchColorImages(k.product.id);
          final imgs = imagesForColor(k.product, list, k.color);
          k.image = imgs.isNotEmpty ? imgs.first : k.product.image;
          k.aspect = await loadImageAspect(k.image);
        }),
      );
      final bad = pairs.where((k) => k.image.isEmpty || k.aspect < _minAspect);
      if (bad.isEmpty) break;
      excluded.addAll(bad.map((k) => k.product.id));
    }
    if (!mounted) return;
    setState(() {
      _playsLeft = plays;
      _pairs = pairs;
      _deck = buildDeck(pairs, _rng);
      _loading = false;
    });
  }

  Future<void> _start() async {
    _started = true;
    var last = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now = DateTime.now();
      setState(() {
        _timeLeft = max(0, _timeLeft - now.difference(last).inMilliseconds / 1000);
      });
      last = now;
      if (_timeLeft <= 0) _finish(won: false);
    });
    _rewarded = await GameStorage.usePlay();
    _playsLeft = await GameStorage.playsLeft();
    if (mounted) setState(() {});
  }

  void _tap(int i) {
    final card = _deck[i];
    if (_lock || card.open || card.done || _loading) return;
    if (!_started) _start();
    setState(() {
      card.open = true;
      _open.add(i);
    });
    if (_open.length < 2) return;

    final a = _deck[_open[0]], b = _deck[_open[1]];
    _open.clear();

    if (a.pair == b.pair) {
      _done++;
      _toast('Đúng đôi rồi!');
      if (MediaQuery.disableAnimationsOf(context)) {
        _markDone(a, b);
      } else {
        _lock = true;
        setState(() => _joining = a.pair);
        _join.forward(from: 0).then((_) {
          if (!mounted) return;
          setState(() => _joining = null);
          _lock = false;
          _markDone(a, b);
        });
      }
    } else {
      _misses++;
      _lock = true;
      if (a.pair.product.id == b.pair.product.id) {
        _toast('Cùng mẫu nhưng khác màu đó!');
      }
      Future.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        setState(() {
          a.shakeTick++;
          b.shakeTick++;
        });
      });
      Future.delayed(const Duration(milliseconds: 950), () {
        if (!mounted) return;
        setState(() {
          a.open = false;
          b.open = false;
          _lock = false;
        });
      });
    }
  }

  void _markDone(MatchCard a, MatchCard b) {
    setState(() {
      a.done = true;
      b.done = true;
    });
    if (_done == _pairs.length) _finish(won: true);
  }

  Future<void> _finish({required bool won}) async {
    if (_timer == null) return;
    _timer?.cancel();
    _timer = null;
    _lock = true;
    final stars = starsFor(won: won, mistakes: _misses, level: _level);
    await Future.delayed(Duration(milliseconds: won ? 450 : 200));
    if (!mounted) return;
    final again = await showGameResult(
      context,
      won: won,
      stars: stars,
      rewarded: _rewarded,
      donePairs: _done,
      totalPairs: _pairs.length,
      playsLeft: _playsLeft,
      pairs: _pairs,
    );
    if (!mounted) return;
    if (again ?? true) _newGame();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _pickLevel(int i) {
    if (i == _levelIndex && !_started) return;
    setState(() => _levelIndex = i);
    _newGame();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = _level;

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'Ghép ',
            children: const [
              TextSpan(text: 'Đôi', style: TextStyle(color: AppColors.rose)),
            ],
          ),
        ),
        actions: [
          // Bản chạy thử (debug): nhấn giữ ô "Lượt" để lấy lại đủ lượt khi demo.
          // Bản phát hành (release) không có tính năng này.
          GestureDetector(
            onLongPress: kDebugMode
                ? () async {
                    await GameStorage.resetPlays();
                    final plays = await GameStorage.playsLeft();
                    if (!mounted) return;
                    setState(() => _playsLeft = plays);
                    _toast('Đã nạp lại $plays lượt (chế độ demo)');
                  }
                : null,
            child: _Pill(label: 'Lượt $_playsLeft/${GameStorage.maxPlays}'),
          ),
          const SizedBox(width: 6),
          ValueListenableBuilder<int>(
            valueListenable: GameStorage.bagCount,
            builder: (context, n, _) => _Pill(
              label: '$n',
              icon: Icons.card_giftcard_rounded,
              onTap: () => showPrizeBag(context),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Lật hộp, tìm lại nửa còn lại của mỗi đôi giày. Thắng để nhận lượt quay quà.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < gameLevels.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _LevelChip(
                    level: gameLevels[i],
                    selected: i == _levelIndex,
                    onTap: () => _pickLevel(i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          DefaultTextStyle(
            style: textTheme.bodySmall!.copyWith(
              color: AppColors.muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            child: Row(
              children: [
                const Text('Đôi '),
                Text('$_done/${level.pairs}', style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                const Text('Lật sai '),
                Text('$_misses', style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text('${_timeLeft.ceil()}s', style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  '★★★ ≤ ${level.threeStarMistakes} lần sai',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: level.seconds == 0 ? 0 : _timeLeft / level.seconds,
              backgroundColor: AppColors.line,
              color: _timeLeft <= 10 ? AppColors.warning : AppColors.rose,
            ),
          ),
          const SizedBox(height: 12),
          // Bàn chơi lấp hết phần màn hình còn lại, thẻ tự to nhỏ theo số thẻ.
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.rose))
                : LayoutBuilder(
                    builder: (context, c) {
                      final g = _boardLayout(_deck.length, c.maxWidth, c.maxHeight);
                      return Stack(
                        children: [
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: _gap,
                              runSpacing: _gap,
                              children: [
                                for (var i = 0; i < _deck.length; i++)
                                  SizedBox(
                                    width: g.width,
                                    height: g.height,
                                    child: MatchCardView(
                                      card: _deck[i],
                                      onTap: () => _tap(i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_joining != null)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: _JoinOverlay(pair: _joining!, animation: _join),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            _started
                ? 'Ghép đúng màu nhé, chấm nhỏ ở góc là màu của đôi giày.'
                : _playsLeft > 0
                ? 'Đồng hồ chạy khi bạn lật hộp đầu tiên.'
                : 'Hôm nay đã hết lượt nhận quà, bạn vẫn chơi được nhé.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
        ),
      ),
    );
  }
}

const _gap = 8.0;

/// Ảnh hẹp hơn tỉ lệ này (rộng/cao) thì không dùng trong game.
const _minAspect = 0.9;

/// Chọn số cột (2–4) cho thẻ to nhất mà vẫn vừa khung.
/// Thẻ giữ dáng đứng: rộng/cao trong khoảng 0.62 – 0.8.
/// Chỉ chọn bố cục đủ hàng cho cân xứng; dư chỗ thì bàn chơi nằm giữa.
Size _boardLayout(int n, double maxW, double maxH) {
  var best = const Size(60, 80);
  var bestScore = -1.0;
  for (final cols in [2, 3, 4]) {
    final rows = (n / cols).ceil();
    var w = (maxW - _gap * (cols - 1)) / cols;
    var h = (maxH - _gap * (rows - 1)) / rows;
    if (w <= 0 || h <= 0) continue;
    if (w / h > .8) w = h * .8; // bè quá → bóp ngang
    if (w / h < .62) h = w / .62; // cao quá → hạ chiều cao
    // Chỉ nhận bố cục đủ hàng (không có hàng lẻ) cho cân xứng.
    if (rows * cols != n) continue;
    final score = w * h;
    if (score > bestScore) {
      bestScore = score;
      best = Size(w, h);
    }
  }
  return Size(best.width.floorToDouble(), best.height.floorToDouble());
}

/// 2 nửa ảnh trượt vào nhau thành đôi giày hoàn chỉnh.
class _JoinOverlay extends StatelessWidget {
  const _JoinOverlay({required this.pair, required this.animation});

  final PairKey pair;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Khung theo đúng tỉ lệ ảnh gốc → 2 nửa ghép lại vừa khít.
        final aspect = pair.aspect <= 0 ? 1.0 : pair.aspect;
        var w = min(c.maxWidth * .82, 320.0);
        var h = w / aspect;
        if (h > c.maxHeight * .7) {
          h = c.maxHeight * .7;
          w = h * aspect;
        }
        final half = w / 2;
        return Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = animation.value;
              final slide = Curves.easeOutCubic.transform((t / .55).clamp(0.0, 1.0));
              final opacity = t < .2 ? t / .2 : (t > .8 ? (1 - t) / .2 : 1.0);
              final scale = t < .2 ? .9 + .1 * (t / .2) : (t > .8 ? 1 + .04 * ((t - .8) / .2) : 1.0);
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x2E000000), blurRadius: 30, offset: Offset(0, 12)),
                        BoxShadow(color: AppColors.rose, spreadRadius: 3),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: Offset(-half * .45 * (1 - slide), 0),
                          child: SizedBox(
                            width: half,
                            height: h,
                            child: HalfShoeImage(pair: pair, left: true),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(half * .45 * (1 - slide), 0),
                          child: SizedBox(
                            width: half,
                            height: h,
                            child: HalfShoeImage(pair: pair, left: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.selected, required this.onTap});

  final GameLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: selected ? AppColors.rose : AppColors.card,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.rose : AppColors.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            children: [
              Text(level.label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
              Text(
                '${level.pairs} đôi · ${level.seconds}s',
                style: TextStyle(color: fg.withValues(alpha: .8), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
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
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.roseDark),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}