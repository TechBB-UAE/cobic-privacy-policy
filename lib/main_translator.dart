import 'utils/arb_translator.dart';

void main() async {
  try {
    await ArbTranslator.translateArbFile(
      sourceFile: 'lib/l10n/app_en.arb',
      targetFile: 'lib/l10n/app_vi.arb',
      targetLanguage: 'Vietnamese',
    );
  } catch (e) {
    print('Error running translator: $e');
  }
} 