class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.time,
  });

  final String id;
  final String type;
  final String title;
  final String content;
  final String time;
}

const appNotifications = [
  AppNotification(
    id: '1',
    type: 'Đơn hàng',
    title: 'Đơn hàng đã được xác nhận',
    content: 'Đơn hàng #LM1024 của bạn đã được xác nhận và đang được chuẩn bị.',
    time: '5 phút trước',
  ),
  AppNotification(
    id: '2',
    type: 'Đơn hàng',
    title: 'Đơn hàng đang được giao',
    content:
        'Đơn hàng #LM1024 đang trên đường giao đến bạn, dự kiến nhận trong hôm nay.',
    time: '2 giờ trước',
  ),
  AppNotification(
    id: '3',
    type: 'Đơn hàng',
    title: 'Giao hàng thành công',
    content:
        'Đơn hàng #LM1019 đã được giao thành công. Cảm ơn bạn đã mua sắm cùng Lumé!',
    time: '1 ngày trước',
  ),
  AppNotification(
    id: '4',
    type: 'Khuyến mãi',
    title: 'Giảm 20% toàn bộ sandal',
    content:
        'Săn ngay sandal mùa hè với ưu đãi giảm 20%, áp dụng đến hết tuần này.',
    time: '3 giờ trước',
  ),
  AppNotification(
    id: '5',
    type: 'Khuyến mãi',
    title: 'Flash sale giữa tháng',
    content:
        'Flash sale 12 giờ duy nhất: đồng giá sốc cho 50 mẫu giày hot nhất.',
    time: '6 giờ trước',
  ),
  AppNotification(
    id: '6',
    type: 'Đơn hàng',
    title: 'Đơn hàng bị hủy',
    content:
        'Đơn hàng #LM0987 đã được hủy theo yêu cầu của bạn. Hoàn tiền trong 3-5 ngày làm việc.',
    time: '2 ngày trước',
  ),
  AppNotification(
    id: '7',
    type: 'Khuyến mãi',
    title: 'Ưu đãi sinh nhật Lumé',
    content:
        'Chúc mừng sinh nhật Lumé 3 tuổi! Nhận ngay voucher 100k cho đơn từ 500k.',
    time: '1 ngày trước',
  ),
  AppNotification(
    id: '8',
    type: 'Đơn hàng',
    title: 'Đơn hàng đang xử lý',
    content:
        'Đơn hàng #LM1031 đang được đóng gói, sẽ bàn giao cho đơn vị vận chuyển sớm.',
    time: '30 phút trước',
  ),
  AppNotification(
    id: '9',
    type: 'Khuyến mãi',
    title: 'Miễn phí vận chuyển',
    content:
        'Áp dụng miễn phí vận chuyển cho mọi đơn hàng từ 300k trong tuần này.',
    time: '4 giờ trước',
  ),
  AppNotification(
    id: '10',
    type: 'Đơn hàng',
    title: 'Đổi trả thành công',
    content:
        'Yêu cầu đổi size đơn hàng #LM0954 đã được xử lý, sản phẩm mới đang được gửi đến bạn.',
    time: '3 ngày trước',
  ),
];
