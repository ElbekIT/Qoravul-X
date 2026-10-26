import 'package:flutter/foundation.dart';
import '../models/app_scan_result.dart';
import '../models/device_security_info.dart';
import '../models/risk_level.dart';
import '../models/security_score.dart';
import '../models/url_scan_result.dart';
import '../models/apk_scan_result.dart';
import 'device_audit_service.dart';
import 'scanning/installed_app_scanner.dart';
import 'scoring/scoring_engine.dart';
import 'url_scanner/url_phishing_scanner.dart';
import 'scanning/apk_scanner_service.dart';

class SecurityProvider with ChangeNotifier {
  bool _isScanning = false;
  double _scanProgress = 0.0;
  String _currentScanAction = '';

  SecurityScore _score = SecurityScore.initial();
  List<AppScanResult> _installedApps = [];
  DeviceSecurityInfo? _deviceInfo;
  final List<UrlScanResult> _urlHistory = [];
  final List<ApkScanResult> _apkHistory = [];

  DateTime? _lastScanTime;

  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  String get currentScanAction => _currentScanAction;
  SecurityScore get score => _score;
  List<AppScanResult> get installedApps => _installedApps;
  DeviceSecurityInfo? get deviceInfo => _deviceInfo;
  List<UrlScanResult> get urlHistory => _urlHistory;
  List<ApkScanResult> get apkHistory => _apkHistory;
  DateTime? get lastScanTime => _lastScanTime;

  // Filtered lists
  List<AppScanResult> get dangerousApps => _installedApps.where((app) =>
      app.riskLevel == RiskLevel.critical ||
      app.riskLevel == RiskLevel.high ||
      app.riskLevel == RiskLevel.medium).toList();

  List<AppScanResult> get criticalApps => _installedApps.where((app) =>
      app.riskLevel == RiskLevel.critical).toList();

  List<AppScanResult> get highRiskApps => _installedApps.where((app) =>
      app.riskLevel == RiskLevel.high).toList();

  List<AppScanResult> get mediumRiskApps => _installedApps.where((app) =>
      app.riskLevel == RiskLevel.medium).toList();

  List<AppScanResult> get lowRiskApps => _installedApps.where((app) =>
      app.riskLevel == RiskLevel.low).toList();

  List<AppScanResult> get safeApps => _installedApps.where((app) =>
      app.riskLevel == RiskLevel.safe).toList();

  /// Perform a full phone security scan
  Future<void> performFullScan() async {
    _isScanning = true;
    _scanProgress = 0.05;
    _currentScanAction = "Qurilma sozlamalari va xavfsizlik darajasi tekshirilmoqda...";
    notifyListeners();

    try {
      // 1. Device posture audit
      _deviceInfo = await DeviceAuditService.auditDevice();
      _scanProgress = 0.25;
      _currentScanAction = "O'rnatilgan ilovalar ro'yxati olinmoqda...";
      notifyListeners();

      // 2. Scan installed applications
      _installedApps = await InstalledAppScanner.scanAllApps();
      _scanProgress = 0.70;
      _currentScanAction = "Ruxsatlar va tahdidlar tahlili o'tkazilmoqda...";
      notifyListeners();

      // 3. Count malicious URLs found so far
      final maliciousUrlCount = _urlHistory.where((u) =>
          u.riskLevel == RiskLevel.critical || u.riskLevel == RiskLevel.high).length;

      _scanProgress = 0.90;
      _currentScanAction = "Xavfsizlik indeksi hisoblanmoqda...";
      notifyListeners();

      // 4. Calculate final score via ScoringEngine
      _score = ScoringEngine.evaluate(
        installedApps: _installedApps,
        deviceInfo: _deviceInfo,
        urlChecksCount: _urlHistory.length,
        maliciousUrlsFound: maliciousUrlCount,
        isScanComplete: true,
      );

      _lastScanTime = DateTime.now();
      _scanProgress = 1.0;
      _currentScanAction = "Tekshiruv muvaffaqiyatli yakunlandi";
    } catch (e) {
      _currentScanAction = "Xatolik yuz berdi: $e";
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Scan a specific APK file and add to history
  Future<ApkScanResult> scanApkFile(String filePath) async {
    final result = await ApkScannerService.scanApkFile(filePath);
    _apkHistory.insert(0, result);
    notifyListeners();
    return result;
  }

  /// Scan a URL and update history & scoring
  Future<UrlScanResult> scanUrl(String url) async {
    final result = await UrlPhishingScanner.scanUrl(url);
    _urlHistory.insert(0, result);

    // Re-evaluate score if apps were already scanned
    if (_installedApps.isNotEmpty) {
      final maliciousUrlCount = _urlHistory.where((u) =>
          u.riskLevel == RiskLevel.critical || u.riskLevel == RiskLevel.high).length;

      _score = ScoringEngine.evaluate(
        installedApps: _installedApps,
        deviceInfo: _deviceInfo,
        urlChecksCount: _urlHistory.length,
        maliciousUrlsFound: maliciousUrlCount,
        isScanComplete: true,
      );
    }

    notifyListeners();
    return result;
  }
}
