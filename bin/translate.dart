import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiKey = 'AIzaSyAtZNR3yShK2lO9E5XQT3MbWdEXhSOaapo'; // Thay thế bằng API key của bạn

Future<String> translateText(String text, String targetLanguage, {int retryCount = 0}) async {
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Translate the following text to $targetLanguage. Only return the translated text, no explanation: "$text"'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else if (response.statusCode == 429 && retryCount < 3) {
      // Rate limit error, wait and retry
      print('Rate limit reached, waiting 30 seconds before retry...');
      await Future.delayed(const Duration(seconds: 30));
      return translateText(text, targetLanguage, retryCount: retryCount + 1);
    } else {
      throw Exception('Failed to translate: ${response.body}');
    }
  } catch (e) {
    if (retryCount < 3) {
      print('Error occurred, retrying in 30 seconds...');
      await Future.delayed(const Duration(seconds: 30));
      return translateText(text, targetLanguage, retryCount: retryCount + 1);
    }
    throw Exception('Error calling Gemini API: $e');
  }
}

Future<void> main() async {
  try {
    print('Starting translation process...');
    
    // Đọc file nguồn
    final sourceFile = File('lib/l10n/app_en.arb');
    final sourceContent = sourceFile.readAsStringSync();
    final Map<String, dynamic> sourceData = json.decode(sourceContent);
    
    // Đọc file đích nếu tồn tại
    final targetFile = File('lib/l10n/app_vi.arb');
    Map<String, dynamic> targetData = {};
    if (targetFile.existsSync()) {
      final targetContent = targetFile.readAsStringSync();
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
            
            final translatedText = await translateText(
              entry.value,
              'Vietnamese'
            );
            
            print('Translated text: "$translatedText"');
            
            targetData[entry.key] = translatedText;
            translatedStrings++;
            
            // Lưu sau mỗi lần dịch thành công
            targetFile.writeAsStringSync(
              json.encode(targetData),
              flush: true,
            );
            
            // Delay 3 giây để tránh vượt quá giới hạn API
            await Future.delayed(const Duration(seconds: 3));
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
  } catch (e) {
    print('Error running translator: $e');
  }
} 