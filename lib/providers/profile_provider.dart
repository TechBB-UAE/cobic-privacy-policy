import 'package:flutter/material.dart';
import 'package:cobic/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? userInfo;
  bool isLoading = false;
  String? error;

  Future<void> fetchUserInfo(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ProfileService.getUserInfo();
      userInfo = res; // API /auth/me trả về trực tiếp thông tin user
    } catch (e) {
      error = e.toString();
      // Nếu lỗi khi lấy thông tin user, tự động logout và chuyển về trang đăng nhập
      await ProfileService.logout();
      // ignore: use_build_context_synchronously
      Future.delayed(Duration.zero, () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
    }
    isLoading = false;
    notifyListeners();
  }

  String get miningRate => userInfo?['miningRate']?.toString() ?? '0.00';
  // Có thể thêm getter cho balance, email, v.v.
} 