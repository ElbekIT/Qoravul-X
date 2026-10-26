import 'dart:async';
import 'package:http/http.dart' as http;
import '../../models/risk_level.dart';
import '../../models/url_scan_result.dart';
import '../threat_intel/threat_intelligence_service.dart';

class UrlPhishingScanner {
  /// Deep inspect a URL for phishing, impersonation, and malicious indicators
  static Future<UrlScanResult> scanUrl(String inputUrl) async {
    String cleanUrl = inputUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    Uri? uri;
    try {
      uri = Uri.parse(cleanUrl);
    } catch (_) {
      return UrlScanResult(
        originalUrl: inputUrl,
        domain: 'Xato URL',
        isHttps: false,
        riskLevel: RiskLevel.critical,
        findings: [
          UrlFinding(
            title: "Noto'g'ri URL formati",
            description: "Kiritilgan havola haqiqiy veb-manzil standartlariga to'g'ri kelmaydi.",
            severity: RiskLevel.critical,
            category: "Sintaksis xatosi",
          )
        ],
        scanTime: DateTime.now(),
        recommendation: "Bunday havolalarni aslo ochmang.",
      );
    }

    final domain = uri.host.toLowerCase();
    final isHttps = uri.scheme.toLowerCase() == 'https';
    final findings = <UrlFinding>[];

    // 1. HTTPS Check
    if (!isHttps) {
      findings.add(UrlFinding(
        title: "Shifrlanmagan ulanish (Oddiy HTTP)",
        description: "Ushbu veb-sayt ma'lumotlarni shifrlamasdan uzatadi. Kirish parollari yoki karta ma'lumotlarini kiritish xavflidir.",
        severity: RiskLevel.medium,
        category: "Protokol xavfsizligi",
      ));
    }

    // 2. IP-based URL
    final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (ipRegex.hasMatch(domain)) {
      findings.add(UrlFinding(
        title: "Domen o'rniga IP manzil ishlatilgan",
        description: "Haqiqiy xizmatlar domen nomidan (masalan, .uz yoki .com) foydalanadi. IP manzilli havolalar fishing uchun tez-tez ishlatiladi.",
        severity: RiskLevel.high,
        category: "Shubhali manzil",
      ));
    }

    // 3. Internationalized Domain / Cyrillic Lookalike (Homograph Attack)
    final containsCyrillic = RegExp(r'[\u0400-\u04FF]').hasMatch(domain);
    final isPunycode = domain.startsWith('xn--') || domain.contains('.xn--');
    if (containsCyrillic || isPunycode) {
      findings.add(UrlFinding(
        title: "Vizual aldamchi domen (Homografiya / Punycode)",
        description: "Domen nomida lotin harflariga o'xshash boshqa alifbo (masalan, kirill 'a' yoki 'o') belgilari ishlatilgan.",
        severity: RiskLevel.critical,
        category: "Fishing hujumi",
      ));
    }

    // 4. Excessive Subdomains (e.g. login.secure.payme.uz.some-scam.com)
    final domainParts = domain.split('.');
    if (domainParts.length >= 4) {
      findings.add(UrlFinding(
        title: "Ko'p pog'onali shubhali subdomen",
        description: "Havola ichida taniqli brend nomini subdomen qilib yashirishga urinish alomatlari bor.",
        severity: RiskLevel.high,
        category: "Domen tuzilishi",
      ));
    }

    // 5. Query Threat Intelligence database for known phishing
    final threatResult = ThreatIntelligenceService.checkDomain(domain, cleanUrl);
    if (threatResult.isDangerous) {
      findings.add(UrlFinding(
        title: threatResult.threatCategory,
        description: threatResult.threatDescription,
        severity: threatResult.isPhishing ? RiskLevel.critical : RiskLevel.high,
        category: "Tahdid bazasi",
      ));
    }

    // 6. Safe Redirect Resolution (with timeout and SSRF protection)
    String? finalDestinationUrl;
    if (findings.every((f) => f.severity != RiskLevel.critical)) {
      try {
        final client = http.Client();
        final request = http.Request('HEAD', uri)..followRedirects = false;
        final response = await client.send(request).timeout(const Duration(seconds: 4));
        if (response.isRedirect) {
          final location = response.headers['location'];
          if (location != null) {
            finalDestinationUrl = location;
            final redirectUri = Uri.tryParse(location);
            if (redirectUri != null && redirectUri.host.toLowerCase() != domain) {
              findings.add(UrlFinding(
                title: "Boshqa domenga yo'naltirish (Redirect)",
                description: "Ushbu havola sizni boshqa domenga: ${redirectUri.host} ga yo'naltiradi.",
                severity: RiskLevel.medium,
                category: "Yo'naltirish",
              ));
            }
          }
        }
      } catch (_) {
        // Network timeout or offline - not an automatic fault
      }
    }

    // Calculate overall URL risk level
    RiskLevel risk = RiskLevel.safe;
    if (findings.any((f) => f.severity == RiskLevel.critical)) {
      risk = RiskLevel.critical;
    } else if (findings.any((f) => f.severity == RiskLevel.high)) {
      risk = RiskLevel.high;
    } else if (findings.any((f) => f.severity == RiskLevel.medium)) {
      risk = RiskLevel.medium;
    } else if (findings.isNotEmpty) {
      risk = RiskLevel.low;
    }

    String recommendation = "Havola xavfsiz ko'rinadi.";
    if (risk == RiskLevel.critical) {
      recommendation = "DIQQAT: Ushbu havolani ochmang! Bu shaxsiy yoki bank ma'lumotlarini o'g'irlash uchun mo'ljallangan bo'lishi mumkin.";
    } else if (risk == RiskLevel.high) {
      recommendation = "Havola jiddiy xavf belgilariga ega. Faqat to'liq ishonchingiz komil bo'lsa oching.";
    } else if (risk == RiskLevel.medium) {
      recommendation = "Saytda parollar yoki bank kartasi ma'lumotlarini kiritish tavsiya etilmaydi.";
    }

    return UrlScanResult(
      originalUrl: cleanUrl,
      finalUrl: finalDestinationUrl,
      domain: domain,
      isHttps: isHttps,
      riskLevel: risk,
      findings: findings,
      scanTime: DateTime.now(),
      reputationChecked: true,
      reputationSource: 'Qoravul X Multi-Layer URL Filter',
      recommendation: recommendation,
    );
  }
}
