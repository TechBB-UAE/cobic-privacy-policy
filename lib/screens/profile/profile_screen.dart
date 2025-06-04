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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cobic/providers/language_provider.dart';
import 'package:cobic/widgets/language_switch_button.dart';

class ProfileScreen extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  const ProfileScreen({super.key, this.navigatorKey});

  String _formatDate(String? dateStr, AppLocalizations l10n) {
    if (dateStr == null) return l10n.notUpdated;
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return l10n.notUpdated;
    }
  }

  String _formatKycStatus(String? status, AppLocalizations l10n) {
    if (status == null) return l10n.notUpdated;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pending;
      case 'approved':
        return l10n.approved;
      case 'rejected':
        return l10n.rejected;
      default:
        return l10n.notUpdated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        titleText: l10n.profile,
        backgroundColor: Colors.white,
        iconColor: AppTheme.textColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppTheme.textColor),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          const LanguageSwitchButton(),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.textColor),
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
              userInfo['email'] ?? l10n.missingEmail,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shadowColor: Colors.black12,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile(
                      icon: Icons.code,
                      label: l10n.referralCode,
                      value: userInfo['referralCode'] ?? l10n.notUpdated,
                      copyable: (userInfo['referralCode'] ?? '').toString().isNotEmpty,
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.balance,
                      label: l10n.balance,
                      value: '${userInfo['balance'] ?? '0.00'} COBIC',
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.balance,
                      label: l10n.nonTransferableBalance,
                      value: '${userInfo['nonTransferableBalance'] ?? '0.00'} COBIC',
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.calculate,
                      label: l10n.miningRate,
                      value: l10n.cobicPerDay(double.tryParse(userInfo['miningRate']?.toString() ?? '0')?.toStringAsFixed(4) ?? '0.0000'),
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.cake,
                      label: l10n.dob,
                      value: _formatDate(userInfo['dateOfBirth'], l10n),
                      context: context,
                    ),
                    _infoTile(
                      icon: Icons.verified,
                      label: l10n.kycStatus,
                      value: _formatKycStatus(userInfo['kycStatus'], l10n),
                      context: context,
                    ),
                    if (userInfo['kycRejectionReason'] != null)
                      _infoTile(
                        icon: Icons.error,
                        label: l10n.reasonKycRejected,
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
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shadowColor: Colors.black12,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: AppTheme.lightTheme.primaryColor),
                    title: Text(l10n.edit, style: TextStyle(color: AppTheme.textColor)),
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
                    title: Text(l10n.changePassword, style: TextStyle(color: AppTheme.textColor)),
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
                    title: Text(l10n.sendKyc, style: TextStyle(color: AppTheme.textColor)),
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
                    title: Text(l10n.logout, style: TextStyle(color: AppTheme.textColor)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: TextStyle(
            color: AppTheme.lightTheme.textTheme.displayMedium?.color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          l10n.logoutConfirmContent,
          style: const TextStyle(color: AppTheme.textColor),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.logout),
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
    ErrorUtils.showSuccessToast(context, AppLocalizations.of(context)!.logoutSuccess);

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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.lightTheme.primaryColor),
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
                                  l10n.reasonKycRejected,
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
                                    child: Text(l10n.close),
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
                    tooltip: l10n.copyReferralCode,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ErrorUtils.showSuccessToast(context, l10n.copyReferralCode);
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