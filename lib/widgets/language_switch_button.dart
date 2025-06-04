import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: const Icon(Icons.language, color: Colors.black),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            final current = languageProvider.currentLanguage;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(
                  l10n.language,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    languageProvider.setLanguage('vi');
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                    child: Row(
                      children: [
                        const Text('🇻🇳', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        const Text('Tiếng Việt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (current == 'vi') const Icon(Icons.check, color: Colors.green)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    languageProvider.setLanguage('en');
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                    child: Row(
                      children: [
                        const Text('🇬🇧', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        const Text('English', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (current == 'en') const Icon(Icons.check, color: Colors.green)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
} 