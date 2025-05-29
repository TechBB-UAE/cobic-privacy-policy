import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/services/transaction_service.dart';
import 'dart:convert';
import 'package:cobic/screens/scan_qr_screen.dart';

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
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (receiver.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
      );
      return;
    }
    setState(() => isSending = true);
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null) {
      setState(() => isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập!')),
      );
      return;
    }
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
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
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userInfo = profileProvider.userInfo;
    final balance = double.tryParse(userInfo?['balance']?.toString() ?? '0.00') ?? 0.0;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        titleText: 'Ví',
        backgroundColor: Colors.white,
        iconColor: AppTheme.textColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppTheme.textColor),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
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
                  Text('Số dư hiện tại', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${balance.toStringAsFixed(2)} Cobic',
                    style: TextStyle(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Column(
              children: [
                TextField(
                  controller: _receiverController,
                  style: TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(
                    labelText: 'Tên người nhận',
                    labelStyle: TextStyle(color: AppTheme.secondaryTextColor),
                    filled: true,
                    fillColor: AppTheme.lightTheme.cardTheme.color,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(
                    labelText: 'Số lượng (Cobic)',
                    labelStyle: TextStyle(color: AppTheme.secondaryTextColor),
                    filled: true,
                    fillColor: AppTheme.lightTheme.cardTheme.color,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSending ? null : _sendCobic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: isSending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Gửi', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardTheme.color,
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
                          'Lịch sử giao dịch',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.white70))),
                    )
                  else ...pagedTransactions.map((item) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
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
                              item['type'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
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
                            item['description'] ?? '',
                            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['timestamp'] != null ? item['timestamp'].toString() : '',
                            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 13),
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
                          backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(_currentPage > 0 && !_isLoadingHistory ? 1 : 0.4),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.white24,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: const Text('Trang trước', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: ((_currentPage + 1) * _pageSize < allTransactions.length) && !_isLoadingHistory ? _nextPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(((_currentPage + 1) * _pageSize < allTransactions.length) && !_isLoadingHistory ? 1 : 0.4),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.white24,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: const Text('Trang sau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trang ${_currentPage + 1} / ${(allTransactions.isEmpty ? 1 : (allTransactions.length / _pageSize).ceil())}',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
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