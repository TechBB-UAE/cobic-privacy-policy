import 'package:cobic/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cobic/utils/error_utils.dart';

class TransactionService {
  static Future<bool> transferCobic({
    required BuildContext context,
    required String token,
    required String recipientUsername,
    required double amount,
    Function(String newBalance)? onSuccess,
  }) async {
    try {
      final res = await ApiService.transferCobic(token, recipientUsername, amount);
      if (res.statusCode == 200 && res.data['success'] == true) {
        ErrorUtils.showSuccessToast(context, 'Chuyển Cobic thành công!');
        if (onSuccess != null && res.data['newBalance'] != null) {
          onSuccess(res.data['newBalance'].toString());
        }
        return true;
      } else {
        ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(res.data, context));
        return false;
      }
    } catch (e) {
      ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e, context));
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTransactions({
    required String token,
    int limit = 20,
    int offset = 0,
    String type = 'all',
  }) async {
    try {
      final res = await ApiService.fetchTransactions(token, limit: limit, offset: offset, type: type);
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data);
      } else {
        throw Exception('Lỗi lấy lịch sử giao dịch');
      }
    } catch (e) {
      rethrow;
    }
  }
} 