import 'dart:convert';
import 'dart:io';
import '../services/gemini_service.dart';

class ArbTranslator {
  static Future<void> translateArbFile({
    required String sourceFile,
    required String targetFile,
    required String targetLanguage,
  }) async {
    print('Starting translation process...');
    print('Source file: $sourceFile');
    print('Target file: $targetFile');
    print('Target language: $targetLanguage');

    // Đọc file nguồn
    final sourceContent = File(sourceFile).readAsStringSync();
    final Map<String, dynamic> sourceData = json.decode(sourceContent);
    
    // Đọc file đích nếu tồn tại
    Map<String, dynamic> targetData = {};
    if (File(targetFile).existsSync()) {
      final targetContent = File(targetFile).readAsStringSync();
      targetData = json.decode(targetContent);
    }

    int totalStrings = sourceData.length;
    int translatedStrings = 0;
    int skippedStrings = 0;

    // Dịch các chuỗi mới
    for (final entry in sourceData.entries) {
      if (entry.value is String) {
        if (!targetData.containsKey(entry.key)) {
          try {
            print('\nTranslating: "${entry.key}"');
            print('Original text: "${entry.value}"');
            
            final translatedText = await GeminiService.translateText(
              entry.value,
              targetLanguage
            );
            
            print('Translated text: "$translatedText"');
            
            targetData[entry.key] = translatedText;
            translatedStrings++;
            
            // Lưu sau mỗi lần dịch thành công
            File(targetFile).writeAsStringSync(
              json.encode(targetData),
              flush: true,
            );
            
            // Delay 1 giây để tránh vượt quá giới hạn API
            await Future.delayed(const Duration(seconds: 1));
          } catch (e) {
            print('Error translating "${entry.key}": $e');
          }
        } else {
          skippedStrings++;
        }
      } else {
        // Giữ nguyên các giá trị không phải string
        targetData[entry.key] = entry.value;
      }
    }

    print('\nTranslation completed!');
    print('Total strings: $totalStrings');
    print('Translated strings: $translatedStrings');
    print('Skipped strings: $skippedStrings');
  }
} 