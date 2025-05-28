import 'package:dio/dio.dart';
import 'package:cobic/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PointService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Future<Map<String, dynamic>> scanQrAndCollectPoint(String qrContent) async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) throw Exception('Không tìm thấy token đăng nhập!');
    final response = await ApiService.client.post(
      '/qr/scan',
      data: {'qrContent': qrContent},
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.data['error'] ?? response.data['message'] ?? 'Lỗi tích điểm bằng QR');
    }
  }
} 