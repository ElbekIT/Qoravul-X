import 'package:flutter_test/flutter_test.dart';
import 'package:qoravul_x/models/risk_level.dart';
import 'package:qoravul_x/services/threat_intel/threat_intelligence_service.dart';
import 'package:qoravul_x/services/url_scanner/url_phishing_scanner.dart';

void main() {
  group('URL Phishing Scanner Tests', () {
    test('Detects IP-address based URLs as High Risk', () async {
      final result = await UrlPhishingScanner.scanUrl('http://192.168.1.1/login');
      expect(result.riskLevel, isNot(RiskLevel.safe));
      expect(result.findings.any((f) => f.title.contains('IP manzil')), isTrue);
    });

    test('Detects Cyrillic Homograph attack in domain as Critical Risk', () async {
      // Lookalike 'а' (Cyrillic \u0430 instead of Latin a)
      final result = await UrlPhishingScanner.scanUrl('https://p\u0430yme.uz');
      expect(result.riskLevel, equals(RiskLevel.critical));
      expect(result.findings.any((f) => f.title.contains('Homografiya')), isTrue);
    });

    test('Detects blacklisted phishing domains', () {
      final check = ThreatIntelligenceService.checkDomain('uzcard-verify.com', 'https://uzcard-verify.com');
      expect(check.isDangerous, isTrue);
      expect(check.isPhishing, isTrue);
    });

    test('Legitimate official domains pass clean', () {
      final check = ThreatIntelligenceService.checkDomain('payme.uz', 'https://payme.uz');
      expect(check.isDangerous, isFalse);
    });
  });

  group('Threat Intelligence Hash Tests', () {
    test('Matches known banking trojan hash', () async {
      final res = await ThreatIntelligenceService.checkHash(
        '8d49a7bc2174366e74e64f891b94d1f2e13d9876543210abcdef0123456789ab',
      );
      expect(res.isMalicious, isTrue);
      expect(res.threatName, contains('Anatsa'));
    });

    test('Clean hash returns non-malicious', () async {
      final res = await ThreatIntelligenceService.checkHash(
        '0000000000000000000000000000000000000000000000000000000000000000',
      );
      expect(res.isMalicious, isFalse);
    });
  });
}
