import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:cobic/screens/home_screen.dart';
import 'package:cobic/screens/profile_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cobic/providers/mining_provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/utils/error_utils.dart';

class MiningScreen extends StatefulWidget {
  final double miningRate;
  final String miningStatus;
  final String dailyCheckinStatus;
  final bool canMine;
  final DateTime? nextMiningTime;
  final VoidCallback? onMine;
  final VoidCallback? onScanQR;

  const MiningScreen({
    super.key,
    this.miningRate = 0.95,
    this.miningStatus = 'Sẵn sàng đào!',
    this.dailyCheckinStatus = 'Cần điểm danh',
    this.canMine = true,
    this.nextMiningTime,
    this.onMine,
    this.onScanQR,
  });

  @override
  State<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends State<MiningScreen> {
  late Timer _timer;
  Duration _countdown = Duration.zero;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    if (widget.nextMiningTime != null) {
      final now = DateTime.now().toUtc();
      final diff = widget.nextMiningTime!.difference(now);
      setState(() {
        _countdown = diff.isNegative ? Duration.zero : diff;
      });
    } else {
      setState(() {
        _countdown = Duration.zero;
      });
    }
  }

  String _formatCountdown(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _progressPercent() {
    if (widget.nextMiningTime == null) return 0.0;
    final now = DateTime.now().toUtc();
    final total = const Duration(hours: 24);
    final diff = widget.nextMiningTime!.difference(now);
    return (diff.isNegative ? 0.0 : diff.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  Future<void> _handleMining() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      final miningProvider = Provider.of<MiningProvider>(context, listen: false);
      await miningProvider.dailyCheckIn(token);
      if (mounted) {
        ErrorUtils.showSuccessToast(context, 'Khai thác thành công! Nhận được ${miningProvider.reward ?? '0.00'} COBIC. Số dư mới: ${miningProvider.newBalance ?? '0.00'} COBIC');
        await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Khai thác',
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
            onPressed: widget.onScanQR,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Logo
                Image.asset(
                  'assets/images/logo.gif',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                // Mining rate
                Text(
                  widget.miningRate.toStringAsFixed(4),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cobic/hr',
                  style: TextStyle(color: AppTheme.lightTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tỷ lệ đào',
                  style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
                ),
                const SizedBox(height: 20),
                // Card mining
                Card(
                  color: AppTheme.lightTheme.cardTheme.color,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                              minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: widget.canMine ? _handleMining : null,
                            icon: const Icon(Icons.bolt, size: 22, color: Colors.white),
                            label: const Text(
                              'bắt đầu khai thác ngay',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Đào tiếp theo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đào tiếp theo', style: TextStyle(color: AppTheme.secondaryTextColor)),
                            Text(
                              widget.canMine
                                ? 'Sẵn sàng đào!'
                                : (widget.nextMiningTime != null ? 'Đang đếm ngược... (${_formatCountdown(_countdown)})' : 'Đang đếm ngược...'),
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.lightTheme.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _progressPercent(),
                          minHeight: 6,
                          backgroundColor: Colors.deepPurple.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Card Quét VietQR
                Card(
                  color: AppTheme.lightTheme.cardTheme.color,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppTheme.lightTheme.primaryColor!, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code_2, color: AppTheme.lightTheme.primaryColor, size: 28),
                            const SizedBox(width: 8),
                            Text('Quét VietQR', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.lightTheme.primaryColor, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quét mã VietQR để nhận Cobic Points\nTích điểm Cobic Points với tỷ lệ 250 VND = 1 Cobic Point.',
                          style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: widget.onScanQR,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                            ),
                            child: const Text('Quét Ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 