import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:convert';

class ErrorUtils {
  static void showErrorToast(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      messageColor: Colors.white,
    ).show(context);
  }

  static void showSuccessToast(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      messageColor: Colors.white,
    ).show(context);
  }

  static void showWarningToast(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      messageColor: Colors.white,
    ).show(context);
  }

  static Future<void> showErrorDialog(BuildContext context, String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Đóng'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Parse lỗi trả về từ backend, ưu tiên error/message, list lỗi, hoặc fallback về lỗi chung
  static String parseApiError(dynamic error) {
    if (error == null) return 'Đã xảy ra lỗi không xác định';
    // Ưu tiên xử lý DioException chuẩn
    try {
      if (error.toString().contains('DioException')) {
        // Nếu là DioException chuẩn
        if (error is Exception && error.toString().contains('DioException')) {
          // Nếu có response và response.data
          final response = (error as dynamic).response;
          if (response != null && response.data != null) {
            final data = response.data;
            if (data is Map) {
              if (data['error'] != null) return data['error'].toString();
              if (data['message'] != null) return data['message'].toString();
            }
            if (data is String) return data;
          }
        }
        // Nếu là chuỗi exception, cố gắng parse JSON trong chuỗi
        final match = RegExp(r'\{.*\}').firstMatch(error.toString());
        if (match != null) {
          try {
            final data = json.decode(match.group(0)!);
            if (data is Map) {
              if (data['error'] != null) return data['error'].toString();
              if (data['message'] != null) return data['message'].toString();
            }
          } catch (_) {}
        }
        return 'Có lỗi kết nối, vui lòng thử lại!';
      }
    } catch (_) {}
    // Nếu là Exception chứa message
    if (error is Exception) {
      final msg = error.toString().replaceAll('Exception:', '').trim();
      if (msg.isNotEmpty && msg != 'Dữ liệu không hợp lệ') return msg;
    }
    // Nếu là Map hoặc List
    final parsed = _parseErrorData(error);
    if (parsed.isNotEmpty && parsed != 'Đã xảy ra lỗi không xác định' && parsed.toLowerCase() != 'dữ liệu không hợp lệ') return parsed;
    return 'Có lỗi xảy ra, vui lòng thử lại!';
  }

  static String _parseErrorData(dynamic data) {
    if (data == null) return 'Đã xảy ra lỗi không xác định';
    if (data is List) {
      return data.map((e) => e['message'] ?? '').where((m) => m != null && m.toString().isNotEmpty).join('\n');
    }
    if (data is Map) {
      if (data['error'] != null) return data['error'].toString();
      if (data['message'] != null) return data['message'].toString();
    }
    return data.toString();
  }
} 