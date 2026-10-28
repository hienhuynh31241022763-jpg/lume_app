import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Future<dynamic> get(String path) {
    return _send(() => http.get(_uri(path)));
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _send(
      () =>
          http.post(_uri(path), headers: _jsonHeaders, body: jsonEncode(body)),
    );
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) {
    return _send(
      () => http.put(_uri(path), headers: _jsonHeaders, body: jsonEncode(body)),
    );
  }

  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request().timeout(ApiConfig.timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException('Máy chủ trả về lỗi ${res.statusCode}');
      }
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on TimeoutException {
      throw ApiException('Kết nối quá lâu, vui lòng thử lại');
    } on SocketException {
      throw ApiException('Không có kết nối mạng');
    } on http.ClientException {
      throw ApiException('Không có kết nối mạng');
    } on FormatException {
      throw ApiException('Dữ liệu từ máy chủ không hợp lệ');
    }
  }
}
