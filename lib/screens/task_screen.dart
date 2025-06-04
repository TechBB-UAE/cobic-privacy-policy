import 'package:cobic/widgets/language_switch_button.dart';
import 'package:cobic/theme/custom_app_bar.dart';
import 'package:cobic/screens/scan_qr_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  // ... (existing code)
}

class _TaskScreenState extends State<TaskScreen> {
  // ... (existing code)

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        titleText: l10n.tasks,
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
          const LanguageSwitchButton(),
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
      // ... (rest of the existing code)
    );
  }
} 