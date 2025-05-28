import 'package:dio/dio.dart';
import 'package:cobic/services/api_service.dart';
import 'package:cobic/models/referral_stats.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReferralService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Future<ReferralStats> getReferralStats() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }

      final response = await ApiService.client.get(
        '/user/referral-stats',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return ReferralStats.fromJson(response.data);
      } else {
        throw Exception('Lỗi lấy thông tin giới thiệu');
      }
    } catch (e) {
      throw Exception('Lỗi lấy thông tin giới thiệu: $e');
    }
  }

  static Future<Map<String, dynamic>> submitReferralCode(String code) async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) throw Exception('Không tìm thấy token đăng nhập!');
    final response = await ApiService.client.post(
      '/referral',
      data: {'referralCode': code},
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Lỗi nhập mã giới thiệu');
    }
  }
} 