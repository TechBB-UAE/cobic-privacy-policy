import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'profile/profile_screen.dart';
import 'mining_screen.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/mining_provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:cobic/screens/tasks/task_list_screen.dart';
import 'package:cobic/screens/wallet_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cobic/screens/referral_screen.dart';
import 'package:cobic/screens/scan_qr_screen.dart';
// TODO: import các màn hình khác (task, mining, wallet, referral)

class MainTabScreen extends StatefulWidget {
  final int initialTab;
  const MainTabScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _currentIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<String> _titles = [
    'Cá nhân',
    'Nhiệm vụ',
    'Khai thác',
    'Ví',
    'Giới thiệu',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_currentIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      // Nếu đang ở root tab, thoát app
      return true;
    }
    // Nếu không, pop màn hình con trong tab
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final miningProvider = Provider.of<MiningProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final currentNavigator = _navigatorKeys[_currentIndex].currentState;
    bool showAppBar = true;
    if (currentNavigator != null && currentNavigator.canPop()) {
      showAppBar = false;
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Navigator(
              key: _navigatorKeys[0],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => ProfileScreen(navigatorKey: _navigatorKeys[0]),
                settings: const RouteSettings(name: '/profile'),
              ),
            ),
            Navigator(
              key: _navigatorKeys[1],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => TaskListScreen(),
              ),
            ),
            Navigator(
              key: _navigatorKeys[2],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => MiningScreen(
                  miningRate: double.tryParse(profileProvider.miningRate) ?? 0.0,
                  miningStatus: miningProvider.canMine ? 'Sẵn sàng đào!' : 'Đang đếm ngược...',
                  dailyCheckinStatus: miningProvider.canMine ? 'Cần điểm danh' : 'Đã điểm danh',
                  canMine: miningProvider.canMine,
                  nextMiningTime: miningProvider.nextMiningTime,
                  onMine: miningProvider.canMine ? () async {
                    final token = await const FlutterSecureStorage().read(key: 'token');
                    if (token != null) {
                      await miningProvider.dailyCheckIn(token);
                      await profileProvider.fetchUserInfo();
                    }
                  } : null,
                  onScanQR: () async {
                    await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const ScanQrScreen(targetRoute: '/home')),
                    );
                  },
                ),
              ),
            ),
            Navigator(
              key: _navigatorKeys[3],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => const WalletScreen(),
              ),
            ),
            Navigator(
              key: _navigatorKeys[4],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => ReferralScreen(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
            primaryColor: AppTheme.lightTheme.primaryColor,
            textTheme: Theme.of(context).textTheme.copyWith(
              bodySmall: const TextStyle(color: Colors.white),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
              BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Nhiệm vụ'),
              BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Khai thác'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Ví'),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Giới thiệu'),
            ],
          ),
        ),
      ),
    );
  }
} 