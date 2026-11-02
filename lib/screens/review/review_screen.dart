import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/review_provider.dart';
import '../../theme/app_colors.dart';

class ReviewRouteArgs {
  const ReviewRouteArgs({
    required this.orderId,
    required this.item,
    required this.customerName,
  });

  final String orderId;
  final OrderItem item;
  final String customerName;
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({required this.args, super.key});

  final ReviewRouteArgs args;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  String? _fit;
  int _mockImageCount = 0;
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleMockImage() {
    setState(() {
      _mockImageCount = _mockImageCount == 0 ? 1 : 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final fit = _fit;
    if (fit == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn chọn độ vừa chân nhé')));
      return;
    }

    setState(() => _sending = true);
    context.read<ReviewProvider>().submit(
      productId: widget.args.item.productId,
      author: widget.args.customerName,
      rating: _rating,
      fit: fit,
      comment: _commentController.text,
      imageCount: _mockImageCount,
      orderId: widget.args.orderId,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã gửi đánh giá sản phẩm')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.args.item;
    return Scaffold(
      appBar: AppBar(title: const Text('Viết đánh giá')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Bạn cảm thấy sản phẩm thế nào?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    tooltip: '$star sao',
                    onPressed: () => setState(() => _rating = star),
                    icon: Icon(
                      star <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.gold,
                      size: 36,
                    ),
                  ),
              ],
            ),
            Center(
              child: Text(
                '$_rating/5 sao',
                style: const TextStyle(
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Độ vừa chân',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final fit in const ['Vừa chân', 'Hơi chật', 'Hơi rộng'])
                  ChoiceChip(
                    label: Text(fit),
                    selected: _fit == fit,
                    onSelected: (_) => setState(() => _fit = fit),
                    selectedColor: AppColors.blush,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _commentController,
              minLines: 4,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Nhận xét của bạn',
                hintText: 'Chia sẻ cảm nhận về sản phẩm...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bạn viết nhận xét trước khi gửi nhé';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Hình ảnh (mô phỏng)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                if (_mockImageCount > 0)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.rose),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: AppColors.roseDark),
                        SizedBox(height: 3),
                        Text('Ảnh mẫu', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                if (_mockImageCount == 0)
                  OutlinedButton.icon(
                    onPressed: _toggleMockImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Thêm ảnh'),
                  )
                else
                  TextButton.icon(
                    onPressed: _toggleMockImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xóa ảnh'),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Gửi đánh giá'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau'),
            ),
          ],
        ),
      ),
    );
  }
}
