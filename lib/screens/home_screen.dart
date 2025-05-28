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
            child: _UserInfoCard(
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
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        if (_token != null) {
          Navigator.of(context).pushReplacementNamed('/main');
          await _checkLoginStatus();
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
          await _checkLoginStatus();
        }
      },
      icon: const Icon(Icons.person, color: Colors.white, size: 22),
      label: Text(
        _token != null ? (_username ?? 'Tài khoản') : 'Đăng nhập',
        style: const TextStyle(
          color: Colors.white,
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
        backgroundColor: const Color(0xFF1A0742),
        elevation: 0,
        title: null,
        automaticallyImplyLeading: false,
        actions: [
          if (_token != null)
            PopupMenuButton<String>(
              offset: const Offset(0, 56),
              color: AppTheme.lightTheme.cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.lightTheme.primaryColor, width: 1),
              ),
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.lightTheme.primaryColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      _username ?? 'Tài khoản',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              onSelected: (value) async {
                if (value == 'profile') {
                  Navigator.of(context).pushReplacementNamed('/main');
                } else if (value == 'logout') {
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
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  height: 48,
                  child: Center(
                    child: Text('Trang cá nhân', style: TextStyle(color: AppTheme.textColor, fontSize: 16)),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  height: 48,
                  child: Center(
                    child: Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
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
              width: 280,
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
              width: 280,
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

// Widget hiển thị thông tin tài khoản và callback khi build xong
class _UserInfoCard extends StatefulWidget {
  final String username;
  final String password;
  const _UserInfoCard({required this.username, required this.password});

  @override
  State<_UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  String? _message;
  Color _messageColor = Colors.green;
  final GlobalKey _infoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      print('Bắt đầu chụp widget thông tin...');
      await _captureAndSaveInfo();
    });
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _message = '$label đã được sao chép!';
      _messageColor = Colors.blueAccent;
    });
  }

  Future<void> _captureAndSaveInfo() async {
    try {
      RenderRepaintBoundary boundary = _infoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      var photosStatus = await Permission.photos.request();
      var storageStatus = await Permission.storage.request();

      if (photosStatus.isGranted || storageStatus.isGranted) {
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: "cobic_guest_info_${DateTime.now().millisecondsSinceEpoch}"
        );
        print('Save image result: ' + result.toString());
        if ((result['isSuccess'] == true || result['isSuccess'] == 1) && mounted) {
          setState(() {
            _message = 'Đã lưu thông tin vào thư viện ảnh!';
            _messageColor = Colors.green;
          });
        } else {
          setState(() {
            _message = 'Lưu ảnh thất bại! (result: ${result.toString()})';
            _messageColor = Colors.red;
          });
        }
      } else {
        setState(() {
          _message = 'Không có quyền lưu ảnh vào Photos!';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Lưu ảnh thất bại! ($e)';
        _messageColor = Colors.red;
      });
      print('Lỗi khi chụp/lưu ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2D1457),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1457),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Widget chụp ảnh chuyên nghiệp
            RepaintBoundary(
              key: _infoKey,
              child: Container(
                width: 300,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D1457),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.gif',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tài khoản khách',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Tên đăng nhập + nút copy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Tên đăng nhập:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                          tooltip: 'Sao chép tên đăng nhập',
                          onPressed: () => _copyToClipboard(widget.username, 'Tên đăng nhập'),
                        ),
                      ],
                    ),
                    Text(
                      widget.username,
                      style: const TextStyle(
                        color: Color(0xFFB266FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Mật khẩu + nút copy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Mật khẩu:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                          tooltip: 'Sao chép mật khẩu',
                          onPressed: () => _copyToClipboard(widget.password, 'Mật khẩu'),
                        ),
                      ],
                    ),
                    Text(
                      widget.password,
                      style: const TextStyle(
                        color: Color(0xFFB266FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Lưu lại thông tin này để đăng nhập về sau!',
                      style: TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Thông báo
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _message!,
                  style: TextStyle(color: _messageColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
} 