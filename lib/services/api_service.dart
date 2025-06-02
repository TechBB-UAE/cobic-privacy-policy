import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://app.cobic.io/api';
  static const String apiKey = '3cc1e10f892dad8eb2c612abf6262c09'; // Thay bằng API KEY thực tế

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'x-api-key': apiKey,
      },
    ),
  );

  static Dio get client => _dio;

  static void init() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // Lấy trạng thái mining
  static Future<Response> getMiningStatus(String token) async {
    return await _dio.get(
      '/mining/status',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // Daily check-in (mining)
  static Future<Response> dailyCheckIn(String token) async {
    return await _dio.post(
      '/mining/daily-check-in',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // Chuyển Cobic (theo API thực tế)
  static Future<Response> transferCobic(String token, String recipientUsername, double amount) async {
    return await _dio.post(
      '/transactions/send',
      data: {
        'recipient': recipientUsername,
        'amount': amount.toString(),
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // Lấy lịch sử giao dịch
  static Future<Response> fetchTransactions(String token, {int limit = 20, int offset = 0, String type = 'all'}) async {
    return await _dio.get(
      '/transactions',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'type': type,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
} 