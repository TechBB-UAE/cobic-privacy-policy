import 'package:dio/dio.dart';
import 'package:cobic/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TaskService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>> fetchTasks({String type = 'all'}) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập!');
      }
      final response = await ApiService.client.get(
        '/tasks',
        queryParameters: {'type': type},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      if (response.statusCode == 200 && response.data is List) {
        final tasks = List<Map<String, dynamic>>.from(response.data);
        
        // Lấy thông tin submission cho mỗi task
        for (var task in tasks) {
          try {
            final submission = await getTaskSubmission(task['id'].toString());
            if (submission != null) {
              task['submission'] = submission;
            }
          } catch (e) {
            // Ignore error if no submission exists
          }
        }
        
        return tasks;
      } else {
        throw Exception('Lỗi lấy danh sách nhiệm vụ');
      }
    } catch (e) {
      throw Exception('Lỗi lấy danh sách nhiệm vụ: $e');
    }
  }

  static Future<void> submitTask({required String taskId, required String proofImage}) async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập!');
    }
    final response = await ApiService.client.post(
      '/tasks/$taskId/submit',
      data: {
        'proofImage': proofImage,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi gửi nhiệm vụ: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>?> getTaskSubmission(String taskId) async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập!');
    }
    final response = await ApiService.client.get(
      '/user/tasks/submissions',
      queryParameters: {'taskId': taskId},
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> submissions = response.data;
      // Tìm submission của task hiện tại
      for (var submission in submissions) {
        if (submission['taskId'].toString() == taskId) {
          return submission;
        }
      }
    }
    return null;
  }
} 