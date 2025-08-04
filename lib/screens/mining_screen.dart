import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:cobic/screens/home_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cobic/providers/mining_provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/utils/error_utils.dart';
import '../l10n/app_localizations.dart';
import 'package:cobic/widgets/language_switch_button.dart';
import 'package:cobic/screens/scan_qr_screen.dart';
import 'package:cobic/providers/theme_provider.dart';

class MiningScreen extends StatefulWidget {
  final VoidCallback? onScanQR;
  const MiningScreen({super.key, this.onScanQR});

  @override
  State<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends State<MiningScreen> {
  Timer? _timer;
  Duration _countdown = Duration.zero;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMiningStatus());
  }

  Future<void> _initMiningStatus() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      await Provider.of<MiningProvider>(context, listen: false).fetchMiningStatus(token);
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() async {
    final miningProvider = Provider.of<MiningProvider>(context, listen: false);
    final nextMiningTime = miningProvider.nextMiningTime;
    if (nextMiningTime != null) {
      final now = DateTime.now().toUtc();
      final diff = nextMiningTime.difference(now);
      if (diff.isNegative || diff.inSeconds <= 0) {
        setState(() {
          _countdown = Duration.zero;
        });
        _timer?.cancel();
        // Gọi lại fetchMiningStatus để cập nhật trạng thái mining
        final token = await _secureStorage.read(key: 'token');
        if (token != null) {
          await miningProvider.fetchMiningStatus(token);
          final updatedProvider = Provider.of<MiningProvider>(context, listen: true);
          setState(() {});
          if (updatedProvider.canMine) {
            setState(() {});
          }
        }
      } else {
      setState(() {
          _countdown = diff;
      });
      }
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

  double _progressPercent(DateTime? nextMiningTime) {
    if (nextMiningTime == null) return 0.0;
    final now = DateTime.now().toUtc();
    final total = const Duration(hours: 24);
    final diff = nextMiningTime.difference(now);
    return (diff.isNegative ? 0.0 : diff.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }

  Future<void> _handleMining() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      final miningProvider = Provider.of<MiningProvider>(context, listen: false);
      await miningProvider.dailyCheckIn(token);
      if (mounted) {
        ErrorUtils.showSuccessToast(context, 'Khai thác thành công! Nhận được ${miningProvider.reward ?? '0.00'} COBIC. Số dư mới: ${miningProvider.newBalance ?? '0.00'} COBIC');
        await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo(context);
        _startCountdown();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final miningProvider = Provider.of<MiningProvider>(context, listen: false);
    final canMine = miningProvider.canMine;
    final nextMiningTime = miningProvider.nextMiningTime;
    final miningRate = double.tryParse(miningProvider.miningRate ?? '0.0') ?? 0.0;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.mining,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      miningRate.toStringAsFixed(4),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Cobic/hr',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.miningRate,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                // Card mining
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: canMine ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: canMine ? _handleMining : null,
                            icon: Icon(Icons.bolt, size: 22, color: canMine ? Colors.white : Theme.of(context).iconTheme.color),
                            label: Text(
                              l10n.mine,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: canMine ? Colors.white : Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Đào tiếp theo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.nextMining, style: Theme.of(context).textTheme.bodyMedium),
                            Text(
                              canMine
                                ? l10n.readyToMine
                                : (nextMiningTime != null ? "${l10n.countingDown} (${_formatCountdown(_countdown)})" : l10n.countingDown),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _progressPercent(nextMiningTime),
                          minHeight: 6,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Card Quét VietQR
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code_2, color: Theme.of(context).colorScheme.primary, size: 28),
                            const SizedBox(width: 8),
                            Text(l10n.scanVietQR, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.scanVietQRDesc,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: widget.onScanQR,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                            ),
                            child: Text(l10n.scanNow, style: const TextStyle(fontWeight: FontWeight.bold)),
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