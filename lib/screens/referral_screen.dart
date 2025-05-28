import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/referral_provider.dart';
import 'package:cobic/models/referral_stats.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/services/referral_service.dart';
import 'package:cobic/screens/scan_qr_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giới thiệu'),
        centerTitle: true,
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
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
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Người đã mời', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text('${stats.currentReferrals}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.lightTheme.primaryColor)),
                                Text('/${stats.maxReferrals}', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Lượt mời còn lại', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('${stats.remainingReferrals}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.lightTheme.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Người đã mời
                Text('Người dùng bạn đã mời', style: TextStyle(color: AppTheme.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Column(
                      children: [
                        if (totalInvited == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('Chưa có ai được mời', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14)),
                          )
                        else ...[
                          ...pagedUsers.map((user) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.lightTheme.primaryColor.withOpacity(0.10)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(0.15),
                                  child: Icon(Icons.person, color: AppTheme.lightTheme.primaryColor, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(user.username, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                                Text('Tham gia ${_formatDate(user.joinedAt)}', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
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
                                    icon: const Icon(Icons.chevron_left, color: Colors.white70),
                                    onPressed: _currentPage > 0
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  Text('Trang ${_currentPage + 1}/$totalPages', style: TextStyle(color: AppTheme.secondaryTextColor)),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right, color: Colors.white70),
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
                ),
                const SizedBox(height: 24),
                // Người đã mời bạn
                Text('Người đã mời bạn', style: TextStyle(color: AppTheme.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    child: stats.whoReferredMe != null
                        ? Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(0.15),
                                child: Icon(Icons.person, color: AppTheme.lightTheme.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stats.whoReferredMe!.username, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('Mã giới thiệu: ${stats.whoReferredMe!.referralCode}', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Text('Chưa có ai mời bạn', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 24),
                // Vòng tròn bảo mật
                Text('Vòng tròn bảo mật', style: TextStyle(color: AppTheme.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    child: stats.securityCircles.isNotEmpty
                        ? Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(0.15),
                                child: Icon(Icons.verified_user, color: AppTheme.lightTheme.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stats.securityCircles.first.username, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('Mã giới thiệu: ${stats.securityCircles.first.referralCode}', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                                    Text('Tham gia: ${_formatDate(stats.securityCircles.first.joinedAt)}', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Text('Bạn chưa có vòng tròn bảo mật', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vòng tròn bảo mật được tạo ra khi hai người dùng cùng giới thiệu lẫn nhau. Hãy tìm người bạn tin tưởng và tạo vòng tròn bảo mật để được +0.1 vào tỉ lệ đào.',
                  style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
                ),
                const SizedBox(height: 24),
                // Mã giới thiệu của bạn
                Text('Mã giới thiệu của bạn', style: TextStyle(color: AppTheme.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final profileProvider = Provider.of<ProfileProvider>(context);
                    final referralCode = profileProvider.userInfo?['referralCode'] ?? '';
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(referralCode, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                if (referralCode.toString().isNotEmpty) {
                                  await Clipboard.setData(ClipboardData(text: referralCode.toString()));
                                  ErrorUtils.showSuccessToast(context, 'Đã copy mã giới thiệu!');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.copy, color: Colors.white70, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text('Chia sẻ mã này để mời người khác và nhận thưởng tăng tỉ lệ đào!', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                const SizedBox(height: 24),
                // Nhập mã giới thiệu
                Text('Nhập mã giới thiệu', style: TextStyle(color: AppTheme.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                if (stats.whoReferredMe != null)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                      child: Text(
                        'Bạn đã nhập mã giới thiệu, chỉ được nhập 1 lần duy nhất!',
                        style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _referralCodeController,
                          decoration: InputDecoration(
                            hintText: 'Nhập mã',
                            hintStyle: TextStyle(color: AppTheme.secondaryTextColor),
                            filled: true,
                            fillColor: AppTheme.lightTheme.cardTheme.color,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 15),
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
                              ErrorUtils.showErrorToast(context, 'Vui lòng nhập mã giới thiệu!');
                              return;
                            }
                            setState(() => _isSubmitting = true);
                            try {
                              await ReferralService.submitReferralCode(code);
                              ErrorUtils.showSuccessToast(context, 'Nhập mã giới thiệu thành công!');
                              _referralCodeController.clear();
                              // Cập nhật lại profile
                              await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
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
                            backgroundColor: AppTheme.lightTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: _isSubmitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
 