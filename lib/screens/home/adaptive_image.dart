import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Ảnh sản phẩm có khung TỰ ĐỔI MÀU theo nền của ảnh.
///
/// Ảnh giày chụp trên nền xám / trắng / kem khác nhau, nếu khung một màu cố
/// định thì lộ viền chênh màu. Widget này đọc màu ở 4 cạnh của ảnh (lấy trung
/// bình), rồi tô khung đúng màu đó → ảnh hiện trọn (BoxFit.contain, không
/// phóng to, không cắt) mà nhìn liền khung.
///
/// - Dùng chung ảnh đã tải (cùng ImageProvider) nên không tải ảnh 2 lần.
/// - Màu đọc được lưu lại theo link ảnh, lần sau hiện ngay.
/// - Ảnh PNG nền trong suốt → giữ màu khung mặc định.
class AdaptiveImage extends StatefulWidget {
  const AdaptiveImage({
    super.key,
    required this.url,
    required this.placeholder,
    this.cacheWidth,
    this.fallbackColor = const Color(0xFFF1EFF1),
    this.onColor,
    this.padding = EdgeInsets.zero,
    this.fit = BoxFit.contain,
    this.debugLabel,
  });

  final String url;

  /// Hiện khi chưa có link hoặc tải lỗi.
  final Widget placeholder;

  /// Giải mã ảnh nhỏ lại cho nhẹ (thẻ sản phẩm). Null = kích thước gốc.
  final int? cacheWidth;

  /// Màu khung khi chưa đọc được màu ảnh.
  final Color fallbackColor;

  /// Báo màu nền đọc được ra ngoài (VD: để tô cả khung ảnh ở Chi tiết).
  final ValueChanged<Color>? onColor;

  /// Khoảng chừa quanh ảnh. Phần chừa vẫn được tô màu nền ảnh, nên ảnh
  /// tránh được các nút đè lên mà khung vẫn liền màu.
  final EdgeInsets padding;

  /// contain = hiện trọn ảnh (thẻ sản phẩm); cover = phủ kín khung (Chi tiết).
  final BoxFit fit;

  /// Tên hiện trong Debug Console khi ảnh bắt đầu tải (để thấy lazy load).
  final String? debugLabel;

  @override
  State<AdaptiveImage> createState() => _AdaptiveImageState();
}

final Map<String, Color> _edgeColorCache = {};

/// Màu nền đã đọc của 1 ảnh (null nếu chưa đọc).
Color? cachedEdgeColor(String url) => _edgeColorCache[url];

class _AdaptiveImageState extends State<AdaptiveImage> {
  ImageProvider? _provider;
  Color? _bg;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant AdaptiveImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url || old.cacheWidth != widget.cacheWidth) {
      _setup();
    }
  }

  void _setup() {
    if (widget.url.isNotEmpty &&
        widget.debugLabel != null &&
        !_edgeColorCache.containsKey(widget.url)) {
      // Lazy load: dòng này chỉ hiện khi thẻ vừa được cuộn tới (được dựng),
      // thẻ chưa cuộn tới thì chưa tải ảnh → chưa có dòng.
      debugPrint('🖼 [Lazy load] Thẻ hiện ra → bắt đầu tải ảnh: '
          '${widget.debugLabel}');
    }
    if (widget.url.isEmpty) {
      _provider = null;
      _bg = null;
      return;
    }
    _provider = ResizeImage.resizeIfNeeded(
      widget.cacheWidth,
      null,
      NetworkImage(widget.url),
    );
    _bg = _edgeColorCache[widget.url];
    if (_bg != null) {
      widget.onColor?.call(_bg!);
      return;
    }
    final url = widget.url;
    _readEdgeColor(_provider!).then((color) {
      if (color == null) return;
      _edgeColorCache[url] = color;
      if (!mounted || widget.url != url) return;
      setState(() => _bg = color);
      widget.onColor?.call(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) return widget.placeholder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: _bg ?? widget.fallbackColor,
      padding: widget.padding,
      child: Image(
        image: provider,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => widget.placeholder,
        // Lúc đang tải: khung nhấp nháy nhẹ. Tải xong: ảnh hiện mờ dần lên.
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync) return child;
          final loaded = frame != null;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (!loaded) const _LoadingPulse(),
              AnimatedOpacity(
                opacity: loaded ? 1 : 0,
                duration: const Duration(milliseconds: 350),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Khung sáng / tối nhấp nháy nhẹ trong lúc ảnh đang tải.
class _LoadingPulse extends StatefulWidget {
  const _LoadingPulse();

  @override
  State<_LoadingPulse> createState() => _LoadingPulseState();
}

class _LoadingPulseState extends State<_LoadingPulse>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.15, end: 0.6).animate(_anim),
      child: const ColoredBox(color: Colors.white),
    );
  }
}

/// Đọc màu trung bình dọc 4 cạnh ảnh. Bỏ qua điểm trong suốt.
Future<Color?> _readEdgeColor(ImageProvider provider) async {
  final completer = Completer<ui.Image?>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      if (!completer.isCompleted) completer.complete(info.image.clone());
      stream.removeListener(listener);
    },
    onError: (_, _) {
      if (!completer.isCompleted) completer.complete(null);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);

  final image = await completer.future;
  if (image == null) return null;
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;
    final w = image.width, h = image.height;
    var r = 0, g = 0, b = 0, n = 0;

    void sample(int x, int y) {
      final i = (y * w + x) * 4;
      final a = data.getUint8(i + 3);
      if (a < 200) return; // điểm trong suốt
      r += data.getUint8(i);
      g += data.getUint8(i + 1);
      b += data.getUint8(i + 2);
      n++;
    }

    // Lấy điểm cách mép 2px (tránh viền mờ / viền nén), khoảng 40 điểm mỗi cạnh.
    final stepX = (w / 40).ceil().clamp(1, w);
    final stepY = (h / 40).ceil().clamp(1, h);
    final x0 = 2.clamp(0, w - 1), x1 = (w - 3).clamp(0, w - 1);
    final y0 = 2.clamp(0, h - 1), y1 = (h - 3).clamp(0, h - 1);
    for (var x = 0; x < w; x += stepX) {
      sample(x, y0);
      sample(x, y1);
    }
    for (var y = 0; y < h; y += stepY) {
      sample(x0, y);
      sample(x1, y);
    }
    if (n == 0) return null;
    return Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
  } catch (_) {
    return null;
  } finally {
    image.dispose();
  }
}