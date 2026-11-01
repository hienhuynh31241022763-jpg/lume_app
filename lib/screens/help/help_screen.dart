import 'package:flutter/material.dart';

import '../../data/faq_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

final _helpTopics = faqTopics;
const _questions = faqItems;

const _terms = [
  (
    '1. Phạm vi áp dụng',
    'Các điều khoản này áp dụng khi bạn truy cập và sử dụng các tính năng mua sắm, tài khoản và nội dung của LUMÉ.',
  ),
  (
    '2. Tài khoản và thông tin',
    'Bạn chịu trách nhiệm cung cấp thông tin chính xác khi tạo đơn hàng và giữ an toàn cho thông tin đăng nhập của mình.',
  ),
  (
    '3. Đơn hàng và thanh toán',
    'Giá, phí giao hàng và phương thức thanh toán được hiển thị tại bước xác nhận đơn. Đơn hàng chỉ được ghi nhận sau khi hệ thống thông báo thành công.',
  ),
  (
    '4. Đổi trả và hỗ trợ',
    'Yêu cầu đổi trả được xem xét theo chính sách đổi trả đang áp dụng. Nếu cần giải đáp, vui lòng gửi câu hỏi qua Trung tâm hỗ trợ.',
  ),
  (
    '5. Quyền sở hữu nội dung',
    'Nội dung, hình ảnh và dấu hiệu thương hiệu trên ứng dụng thuộc LUMÉ hoặc bên cấp phép tương ứng; vui lòng không sử dụng khi chưa được cho phép.',
  ),
];

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  final _searchController = TextEditingController();
  String _query = '';
  String _topic = _helpTopics.first;
  bool _agreed = false;
  String? _lastExchangeRequest;

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _contactSupport() {
    Navigator.pushNamed(context, AppRoutes.about, arguments: 1);
  }

  Future<void> _createExchangeRequest() async {
    final request = await showModalBottomSheet<_ExchangeRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => const _ExchangeRequestSheet(),
    );
    if (!mounted || request == null) return;
    setState(() => _lastExchangeRequest = request.reference);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã ghi nhận yêu cầu ${request.reference} (mô phỏng).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final questions = _questions.where((question) {
      final matchesTopic = _topic == 'Tất cả' || question.topic == _topic;
      final haystack =
          '${question.topic} ${question.question} ${question.answer}'
              .toLowerCase();
      return matchesTopic && haystack.contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung tâm hỗ trợ'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.roseDark,
          indicatorColor: AppColors.rose,
          tabs: const [
            Tab(text: 'Câu hỏi thường gặp'),
            Tab(text: 'Đổi trả'),
            Tab(text: 'Điều khoản'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildFaqTab(questions),
          _buildReturnsTab(),
          _buildTermsTab(),
        ],
      ),
    );
  }

  Widget _buildFaqTab(List<FaqItem> questions) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Tìm câu hỏi...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: AppColors.card,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _helpTopics.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final topic = _helpTopics[index];
              return ChoiceChip(
                label: Text(topic),
                selected: topic == _topic,
                selectedColor: AppColors.blush,
                side: BorderSide(
                  color: topic == _topic ? AppColors.rose : AppColors.line,
                ),
                onSelected: (_) => setState(() => _topic = topic),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (questions.isEmpty)
          _NoAnswerCard(onContact: _contactSupport)
        else
          for (final question in questions)
            Card(
              color: AppColors.card,
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  question.question,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  question.topic,
                  style: const TextStyle(color: AppColors.roseDark),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      question.answer,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildReturnsTab() {
    const steps = [
      ('01', 'Tạo yêu cầu', 'Gửi mã đơn và lý do đổi size.'),
      ('02', 'Chờ xác nhận', 'Nhân viên liên hệ xác nhận thông tin.'),
      ('03', 'Gửi sản phẩm', 'Đóng gói giày cùng phụ kiện và gửi theo hướng dẫn.'),
      ('04', 'Nhận size mới', 'LUMÉ kiểm tra sản phẩm và gửi size bạn chọn.'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.blush,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.swap_horiz_rounded, color: AppColors.roseDark, size: 30),
              SizedBox(height: 10),
              Text(
                'Đổi size miễn phí trong 7 ngày',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Áp dụng từ ngày nhận hàng. Sản phẩm cần chưa qua sử dụng, còn nguyên vẹn và đầy đủ phụ kiện.',
                style: TextStyle(color: AppColors.ink, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Quy trình 4 bước',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < steps.length; index++)
          _ProcessStep(
            number: steps[index].$1,
            title: steps[index].$2,
            description: steps[index].$3,
            isLast: index == steps.length - 1,
          ),
        if (_lastExchangeRequest != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              'Yêu cầu gần nhất: $_lastExchangeRequest',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _createExchangeRequest,
            icon: const Icon(Icons.assignment_add),
            label: const Text('Tạo yêu cầu đổi size'),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _contactSupport,
          child: const Text('Cần hỗ trợ thêm? Liên hệ LUMÉ'),
        ),
      ],
    );
  }

  Widget _buildTermsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Vui lòng đọc các mục dưới đây trước khi tiếp tục sử dụng dịch vụ.',
          style: TextStyle(color: AppColors.muted, height: 1.45),
        ),
        const SizedBox(height: 12),
        for (final (title, body) in _terms)
          Card(
            color: AppColors.card,
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    body,
                    style: const TextStyle(
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        CheckboxListTile(
          value: _agreed,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.rose,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Tôi đã đọc và đồng ý với các điều khoản trên.',
            style: TextStyle(fontSize: 14),
          ),
          onChanged: (value) => setState(() => _agreed = value ?? false),
        ),
        if (_agreed)
          const Text(
            'Cảm ơn bạn đã xác nhận.',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _NoAnswerCard extends StatelessWidget {
  const _NoAnswerCard({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.question_answer_outlined,
            color: AppColors.rose,
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text(
            'Chưa tìm thấy câu trả lời phù hợp?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gửi câu hỏi cho LUMÉ, chúng mình sẽ hỗ trợ bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.support_agent),
            label: const Text('Chuyển đến tab Liên hệ'),
          ),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.number,
    required this.title,
    required this.description,
    required this.isLast,
  });

  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.blush,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.roseDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppColors.line,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExchangeRequest {
  const _ExchangeRequest(this.reference);

  final String reference;
}

class _ExchangeRequestSheet extends StatefulWidget {
  const _ExchangeRequestSheet();

  @override
  State<_ExchangeRequestSheet> createState() => _ExchangeRequestSheetState();
}

class _ExchangeRequestSheetState extends State<_ExchangeRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _orderController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _reason;

  @override
  void dispose() {
    _orderController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    Navigator.pop(context, _ExchangeRequest('EX-$suffix'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Tạo yêu cầu đổi size',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(labelText: 'Mã đơn hàng'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Vui lòng nhập mã đơn hàng'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Vui lòng nhập số điện thoại'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _reason,
                decoration: const InputDecoration(labelText: 'Lý do đổi'),
                items: const [
                  DropdownMenuItem(value: 'Đổi size', child: Text('Đổi size')),
                  DropdownMenuItem(
                    value: 'Sản phẩm lỗi',
                    child: Text('Sản phẩm lỗi'),
                  ),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (value) => setState(() => _reason = value),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn lý do đổi' : null,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Gửi yêu cầu'),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yêu cầu được mô phỏng trong phiên hiện tại, chưa gửi lên máy chủ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
