import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/services/profile_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cobic/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/mining_provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'profile_update_screen.dart';
import 'change_password_screen.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:cobic/screens/main_tab_screen.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/screens/kyc_submit_screen.dart';
import 'package:cobic/screens/scan_qr_screen.dart';

class ProfileScreen extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  const ProfileScreen({super.key, this.navigatorKey});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Chưa cập nhật';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Chưa cập nhật';
    }
  }

  String _formatKycStatus(String? status) {
    if (status == null) return 'Chưa xác thực';
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Đang chờ duyệt';
      case 'approved':
        return 'Đã xác thực';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Chưa xác thực';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userInfo = profileProvider.userInfo;
    final isLoading = profileProvider.isLoading;
    final error = profileProvider.error;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }
    if (userInfo == null) {
      return const Center(child: Text('Không có dữ liệu tài khoản!'));
    }
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Cá nhân',
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        iconColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const ScanQrScreen(targetRoute: '/home')),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.gif',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              userInfo['fullName'] ?? userInfo['username'] ?? 'Chưa cập nhật',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              userInfo['email'] ?? 'Chưa cập nhật email',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              color: AppTheme.lightTheme.cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile(
                      icon: Icons.code,
                      label: 'Mã giới thiệu',
                      value: userInfo['referralCode'] ?? 'Chưa có',
                      copyable: (userInfo['referralCode'] ?? '').toString().isNotEmpty,
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.balance,
                      label: 'Số dư',
                      value: '${userInfo['balance'] ?? '0.00'} COBIC',
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.balance,
                      label: 'Số dư không chuyển được',
                      value: '${userInfo['nonTransferableBalance'] ?? '0.00'} COBIC',
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.calculate,
                      label: 'Tỷ lệ đào',
                      value: '${double.tryParse(userInfo['miningRate']?.toString() ?? '0')?.toStringAsFixed(4) ?? '0.0000'} COBIC/ngày',
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.cake,
                      label: 'Ngày sinh',
                      value: _formatDate(userInfo['dateOfBirth']),
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.verified,
                      label: 'Trạng thái KYC',
                      value: _formatKycStatus(userInfo['kycStatus']),
                      context: context,
                    ),
                    if (userInfo['kycRejectionReason'] != null)
                      _infoTile(
                        icon: Icons.error,
                        label: 'Lý do từ chối KYC',
                        value: userInfo['kycRejectionReason'],
                        context: context,
                        isLongText: true,
                      ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(top: 24, bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: AppTheme.lightTheme.primaryColor),
                    title: Text('Cập nhật hồ sơ', style: TextStyle(color: AppTheme.textColor)),
                    onTap: () {
                      if (navigatorKey != null) {
                        navigatorKey!.currentState?.push(
                          MaterialPageRoute(
                            builder: (context) => ProfileUpdateScreen(
                              navigatorKey: navigatorKey,
                            ),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileUpdateScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: AppTheme.lightTheme.primaryColor),
                    title: Text('Đổi mật khẩu', style: TextStyle(color: AppTheme.textColor)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.verified_user, color: AppTheme.lightTheme.primaryColor),
                    title: Text('Gửi KYC', style: TextStyle(color: AppTheme.textColor)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const KycSubmitScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text('Đăng xuất', style: TextStyle(color: AppTheme.textColor)),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận đăng xuất',
          style: TextStyle(
            color: AppTheme.lightTheme.textTheme.displayMedium?.color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Huỷ'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Đăng xuất'),
            onPressed: () async {
              Navigator.of(context).pop();
              await _logout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await ProfileService.logout();
    // Reset provider
    Provider.of<ProfileProvider>(context, listen: false).userInfo = null;
    Provider.of<ProfileProvider>(context, listen: false).error = null;
    Provider.of<ProfileProvider>(context, listen: false).isLoading = false;
    Provider.of<MiningProvider>(context, listen: false).reset();
    
    // Hiện thông báo
    ErrorUtils.showSuccessToast(context, 'Đăng xuất thành công!');

    // Chuyển về HomeScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
    required BuildContext context,
    bool isLongText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: const TextStyle(color: Colors.grey)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: isLongText
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: AppTheme.lightTheme.cardTheme.color,
                                title: Text(
                                  'Lý do từ chối KYC',
                                  style: TextStyle(
                                    color: AppTheme.lightTheme.textTheme.displayMedium?.color ?? Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: SingleChildScrollView(child: Text(value)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              ),
                            );
                          },
                    child: Text(
                            value,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )
                      : Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyable && value.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.deepPurple),
                    tooltip: 'Sao chép',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ErrorUtils.showSuccessToast(context, 'Đã sao chép mã giới thiệu!');
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 