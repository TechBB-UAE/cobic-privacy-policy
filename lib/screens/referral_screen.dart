import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/referral_provider.dart';
import 'package:cobic/models/referral_stats.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/services/referral_service.dart';
import 'package:cobic/screens/scan_qr_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:cobic/widgets/language_switch_button.dart';
import 'package:cobic/providers/theme_provider.dart';

class ReferralScreen extends StatefulWidget {
  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final TextEditingController _referralCodeController = TextEditingController();
  bool _isSubmitting = false;

  // Phân trang danh sách người đã mời
  int _currentPage = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    // Fetch referral stats khi màn hình được tạo
    Provider.of<ReferralProvider>(context, listen: false).fetchReferralStats();
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.referral,
        leading: IconButton(
          icon: Icon(Icons.home, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        actions: [
          const LanguageSwitchButton(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              tooltip: themeProvider.isDarkMode ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
              onPressed: () {
                themeProvider.setThemeMode(
                  themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const ScanQrScreen(targetRoute: '/home')),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Consumer<ReferralProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Lỗi: ${provider.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final stats = provider.referralStats;
          if (stats == null) {
            return const Center(
              child: Text('Không có dữ liệu'),
            );
          }

          // Phân trang danh sách người đã mời
          final totalInvited = stats.referredByMe.length;
          final totalPages = (totalInvited / _pageSize).ceil();
          final start = _currentPage * _pageSize;
          final end = ((start + _pageSize) > totalInvited) ? totalInvited : (start + _pageSize);
          final pagedUsers = stats.referredByMe.sublist(start, end);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thống kê lượt mời
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.invitedUsers, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text('${stats.currentReferrals}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                              Text('/${stats.maxReferrals}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.remainingInvites, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Text('${stats.remainingReferrals}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Người đã mời
                Text(l10n.invitedByYou, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(
                    children: [
                      if (totalInvited == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(l10n.noInvitedUsers, style: Theme.of(context).textTheme.bodyMedium),
                        )
                      else ...[
                        ...pagedUsers.map((user) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(user.username, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                              Text(l10n.joinedAt(_formatDate(user.joinedAt)), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        )),
                        if (totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                                  onPressed: _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                                ),
                                Text('Trang ${_currentPage + 1}/$totalPages', style: Theme.of(context).textTheme.bodySmall),
                                IconButton(
                                  icon: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                                  onPressed: _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Người đã mời bạn
                Text(l10n.invitedBy, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  child: stats.whoReferredMe != null
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stats.whoReferredMe!.username, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(l10n.referralCodeLabel(stats.whoReferredMe!.referralCode), style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Text(l10n.noReferrer, style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: 24),
                // Vòng tròn bảo mật
                Text(l10n.securityCircle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  child: stats.securityCircles.isNotEmpty
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              child: Icon(Icons.verified_user, color: Theme.of(context).colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stats.securityCircles.first.username, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(l10n.referralCodeLabel(stats.securityCircles.first.referralCode), style: Theme.of(context).textTheme.bodySmall),
                                  Text(l10n.joinedAt(_formatDate(stats.securityCircles.first.joinedAt)), style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Text(l10n.noSecurityCircle, style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.securityCircleDesc,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                // Mã giới thiệu của bạn
                Text(l10n.yourReferralCode, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                    final referralCode = profileProvider.userInfo?['referralCode'] ?? '';
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(referralCode, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              if (referralCode.toString().isNotEmpty) {
                                await Clipboard.setData(ClipboardData(text: referralCode.toString()));
                                ErrorUtils.showSuccessToast(context, l10n.copyReferralCode);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.copy,
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(l10n.shareReferral, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                // Nhập mã giới thiệu
                Text(l10n.enterReferralCode, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (stats.whoReferredMe != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    child: Text(
                      l10n.alreadyEnteredCode,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _referralCodeController,
                          decoration: InputDecoration(
                            hintText: l10n.referralCodeHint,
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                          enabled: !_isSubmitting,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () async {
                            final code = _referralCodeController.text.trim();
                            if (code.isEmpty) {
                              ErrorUtils.showErrorToast(context, l10n.pleaseEnterCode);
                              return;
                            }
                            setState(() => _isSubmitting = true);
                            try {
                              await ReferralService.submitReferralCode(code);
                              ErrorUtils.showSuccessToast(context, l10n.enterCodeSuccess);
                              _referralCodeController.clear();
                              // Cập nhật lại profile
                              await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo(context);
                              // Thêm delay để backend kịp cập nhật
                              await Future.delayed(const Duration(milliseconds: 1000));
                              // Cập nhật lại referral stats
                              await Provider.of<ReferralProvider>(context, listen: false).fetchReferralStats();
                            } catch (e) {
                              ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
                            } finally {
                              if (mounted) setState(() => _isSubmitting = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: _isSubmitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(
                                l10n.apply,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 15,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
 