import '../../models/app_scan_result.dart';
import '../../models/risk_level.dart';
import '../../core/constants/app_constants.dart';
import '../platform_security_service.dart';

class InstalledAppScanner {
  /// Scan all installed apps on the device and classify their risks
  static Future<List<AppScanResult>> scanAllApps() async {
    final rawApps = await PlatformSecurityService.getInstalledApps();
    final results = <AppScanResult>[];

    for (final raw in rawApps) {
      final appResult = _analyzePackage(raw);
      results.add(appResult);
    }

    // Sort by risk priority (critical first, then high, medium, low, safe)
    results.sort((a, b) => a.riskLevel.sortOrder.compareTo(b.riskLevel.sortOrder));
    return results;
  }

  static AppScanResult _analyzePackage(Map<String, dynamic> raw) {
    final appName = raw['appName'] as String? ?? 'Noma\'lum ilova';
    final packageName = raw['packageName'] as String? ?? '';
    final versionName = raw['versionName'] as String? ?? '1.0.0';
    final versionCode = raw['versionCode'] as int? ?? 1;
    final installerPackage = raw['installerPackage'] as String?;
    final isSystemApp = raw['isSystemApp'] as bool? ?? false;
    final targetSdkVersion = raw['targetSdkVersion'] as int? ?? 33;
    final minSdkVersion = raw['minSdkVersion'] as int? ?? 21;
    final rawPermissions = (raw['requestedPermissions'] as List<dynamic>?)?.cast<String>() ?? [];
    final signingCertHash = raw['signingCertHash'] as String?;
    final installTime = raw['firstInstallTime'] as int? ?? 0;
    final updateTime = raw['lastUpdateTime'] as int? ?? 0;

    final dangerousPermissions = rawPermissions.where((perm) =>
        AppConstants.highRiskPermissions.contains(perm)).toList();

    final findings = <SecurityFinding>[];

    // 1. Accessibility Service Check (Critical capability in malware)
    if (rawPermissions.contains('android.permission.BIND_ACCESSIBILITY_SERVICE')) {
      findings.add(SecurityFinding(
        title: "Maxsus imkoniyatlar (Accessibility) ruxsati",
        description: "Ilova ekrandagi barcha ma'lumotlarni o'qish va foydalanuvchi nomidan tugmalarni bosish huquqiga ega.",
        evidence: "android.permission.BIND_ACCESSIBILITY_SERVICE aniqlandi",
        severity: isSystemApp ? RiskLevel.low : RiskLevel.high,
        category: "Imtiyozlarni suiiste'mol qilish",
        confirmed: true,
        recommendation: "Agar bu ilova bank yoki maxsus yordamchi ilova bo'lmasa, ushbu ruxsatni darhol o'chirib qo'ying.",
      ));
    }

    // 2. Device Admin Check
    if (rawPermissions.contains('android.permission.BIND_DEVICE_ADMIN')) {
      findings.add(SecurityFinding(
        title: "Qurilma ma'muri (Device Admin) imtiyozi",
        description: "Ilova qurilmani qulflash, parollarni o'zgartirish va o'chirishni taqiqlash huquqiga ega bo'lishi mumkin.",
        evidence: "android.permission.BIND_DEVICE_ADMIN so'ralgan",
        severity: isSystemApp ? RiskLevel.safe : RiskLevel.high,
        category: "Tizim boshqaruvi",
        confirmed: true,
        recommendation: "Ilova ishonchli kompaniyaga tegishli ekanligiga ishonch hosil qiling.",
      ));
    }

    // 3. Sensitive Spyware Combination: SMS + Internet
    final hasSms = rawPermissions.any((p) => p.contains('SMS'));
    final hasInternet = rawPermissions.contains('android.permission.INTERNET');
    if (hasSms && hasInternet && !isSystemApp) {
      final isKnownSmsApp = packageName.contains('messaging') ||
          packageName.contains('sms') ||
          packageName.contains('mms');

      if (!isKnownSmsApp) {
        findings.add(SecurityFinding(
          title: "SMS va Internet ruxsati kombinatsiyasi",
          description: "Ilova kiruvchi va chiquvchi SMSlarni o'qib, ularni internet orqali tashqi serverga yuborish imkoniyatiga ega.",
          evidence: "READ_SMS/RECEIVE_SMS va INTERNET ruxsatlari bir vaqtda so'ralgan",
          severity: RiskLevel.medium,
          category: "Maxfiylik va moliyaviy xavf",
          confirmed: false,
          recommendation: "Bank tasdiqlash kodlari (OTP) ushbu ilova tomonidan o'qilishi xavfi mavjudligini ko'rib chiqing.",
        ));
      }
    }

    // 4. Notification Listener (Can read OTPs from push notifications)
    if (rawPermissions.contains('android.permission.BIND_NOTIFICATION_LISTENER_SERVICE')) {
      findings.add(SecurityFinding(
        title: "Bildirishnomalarni to'liq o'qish ruxsati",
        description: "Boshqa barcha ilovalarning (jumladan bank va Telegram) bildirishnomalarini o'qiy oladi.",
        evidence: "android.permission.BIND_NOTIFICATION_LISTENER_SERVICE mavjud",
        severity: isSystemApp ? RiskLevel.safe : RiskLevel.medium,
        category: "Maxfiylik",
        confirmed: true,
        recommendation: "Faqat aqlli soat va bildirishnoma menejerlariga ruxsat bering.",
      ));
    }

    // 5. Overlay + Install Packages (Phishing / Dropper technique)
    final hasOverlay = rawPermissions.contains('android.permission.SYSTEM_ALERT_WINDOW');
    final hasInstall = rawPermissions.contains('android.permission.REQUEST_INSTALL_PACKAGES');
    if (hasOverlay && hasInstall && !isSystemApp) {
      findings.add(SecurityFinding(
        title: "Soxta oyna (Overlay) va yangi ilova o'rnatish",
        description: "Ilova boshqa ilovalarning ustiga soxta login oynalarini chiqarishi va yangi ilovalarni o'rnatishga urinishi mumkin.",
        evidence: "SYSTEM_ALERT_WINDOW va REQUEST_INSTALL_PACKAGES birgalikda",
        severity: RiskLevel.high,
        category: "Trojan xususiyatlari",
        confirmed: false,
        recommendation: "Ilova manbasini va zaruriyatini tekshiring.",
      ));
    }

    // 6. Unknown Installer Source
    final isTrustedSource = installerPackage != null &&
        AppConstants.trustedInstallers.contains(installerPackage);

    if (!isSystemApp && !isTrustedSource) {
      findings.add(SecurityFinding(
        title: "Noma'lum manbadan o'rnatilgan",
        description: "Ilova rasmiy Google Play yoki boshqa tasdiqlangan do'kondan o'rnatilmagan (brauzer, Telegram yoki fayl menejer orqali o'rnatilgan bo'lishi mumkin).",
        evidence: "O'rnatuvchi: ${installerPackage ?? "Noma'lum manba (APK fayl)"}",
        severity: RiskLevel.low,
        category: "O'rnatish manbasi",
        confirmed: true,
        recommendation: "Rasmiy do'kondan tashqari olingan ilovalarning xavfsizligini alohida tekshiring.",
      ));
    }

    // 7. Outdated Target SDK (Bypassing modern Android security restrictions)
    if (targetSdkVersion < 28 && !isSystemApp) {
      findings.add(SecurityFinding(
        title: "Eski Android xavfsizlik standarti (Target SDK: $targetSdkVersion)",
        description: "Ilova zamonaviy Android xavfsizlik cheklovlari va ruxsatlar tizimidan qochish uchun eski API darajasiga mo'ljallangan bo'lishi mumkin.",
        evidence: "Target SDK $targetSdkVersion (tavsiya etilgan: 33+)",
        severity: RiskLevel.low,
        category: "Arxitektura zaifligi",
        confirmed: true,
        recommendation: "Ilovani yangilash yoki zamonaviyroq muqobiliga almashtirish tavsiya etiladi.",
      ));
    }

    // Determine final RiskLevel
    RiskLevel finalRisk = RiskLevel.safe;
    if (findings.any((f) => f.severity == RiskLevel.critical)) {
      finalRisk = RiskLevel.critical;
    } else if (findings.any((f) => f.severity == RiskLevel.high)) {
      finalRisk = RiskLevel.high;
    } else if (findings.where((f) => f.severity == RiskLevel.medium).length >= 2) {
      finalRisk = RiskLevel.high;
    } else if (findings.any((f) => f.severity == RiskLevel.medium)) {
      finalRisk = RiskLevel.medium;
    } else if (findings.any((f) => f.severity == RiskLevel.low)) {
      finalRisk = RiskLevel.low;
    } else if (dangerousPermissions.length > 5) {
      finalRisk = RiskLevel.low;
    }

    return AppScanResult(
      appName: appName,
      packageName: packageName,
      versionName: versionName,
      versionCode: versionCode,
      installerPackage: installerPackage,
      requestedPermissions: rawPermissions,
      dangerousPermissions: dangerousPermissions,
      riskLevel: finalRisk,
      findings: findings,
      scanTime: DateTime.now(),
      scanComplete: true,
      targetSdkVersion: targetSdkVersion,
      minSdkVersion: minSdkVersion,
      isSystemApp: isSystemApp,
      signingCertHash: signingCertHash,
      installTimeMs: installTime,
      updateTimeMs: updateTime,
    );
  }
}
