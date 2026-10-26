import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Map<String, double> ratesToUzs = {
    'UZS': 1.0,
    'USD': 12850.0,
    'EUR': 13950.0,
    'RUB': 135.0,
    'GBP': 16700.0,
    'KZT': 26.5,
  };

  static bool isLiveLoaded = false;
  static String lastUpdated = "Standart kurslar";

  static Future<bool> fetchLiveRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/USD'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        if (rates.containsKey('UZS')) {
          final double uzsPerUsd = (rates['UZS'] as num).toDouble();
          final double eurPerUsd = (rates['EUR'] as num?)?.toDouble() ?? 0.92;
          final double rubPerUsd = (rates['RUB'] as num?)?.toDouble() ?? 95.0;
          final double gbpPerUsd = (rates['GBP'] as num?)?.toDouble() ?? 0.77;
          final double kztPerUsd = (rates['KZT'] as num?)?.toDouble() ?? 485.0;

          ratesToUzs['USD'] = uzsPerUsd;
          ratesToUzs['EUR'] = uzsPerUsd / (eurPerUsd > 0 ? eurPerUsd : 1.0);
          ratesToUzs['RUB'] = uzsPerUsd / (rubPerUsd > 0 ? rubPerUsd : 1.0);
          ratesToUzs['GBP'] = uzsPerUsd / (gbpPerUsd > 0 ? gbpPerUsd : 1.0);
          ratesToUzs['KZT'] = uzsPerUsd / (kztPerUsd > 0 ? kztPerUsd : 1.0);

          isLiveLoaded = true;
          final now = DateTime.now();
          lastUpdated = "Jonli kurs (${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')})";
          return true;
        }
      }
    } catch (_) {
      // Tarmoqda xato bo'lsa zaxira oflayn kurslar ishlatiladi
    }
    return false;
  }
}
