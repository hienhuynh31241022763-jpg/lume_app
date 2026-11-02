class FaqItem {
  const FaqItem({
    required this.id,
    required this.topic,
    required this.question,
    required this.answer,
  });

  final String id;
  final String topic;
  final String question;
  final String answer;
}

const faqItems = [
  FaqItem(
    id: '1',
    topic: 'Size và sản phẩm',
    question: 'Làm thế nào để tôi chọn được size giày vừa vặn nhất tại LUMÉ?',
    answer: 'LUMÉ áp dụng bảng size chuẩn quốc tế từ 35 đến 40. Bạn có thể sử dụng trực tiếp tính năng "Tìm size chuẩn" ngay trong ứng dụng bằng cách nhập chiều dài bàn chân (cm) để được hệ thống đề xuất size chính xác nhất.',
  ),
  FaqItem(
    id: '2',
    topic: 'Đổi trả',
    question: 'Tôi có được đổi size hoặc đổi mẫu nếu mang không vừa không?',
    answer: 'LUMÉ hỗ trợ đổi size hoặc đổi mẫu miễn phí trong vòng 7 ngày kể từ ngày nhận hàng. Sản phẩm đổi phải còn nguyên tem mác, hộp đựng và chưa qua sử dụng ngoài trời.',
  ),
  FaqItem(
    id: '3',
    topic: 'Giao hàng',
    question: 'Thời gian giao hàng mất bao lâu và phí vận chuyển tính thế nào?',
    answer: 'Đơn hàng nội thành TP.HCM sẽ được giao trong 1-2 ngày, các tỉnh thành khác từ 2-4 ngày làm việc. LUMÉ miễn phí vận chuyển toàn quốc cho mọi đơn hàng có giá trị từ 1.000.000đ trở lên.',
  ),
  FaqItem(
    id: '4',
    topic: 'Đổi trả',
    question: 'Sản phẩm của LUMÉ có được bảo hành không?',
    answer: 'Tất cả giày LUMÉ đều được bảo hành kỹ thuật 6 tháng miễn phí đối với lỗi bung keo, đứt chỉ hoặc gãy đế. Sau thời gian bảo hành, LUMÉ vẫn hỗ trợ bảo dưỡng và sửa chữa trọn đời với chi phí ưu đãi.',
  ),
  FaqItem(
    id: '5',
    topic: 'Thanh toán',
    question: 'Ứng dụng LUMÉ hỗ trợ các phương thức thanh toán nào?',
    answer: 'Bạn có thể thanh toán trực tiếp khi nhận hàng (COD), thanh toán qua thẻ tín dụng/ghi nợ quốc tế (Visa/Mastercard), chuyển khoản quét mã QR tự động hoặc qua các ví điện tử liên kết.',
  ),
  FaqItem(
    id: '6',
    topic: 'Size và sản phẩm',
    question: 'Cách bảo quản giày da thật và chất liệu nhung như thế nào?',
    answer: 'Bạn nên tránh để giày tiếp xúc trực tiếp với nước mưa hoặc nhiệt độ cao. Đối với chất liệu nhung nên dùng bàn chải mềm vệ sinh nhẹ nhàng, còn giày da nên định kỳ lau sạch bụi bằng khăn ẩm và dưỡng kem/xi không màu.',
  ),
  FaqItem(
    id: '7',
    topic: 'Giao hàng',
    question: 'Tôi có được kiểm tra và thử giày trước khi nhận không?',
    answer: 'Khách hàng hoàn toàn được phép đồng kiểm ngoại quan sản phẩm trước khi thanh toán cho shipper. Để đảm bảo quyền lợi đổi trả, bạn vui lòng chỉ thử giày trên bề mặt sạch trong nhà.',
  ),
  FaqItem(
    id: '8',
    topic: 'Đặt hàng',
    question: 'Làm sao để áp dụng mã giảm giá khi đặt hàng?',
    answer: 'Tại màn hình Giỏ hàng hoặc Thanh toán, bạn chỉ cần nhập mã khuyến mãi vào ô "Mã giảm giá" hoặc bấm chọn trực tiếp voucher có sẵn trong ví ưu đãi rồi nhấn Áp dụng.',
  ),
  FaqItem(
    id: '9',
    topic: 'Giao hàng',
    question: 'Làm thế nào để tôi theo dõi tình trạng vận chuyển đơn hàng?',
    answer: 'Bạn vào mục "Tài khoản" -> chọn "Đơn hàng của tôi". Tại đây hệ thống sẽ hiển thị chi tiết tiến trình vận chuyển theo thời gian thực từ lúc xác nhận, đóng gói đến khi giao hàng thành công.',
  ),
  FaqItem(
    id: '10',
    topic: 'Đổi trả',
    question: 'Tôi có thể hủy đơn hàng sau khi đã đặt thành công không?',
    answer: 'Bạn có thể hủy đơn hàng trực tiếp trên ứng dụng khi đơn còn ở trạng thái "Chờ xác nhận" hoặc "Đang xử lý". Nếu đơn đã bàn giao cho bên vận chuyển, bạn vui lòng liên hệ hotline hỗ trợ để được xử lý nhanh nhất.',
  ),
];

List<String> get faqTopics => [
  'Tất cả',
  ...faqItems.map((item) => item.topic).toSet(),
];
