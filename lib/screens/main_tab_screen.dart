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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            canvasColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).cardColor,
          ),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).cardColor,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            unselectedIconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profile),
              BottomNavigationBarItem(icon: const Icon(Icons.assignment), label: l10n.tasks),
              BottomNavigationBarItem(icon: const Icon(Icons.bolt), label: l10n.mining),
              BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet), label: l10n.wallet),
              BottomNavigationBarItem(icon: const Icon(Icons.group), label: l10n.referent),
            ],
          ),
        ),
      ),
    );
  }
} 