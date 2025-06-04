import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('English'),
            trailing: languageProvider.isEnglish
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => languageProvider.setLocale(const Locale('en')),
          ),
          ListTile(
            title: const Text('Tiếng Việt'),
            trailing: languageProvider.isVietnamese
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => languageProvider.setLocale(const Locale('vi')),
          ),
        ],
      ),
    );
  }
} 