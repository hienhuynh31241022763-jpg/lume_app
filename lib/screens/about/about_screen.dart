import 'package:flutter/material.dart';

import '../../data/support_api.dart';
import '../../theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, this.initialTab = 0, this.supportApi});

  final int initialTab;
  final SupportApi? supportApi;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab.clamp(0, 1).toInt(),
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về LUMÉ'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.roseDark,
          indicatorColor: AppColors.rose,
          tabs: const [
            Tab(text: 'Câu chuyện'),
            Tab(text: 'Liên hệ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _StoryTab(onContact: () => _tabs.animateTo(1)),
          _ContactTab(supportApi: widget.supportApi),
        ],
      ),
    );
  }
}

class _StoryTab extends StatelessWidget {
  const _StoryTab({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blush, AppColors.background],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LUMÉ',
                      style: TextStyle(
                        color: AppColors.rose,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bước chân tự tin\nmỗi ngày',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/images/giay_nen.png',
                  height: 92,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'LUMÉ ra đời từ một điều đơn giản: mua giày online mà không lo sai size. Mỗi đôi giày đều có bảng size chi tiết, ảnh thật và mô hình 3D để bạn xem kỹ trước khi mua.',
          style: TextStyle(color: AppColors.ink, height: 1.45, fontSize: 12),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _StoryPromise(
                icon: Icons.straighten,
                title: 'Chuẩn size',
                subtitle: 'Đo size theo\nchiều dài chân',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StoryPromise(
                icon: Icons.swap_horiz,
                title: 'Đổi trả 7 ngày',
                subtitle: 'Đổi size\nmiễn phí',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StoryPromise(
                icon: Icons.remove_red_eye_outlined,
                title: 'Chân thật',
                subtitle: 'Kiểm tra trước\nkhi giao',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Expanded(
                child: _StoryMetric(value: '120+', label: 'mẫu giày'),
              ),
              Expanded(
                child: _StoryMetric(value: '35–40', label: 'đủ size'),
              ),
              Expanded(
                child: _StoryMetric(value: '4.8★', label: 'đánh giá'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('Liên hệ với LUMÉ'),
          ),
        ),
      ],
    );
  }
}

class _StoryPromise extends StatelessWidget {
  const _StoryPromise({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.rose, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.15,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryMetric extends StatelessWidget {
  const _StoryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8)),
      ],
    );
  }
}

class _ContactTab extends StatefulWidget {
  const _ContactTab({this.supportApi});

  final SupportApi? supportApi;

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  static const _topics = ['Đơn hàng', 'Đổi trả', 'Góp ý', 'Khác'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _questionController = TextEditingController();
  String _topic = _topics.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final id = await (widget.supportApi ?? SupportApi()).submitQuestion(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        topic: _topic,
        question: _questionController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Đã gửi câu hỏi thành công. Mã: $id')),
        );
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _questionController.clear();
      setState(() => _topic = _topics.first);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Gửi câu hỏi thất bại: $error')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'LUMÉ luôn sẵn sàng hỗ trợ bạn',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Chăm sóc khách hàng: 8:00–21:00, tất cả các ngày',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _ContactInfoCard(
                icon: Icons.phone_outlined,
                title: 'Hotline hỗ trợ',
                detail: '1900 1234',
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _ContactInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                detail: 'cskh@lume.vn',
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        const Row(
          children: [
            Expanded(
              child: _ContactInfoCard(
                icon: Icons.chat_bubble_outline,
                title: 'Zalo',
                detail: 'LUMÉ Official',
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _ContactInfoCard(
                icon: Icons.location_on_outlined,
                title: 'Cửa hàng',
                detail: '12 Đường số 5, Q.1',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Gửi câu hỏi cho LUMÉ',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Để lại thông tin, LUMÉ sẽ liên hệ hỗ trợ bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.4, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Vui lòng nhập họ và tên'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email liên hệ'),
                validator: (value) {
                  final email = (value ?? '').trim();
                  if (email.isEmpty) return 'Vui lòng nhập email';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Email chưa đúng định dạng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Chủ đề',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final topic in _topics)
                    ChoiceChip(
                      label: Text(topic),
                      selected: _topic == topic,
                      onSelected: (_) => setState(() => _topic = topic),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _questionController,
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'Nhập câu hỏi của bạn...',
                  alignLabelWithHint: true,
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Vui lòng nhập nội dung câu hỏi'
                    : null,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi câu hỏi'),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Câu hỏi sẽ được gửi đến bộ phận hỗ trợ LUMÉ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.roseDark, size: 19),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.3,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
