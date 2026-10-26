import 'risk_level.dart';

class UrlScanResult {
  final String originalUrl;
  final String? finalUrl;
  final String domain;
  final bool isHttps;
  final RiskLevel riskLevel;
  final List<UrlFinding> findings;
  final DateTime scanTime;
  final bool reputationChecked;
  final String? reputationSource;
  final String recommendation;

  UrlScanResult({
    required this.originalUrl,
    this.finalUrl,
    required this.domain,
    required this.isHttps,
    required this.riskLevel,
    required this.findings,
    required this.scanTime,
    this.reputationChecked = false,
    this.reputationSource,
    required this.recommendation,
  });
}

class UrlFinding {
  final String title;
  final String description;
  final RiskLevel severity;
  final String category;

  UrlFinding({
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
  });
}
