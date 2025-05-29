import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/services/api_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/screens/main_tab_screen.dart';
import 'package:cobic/screens/login_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/mining_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:async';
import 'package:cobic/providers/profile_provider.dart';
import 'package:cobic/utils/navigation_helper.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:cobic/services/profile_service.dart';
import 'package:cobic/screens/scan_qr_screen.dart';
import 'package:cobic/screens/user_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _popupKey = GlobalKey();
  bool _loading = false;
  String? _popupMessage;
  Color _popupMessageColor = Colors.green;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;
  String? _username;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initMiningStatus();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    _token = await _secureStorage.read(key: 'token');
    _username = await _secureStorage.read(key: 'username');
    if (_token != null) {
      // Auto fetch user info khi đã có token
      Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
    } else {
      final miningProvider = Provider.of<MiningProvider>(context, listen: false);
      miningProvider.reset();
    }
    setState(() {});
  }

  Future<void> _initMiningStatus() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      final mining = Provider.of<MiningProvider>(context, listen: false);
      await mining.fetchMiningStatus(token);
    }
  }

  Future<void> _registerGuest() async {
    setState(() => _loading = true);
    try {
      final response = await ApiService.client.post('/auth/guest-register');
      if (response.statusCode == 201 && response.data['user'] != null) {
        final user = response.data['user'];
        final username = user['username'] ?? '';
        final password = user['plainPassword'] ?? '';
        final token = response.data['token'] ?? '';
        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'username', value: username);
        await _secureStorage.write(key: 'password', value: password);
        await _secureStorage.write(key: 'isGuest', value: 'true');
        setState(() {
          _popupMessage = null;
        });
        await _showUserInfoPopup(username, password);
        await _checkLoginStatus();
        await _initMiningStatus();
      } else {
        _showError('Đăng ký tài khoản khách thất bại!');
      }
    } catch (e) {
      _showError('Có lỗi xảy ra, vui lòng thử lại!');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _dailyCheckIn() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      final mining = Provider.of<MiningProvider>(context, listen: false);
      await mining.dailyCheckIn(token);
      if (mounted) {
        ErrorUtils.showSuccessToast(context, 'Khai thác thành công! Nhận được ${mining.reward ?? '0.00'} COBIC. Số dư mới: ${mining.newBalance ?? '0.00'} COBIC');
        await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
      }
    }
  }

  Future<void> _showUserInfoPopup(String username, String password) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: RepaintBoundary(
            key: _popupKey,
            child: UserInfoCard(
              username: username,
              password: password,
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    setState(() {
      _popupMessage = message;
      _popupMessageColor = Colors.red;
    });
  }

  Widget buildLoginButton() {
    final isLoggedIn = _token != null;
    final labelText = isLoggedIn
        ? ((_username != null && _username!.isNotEmpty) ? _username! : 'Tài khoản')
        : 'Đăng nhập';

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textColor,
        side: BorderSide(color: Colors.grey.shade300, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(
          color: AppTheme.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: () async {
        if (isLoggedIn) {
          Navigator.of(context).pushReplacementNamed('/main');
          await _checkLoginStatus();
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
          await _checkLoginStatus();
        }
      },
      icon: const Icon(Icons.person, color: AppTheme.textColor, size: 22),
      label: Text(
        labelText,
        style: const TextStyle(
          color: AppTheme.textColor,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mining = Provider.of<MiningProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarHomeColor,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_token != null)
            _UserMenuButton(
              username: (_username != null && _username!.isNotEmpty) ? _username! : 'Tài khoản',
              onProfile: () {
                Navigator.of(context).pushReplacementNamed('/main');
              },
              onLogout: () async {
                await ProfileService.logout();
                Provider.of<ProfileProvider>(context, listen: false).userInfo = null;
                Provider.of<ProfileProvider>(context, listen: false).error = null;
                Provider.of<ProfileProvider>(context, listen: false).isLoading = false;
                Provider.of<MiningProvider>(context, listen: false).reset();
                ErrorUtils.showSuccessToast(context, 'Đăng xuất thành công!');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            )
          else
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: buildLoginButton(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.gif',
              width: 260,
              height: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/logo-text.png',
              width: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 340,
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.white; // hoặc AppTheme._secondaryTextColor nếu muốn nhạt hơn
                    }
                    return Colors.white;
                  }),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return AppTheme.lightTheme.primaryColor.withOpacity(0.5);
                    }
                    return AppTheme.lightTheme.primaryColor;
                  }),
                ),
                onPressed: mining.isLoading || (_token != null && !mining.canMine)
                    ? null
                    : () async {
                        // Lấy token từ secure storage hoặc provider Auth nếu có
                        final token = await _secureStorage.read(key: 'token');
                        if (token != null) {
                          await _dailyCheckIn();
                        } else {
                          await _registerGuest();
                        }
                      },
                child: mining.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _token == null ? 'Bắt đầu khai thác ngay' : (mining.canMine ? 'Sẵn Sàng Khai thác' : 'Đang đếm ngược... ${mining.nextMiningTime != null ? '(${_formatCountdown(mining.nextMiningTime!)})' : ''}')
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 340,
              child: OutlinedButton(
                onPressed: () async {
                  final token = await _secureStorage.read(key: 'token');
                  if (token == null) {
                    Navigator.of(context).pushReplacementNamed('/login');
                    return;
                  }
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScanQrScreen()),
                  );
                  if (result == true) {
                    // Có thể cập nhật điểm hoặc thông tin khác nếu cần
                  }
                },
                child: const Text(
                  'Quét mã QR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(DateTime nextTime) {
    final now = DateTime.now().toUtc();
    final difference = nextTime.toUtc().difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _UserMenuButton extends StatefulWidget {
  final String username;
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  const _UserMenuButton({required this.username, required this.onProfile, required this.onLogout});

  @override
  State<_UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<_UserMenuButton> {
  OverlayEntry? _overlayEntry;

  void _showMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + size.height + 8,
              left: offset.dx + size.width - 180,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _hideMenu();
                          widget.onProfile();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Trang cá nhân',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          _hideMenu();
                          widget.onLogout();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMenu,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: AppTheme.textColor, size: 22),
            const SizedBox(width: 8),
            Text(
              widget.username,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 