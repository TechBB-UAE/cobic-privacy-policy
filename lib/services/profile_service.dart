import 'package:dio/dio.dart';
import 'package:cobic/services/api_service.dart';
import 'package:cobic/services/api_endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class ProfileService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }

      developer.log('Token: $token', name: 'ProfileService');

      final response = await ApiService.client.get(
        ApiEndpoints.me,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      developer.log('Response status: ${response.statusCode}', name: 'ProfileService');
      developer.log('Response data: ${response.data}', name: 'ProfileService');

      if (response.statusCode == 200) {
        if (response.data is Map && (response.data['error'] != null || response.data['message'] != null)) {
          throw Exception(response.data['error'] ?? response.data['message']);
        }
        return response.data;
      } else {
        developer.log('API trả về status code lỗi: ${response.statusCode}', name: 'ProfileService');
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Lỗi khi gọi API: ${e.toString()}', name: 'ProfileService');
      throw Exception('Lỗi khi lấy thông tin tài khoản: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'username');
    await _secureStorage.delete(key: 'password');
    await _secureStorage.delete(key: 'isGuest');
  }

  static Future<Map<String, dynamic>> checkUsername(String username) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }

      final response = await ApiService.client.get(
        '/auth/check-username',
        queryParameters: {'username': username},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return response.data;
    } catch (e) {
      return {'exists': false};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }
      final body = {
        'fullName': data['fullName'],
        'dateOfBirth': data['dateOfBirth'],
        'country': data['country'],
        'address': data['address'],
        'bio': data['bio'],
        'phoneNumber': data['phone'],
      };
      final response = await ApiService.client.patch(
        '/user/profile',
        data: body,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String message;
        if (data is String) {
          message = data;
        } else if (data is Map) {
          if (data['error'] != null) {
            message = data['error'];
          } else if (data['message'] != null) {
            message = data['message'];
          } else {
            message = 'Có lỗi xảy ra';
          }
        } else {
          message = 'Có lỗi xảy ra';
        }
        return {
          'success': false,
          'message': message,
        };
      }
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateEmail(String email) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }
      final response = await ApiService.client.patch(
        '/user/email',
        data: {'email': email},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String message;
        if (data is String) {
          message = data;
        } else if (data is Map) {
          if (data['error'] != null) {
            message = data['error'];
          } else if (data['message'] != null) {
            message = data['message'];
          } else {
            message = 'Có lỗi xảy ra';
          }
        } else {
          message = 'Có lỗi xảy ra';
        }
        return {
          'success': false,
          'message': message,
        };
      }
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateUsername(String username) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }
      final response = await ApiService.client.patch(
        '/user/username',
        data: {'username': username},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String message;
        if (data is String) {
          message = data;
        } else if (data is Map) {
          if (data['error'] != null) {
            message = data['error'];
          } else if (data['message'] != null) {
            message = data['message'];
          } else {
            message = 'Có lỗi xảy ra';
          }
        } else {
          message = 'Có lỗi xảy ra';
        }
        return {
          'success': false,
          'message': message,
        };
      }
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e',
      };
    }
  }

  static Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.client.patch(
        '/user/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        if (response.data is Map && (response.data['error'] != null || response.data['message'] != null)) {
          throw Exception(response.data['error'] ?? response.data['message']);
        }
        return;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        var data = response.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        if (data is Map && (data['error'] != null || data['message'] != null)) {
          throw Exception(data['error'] ?? data['message']);
        }
        if (data is List) {
          final msg = data.map((e) => e['message'] ?? '').where((m) => m != null && m.toString().isNotEmpty).join('\n');
          if (msg.isNotEmpty) throw Exception(msg);
        }
        throw Exception('Có lỗi xảy ra, vui lòng thử lại!');
      } else {
        throw Exception('Đổi mật khẩu thất bại');
      }
    } catch (e) {
      if (e is DioException) {
        var data = e.response?.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        if (data is Map && (data['error'] != null || data['message'] != null)) {
          throw Exception(data['error'] ?? data['message']);
        }
        if (data is List) {
          final msg = data.map((e) => e['message'] ?? '').where((m) => m != null && m.toString().isNotEmpty).join('\n');
          if (msg.isNotEmpty) throw Exception(msg);
        }
        throw Exception('Có lỗi xảy ra, vui lòng thử lại!');
      }
      throw Exception('Đổi mật khẩu thất bại: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> submitKyc(FormData data) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }
      // Log chi tiết FormData
      for (var entry in data.fields) {
        print('[KYC] Field: ${entry.key} = ${entry.value}');
      }
      for (var file in data.files) {
        print('[KYC] File: ${file.key}');
        print('  filename: ${file.value.filename}');
        print('  contentType: ${file.value.contentType}');
        print('  length: ${file.value.length}');
      }
      final response = await ApiService.client.post(
        '/kyc/submit',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        var resData = response.data;
        if (resData is String) {
          try {
            resData = json.decode(resData);
          } catch (_) {}
        }
        if (resData is Map && (resData['error'] != null || resData['message'] != null)) {
          throw Exception(resData['error'] ?? resData['message']);
        }
        throw Exception('Dữ liệu không hợp lệ hoặc chưa xác thực');
      } else {
        throw Exception('Nộp KYC thất bại');
      }
    } catch (e) {
      if (e is DioException) {
        var data = e.response?.data;
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (_) {}
        }
        if (data is Map && (data['error'] != null || data['message'] != null)) {
          throw Exception(data['error'] ?? data['message']);
        }
        throw Exception('Có lỗi xảy ra, vui lòng thử lại!');
      }
      throw Exception('Nộp KYC thất bại: ${e.toString()}');
    }
  }
} 