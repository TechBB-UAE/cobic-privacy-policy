import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/services/transaction_service.dart';
import 'package:cobic/services/transaction_translation_service.dart';
import 'dart:convert';
import 'package:cobic/screens/scan_qr_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:cobic/widgets/language_switch_button.dart';
import 'package:cobic/providers/theme_provider.dart';
import 'package:cobic/utils/error_utils.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool isSending = false;

  List<Map<String, dynamic>> allTransactions = [];
  int _currentPage = 0;
  final int _pageSize = 5;
  bool _isLoadingHistory = false;
  String? _historyError;
  int _totalCount = 0;

  List<Map<String, dynamic>> get pagedTransactions {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize) > allTransactions.length ? allTransactions.length : (start + _pageSize);
    return allTransactions.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null) {
      setState(() {
        _isLoadingHistory = false;
        _historyError = 'Bạn chưa đăng nhập!';
      });
      return;
    }
    try {
      final data = await TransactionService.fetchTransactions(
        token: token,
        limit: 1000, // lấy hết giao dịch
        offset: 0,
      );
      List<Map<String, dynamic>> list = [];
      if (data is List) {
        list = data.whereType<Map<String, dynamic>>().toList();
        // Sắp xếp theo timestamp giảm dần (mới nhất lên đầu)
        list.sort((a, b) {
          final aTime = DateTime.tryParse(a['timestamp']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = DateTime.tryParse(b['timestamp']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
      }
      setState(() {
        allTransactions = list;
        _isLoadingHistory = false;
        _currentPage = 0;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
        _historyError = 'Lỗi lấy lịch sử giao dịch';
      });
    }
  }

  void _nextPage() {
    if ((_currentPage + 1) * _pageSize < allTransactions.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _sendCobic() async {
    final receiver = _receiverController.text.trim();
    final amountText = _amountController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final currentUsername = profileProvider.userInfo?['username']?.toString() ?? '';
    if (receiver.isEmpty) {
      ErrorUtils.showErrorToast(context, l10n.pleaseEnterCode);
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ErrorUtils.showErrorToast(context, l10n.invalidAmount);
      return;
    }
    if (receiver == currentUsername) {
      ErrorUtils.showErrorToast(context, l10n.cannotTransferToYourself);
      return;
    }
    setState(() => isSending = true);
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null) {
      setState(() => isSending = false);
      ErrorUtils.showErrorToast(context, 'Bạn chưa đăng nhập!');
      return;
    }
    await TransactionService.transferCobic(
      context: context,
      token: token,
      recipientUsername: receiver,
      amount: amount,
      onSuccess: (newBalance) {
        _receiverController.clear();
        _amountController.clear();
        if (profileProvider.userInfo != null) {
          profileProvider.userInfo!['balance'] = newBalance;
          profileProvider.notifyListeners();
        }
        _fetchHistory();
      },
    );
    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);
    final userInfo = profileProvider.userInfo;
    final balance = double.tryParse(userInfo?['balance']?.toString() ?? '0.00') ?? 0.0;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar.themed(
        context: context,
        titleText: l10n.wallet,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(l10n.currentBalance, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${balance.toStringAsFixed(2)} Cobic',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.transactionHistory,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingHistory)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_historyError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text(_historyError!, style: TextStyle(color: Colors.redAccent))),
                    )
                  else if (allTransactions.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text(l10n.noTransaction, style: Theme.of(context).textTheme.bodyMedium)),
                    )
                  else ...pagedTransactions.map((item) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      leading: Icon(
                        item['type'] == 'transfer' ? Icons.arrow_upward : Icons.arrow_downward,
                        color: item['type'] == 'transfer' ? Colors.red : Colors.green,
                        size: 28,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              TransactionTranslationService.getTransactionTypeText(context, item['type']),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            (item['type'] == 'transfer' ? '-' : '+') + (double.tryParse(item['amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00') + ' Cobic',
                            style: TextStyle(
                              color: item['type'] == 'transfer' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            TransactionTranslationService.getTransactionDescription(context, item),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['timestamp'] != null ? item['timestamp'].toString() : '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage > 0 && !_isLoadingHistory ? _prevPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(_currentPage > 0 && !_isLoadingHistory ? 1 : 0.4),
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: Text(l10n.previousPage, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: ((_currentPage + 1) * _pageSize < allTransactions.length) && !_isLoadingHistory ? _nextPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(((_currentPage + 1) * _pageSize < allTransactions.length) && !_isLoadingHistory ? 1 : 0.4),
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: Text(l10n.nextPage, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trang ${_currentPage + 1} / ${(allTransactions.isEmpty ? 1 : (allTransactions.length / _pageSize).ceil())}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 