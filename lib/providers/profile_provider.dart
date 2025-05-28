import 'package:flutter/material.dart';
import 'package:cobic/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? userInfo;
  bool isLoading = false;
  String? error;

  Future<void> fetchUserInfo() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ProfileService.getUserInfo();
      userInfo = res; // API /auth/me trả về trực tiếp thông tin user
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  String get miningRate => userInfo?['miningRate']?.toString() ?? '0.00';
  // Có thể thêm getter cho balance, email, v.v.
} 