import 'dart:math' as math;
import '../../models/app_scan_result.dart';
import '../../models/device_security_info.dart';
import '../../models/risk_level.dart';
import '../../models/security_score.dart';
import '../../core/constants/app_constants.dart';

class ScoringEngine {
  /// Calculate comprehensive security score based on actual inspection data
  static SecurityScore evaluate({
    required List<AppScanResult> installedApps,
    required DeviceSecurityInfo? deviceInfo,
    required int urlChecksCount,
    required int maliciousUrlsFound,
    required bool isScanComplete,
  }) {
    final components = <ScoreComponent>[];
    int totalChecks = 0;
    int completedChecks = 0;

    // ==========================================
    // 1. INSTALLED APPLICATION SECURITY (Max: 100)
    // ==========================================
    totalChecks += 4;
    int appSecurityDeductions = 0;
    final List<String> appEvidences = [];

    final confirmedMaliciousApps = installedApps.where((a) =>
        a.riskLevel == RiskLevel.critical ||
        a.findings.any((f) => f.confirmed && f.severity == RiskLevel.critical)).toList();

    final highRiskApps = installedApps.where((a) =>
        a.riskLevel == RiskLevel.high).toList();

    final mediumRiskApps = installedApps.where((a) =>
        a.riskLevel == RiskLevel.medium).toList();

    final unknownSourceApps = installedApps.where((a) =>
        !a.isSystemApp &&
        (a.installerPackage == null || !AppConstants.trustedInstallers.contains(a.installerPackage))).toList();

    if (confirmedMaliciousApps.isNotEmpty) {
      final deduction = math.min(50, confirmedMaliciousApps.length * 25);
      appSecurityDeductions += deduction;
      appEvidences.add('${confirmedMaliciousApps.length} ta tasdiqlangan xavfli ilova topildi (-$deduction ball)');
    }

    if (highRiskApps.isNotEmpty) {
      final deduction = math.min(30, highRiskApps.length * 10);
      appSecurityDeductions += deduction;
      appEvidences.add('${highRiskApps.length} ta yuqori xavfli ilova topildi (-$deduction ball)');
    }

    if (mediumRiskApps.isNotEmpty) {
      final deduction = math.min(15, mediumRiskApps.length * 3);
      appSecurityDeductions += deduction;
      appEvidences.add('${mediumRiskApps.length} ta o\'rtacha xavfli ilova (-$deduction ball)');
    }

    if (unknownSourceApps.length > 5) {
      final deduction = math.min(15, (unknownSourceApps.length - 5) * 2);
      appSecurityDeductions += deduction;
      appEvidences.add('${unknownSourceApps.length} ta ilova noma\'lum manbalardan o\'rnatilgan (-$deduction ball)');
    }

    completedChecks += 4;
    final appSecurityScore = math.max(0, 100 - appSecurityDeductions);
    components.add(ScoreComponent(
      name: "O'rnatilgan ilovalar xavfsizligi",
      description: "Qurilmadagi ilovalarning xulq-atvori, imzolari va xavf darajalari tahlili",
      pointsDeducted: appSecurityDeductions,
      maxPoints: 100,
      category: 'apps',
      evidence: appEvidences.isEmpty ? "Xavfli yoki zararli ilovalar aniqlanmadi" : appEvidences.join('; '),
    ));

    // ==========================================
    // 2. PERMISSION AND PRIVACY SECURITY (Max: 100)
    // ==========================================
    totalChecks += 4;
    int permDeductions = 0;
    final List<String> permEvidences = [];

    // Count apps with Accessibility services or sensitive admin rights
    final accessibilityApps = installedApps.where((a) =>
        !a.isSystemApp &&
        a.requestedPermissions.contains('android.permission.BIND_ACCESSIBILITY_SERVICE')).toList();

    final deviceAdminApps = installedApps.where((a) =>
        !a.isSystemApp &&
        a.requestedPermissions.contains('android.permission.BIND_DEVICE_ADMIN')).toList();

    final smsSpyCandidateApps = installedApps.where((a) =>
        !a.isSystemApp &&
        a.requestedPermissions.contains('android.permission.READ_SMS') &&
        a.requestedPermissions.contains('android.permission.INTERNET')).toList();

    final overlayApps = installedApps.where((a) =>
        !a.isSystemApp &&
        a.requestedPermissions.contains('android.permission.SYSTEM_ALERT_WINDOW')).toList();

    if (accessibilityApps.isNotEmpty) {
      final deduction = math.min(30, accessibilityApps.length * 15);
      permDeductions += deduction;
      permEvidences.add('${accessibilityApps.length} ta nostandart ilova Maxsus Imkoniyatlar (Accessibility) ruxsatiga ega (-$deduction ball)');
    }

    if (deviceAdminApps.isNotEmpty) {
      final deduction = math.min(25, deviceAdminApps.length * 15);
      permDeductions += deduction;
      permEvidences.add('${deviceAdminApps.length} ta uchinchi tomon ilovasi Qurilma Ma\'muri huquqini so\'ragan (-$deduction ball)');
    }

    if (smsSpyCandidateApps.length > 2) {
      final deduction = math.min(20, (smsSpyCandidateApps.length - 2) * 5);
      permDeductions += deduction;
      permEvidences.add('${smsSpyCandidateApps.length} ta ilova bir vaqtda SMS va Internet ruxsatiga ega (-$deduction ball)');
    }

    if (overlayApps.length > 3) {
      final deduction = math.min(15, (overlayApps.length - 3) * 3);
      permDeductions += deduction;
      permEvidences.add('${overlayApps.length} ta ilova boshqa oynalar ustidan chizish huquqiga ega (-$deduction ball)');
    }

    completedChecks += 4;
    final permissionPrivacyScore = math.max(0, 100 - permDeductions);
    components.add(ScoreComponent(
      name: "Ruxsatlar va maxfiylik auditi",
      description: "SMS, Mikrofon, Accessibility va ekran ustiga chizish kabi nozik ruxsatlar nazorati",
      pointsDeducted: permDeductions,
      maxPoints: 100,
      category: 'permissions',
      evidence: permEvidences.isEmpty ? "Xavfli ruxsat kombinatsiyalari aniqlanmadi" : permEvidences.join('; '),
    ));

    // ==========================================
    // 3. LINK AND PHISHING PROTECTION (Max: 100)
    // ==========================================
    totalChecks += 2;
    int linkDeductions = 0;
    final List<String> linkEvidences = [];

    if (maliciousUrlsFound > 0) {
      final deduction = math.min(50, maliciousUrlsFound * 25);
      linkDeductions += deduction;
      linkEvidences.add('$maliciousUrlsFound ta xavfli/fishing havolasi qayd etilgan (-$deduction ball)');
    }

    if (urlChecksCount == 0) {
      // Missing check indicator
      linkDeductions += 10;
      linkEvidences.add("Hali havolalar skaneri ishlatilmagan (boshlang'ich -10 ball)");
    } else {
      linkEvidences.add('$urlChecksCount ta havola xavfsizlik filtridan o\'tkazilgan');
    }

    completedChecks += 2;
    final linkProtectionScore = math.max(0, 100 - linkDeductions);
    components.add(ScoreComponent(
      name: "Havolalar va fishingdan himoya",
      description: "Brauzer va messenjerlar orqali keluvchi soxta/fishing saytlar monitoringi",
      pointsDeducted: linkDeductions,
      maxPoints: 100,
      category: 'links',
      evidence: linkEvidences.join('; '),
    ));

    // ==========================================
    // 4. SYSTEM CONFIGURATION SECURITY (Max: 100)
    // ==========================================
    totalChecks += 5;
    int systemDeductions = 0;
    final List<String> sysEvidences = [];

    if (deviceInfo != null) {
      completedChecks += 5;

      // 1. Root check
      if (deviceInfo.isRooted) {
        systemDeductions += 35;
        sysEvidences.add("Qurilmada Root (superuser) huquqlari aniqlandi (-35 ball)");
      }

      // 2. Security patch age
      if (deviceInfo.securityPatchLevel == null) {
        systemDeductions += 15;
        sysEvidences.add("Xavfsizlik patchi sanasi aniqlanmadi (-15 ball)");
      } else {
        final age = deviceInfo.patchAgeMonths;
        if (age > 12) {
          systemDeductions += 25;
          sysEvidences.add("Xavfsizlik yangilanishi 1 yildan eski (-25 ball)");
        } else if (age > 6) {
          systemDeductions += 15;
          sysEvidences.add("Xavfsizlik yangilanishi 6 oydan eski (-15 ball)");
        } else if (age > 3) {
          systemDeductions += 5;
          sysEvidences.add("Xavfsizlik yangilanishi 3 oydan eski (-5 ball)");
        }
      }

      // 3. USB Debugging
      if (deviceInfo.usbDebuggingEnabled) {
        systemDeductions += 15;
        sysEvidences.add("USB orqali nosozliklarni tuzatish (ADB) yoqilgan (-15 ball)");
      }

      // 4. Developer options
      if (deviceInfo.developerOptionsEnabled && !deviceInfo.usbDebuggingEnabled) {
        systemDeductions += 5;
        sysEvidences.add("Dasturchi sozlamalari yoqilgan (-5 ball)");
      }

      // 5. Screen lock
      if (deviceInfo.screenLockCheckAvailable && !deviceInfo.screenLockEnabled) {
        systemDeductions += 20;
        sysEvidences.add("Ekran qulfi (PIN/Parol/Biometriya) o'rnatilmagan (-20 ball)");
      }
    } else {
      // Incomplete inspection
      systemDeductions += 30;
      sysEvidences.add("Tizim sozlamalari tekshiruvi yakunlanmagan (-30 ball)");
    }

    final systemConfigScore = math.max(0, 100 - systemDeductions);
    components.add(ScoreComponent(
      name: "Tizim va qurilma sozlamalari",
      description: "Root huquqlari, xavfsizlik yangilanishlari (patch), ADB va ekran himoyasi",
      pointsDeducted: systemDeductions,
      maxPoints: 100,
      category: 'system',
      evidence: sysEvidences.isEmpty ? "Tizim xavfsizlik sozlamalari me'yorida" : sysEvidences.join('; '),
    ));

    // ==========================================
    // OVERALL WEIGHTED SCORE (0 - 100)
    // ==========================================
    final weightedScore = (appSecurityScore * AppConstants.weightAppSecurity) +
        (permissionPrivacyScore * AppConstants.weightPermissionPrivacy) +
        (linkProtectionScore * AppConstants.weightLinkProtection) +
        (systemConfigScore * AppConstants.weightSystemConfig);

    final finalScore = weightedScore.round().clamp(0, 100);

    return SecurityScore(
      overallScore: finalScore,
      appSecurityScore: appSecurityScore,
      permissionPrivacyScore: permissionPrivacyScore,
      linkProtectionScore: linkProtectionScore,
      systemConfigScore: systemConfigScore,
      calculatedAt: DateTime.now(),
      checksCompleted: completedChecks,
      checksTotal: totalChecks,
      scanComplete: isScanComplete,
      components: components,
    );
  }
}
