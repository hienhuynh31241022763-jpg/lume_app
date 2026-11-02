import 'api_client.dart';

class SupportApi {
  static final _questionsEndpoint = Uri.parse(
    'https://6ae830af1a7b15aaa50eb4b5.mockapi.io/questions',
  );
  static final _exchangeRequestsEndpoint = Uri.parse(
    'https://6ae830af1a7b15aaa50eb4b5.mockapi.io/exchange_requests',
  );

  Future<String> submitQuestion({
    required String name,
    required String email,
    required String topic,
    required String question,
  }) async {
    final response = await ApiClient.postTo(_questionsEndpoint, {
      'name': name,
      'email': email,
      'topic': topic,
      'question': question,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
    return _readId(response, 'câu hỏi');
  }

  Future<String> submitExchangeRequest({
    required String orderCode,
    required String phone,
    required String reason,
  }) async {
    final response = await ApiClient.postTo(_exchangeRequestsEndpoint, {
      'orderCode': orderCode,
      'phone': phone,
      'reason': reason,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
    return _readId(response, 'yêu cầu đổi trả');
  }

  String _readId(dynamic response, String recordName) {
    if (response is Map && response['id'] != null) {
      return response['id'].toString();
    }
    throw ApiException('Máy chủ chưa trả mã cho $recordName');
  }
}
