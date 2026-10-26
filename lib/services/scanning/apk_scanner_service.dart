import 'dart:io';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../models/apk_scan_result.dart';
import '../../models/app_scan_result.dart';
import '../../models/risk_level.dart';
import '../../core/constants/app_constants.dart';
import '../threat_intel/threat_intelligence_service.dart';

class ApkScannerService {
  static const MethodChannel _channel = MethodChannel('com.qoravulx.app/security');

  /// Scan an APK file by path and return complete analysis report
  static Future<ApkScanResult> scanApkFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("APK fayl topilmadi: $filePath");
    }

    final fileName = file.uri.pathSegments.last;
    final fileSizeBytes = await file.length();

    // 1. Calculate SHA-256 in background/chunked to prevent UI freeze
    final sha256Hash = await _calculateSha256(file);

    // 2. Query threat intelligence database for known malicious hash
    final threatCheck = await ThreatIntelligenceService.checkHash(sha256Hash);

    // 3. Inspect package info and certificate via native platform channel
    Map<String, dynamic>? nativeInfo;
    try {
      final res = await _channel.invokeMethod('analyzeApkFile', {'filePath': filePath});
      if (res is Map) {
        nativeInfo = Map<String, dynamic>.from(res);
      }
    } catch (_) {
      nativeInfo = null;
    }

    final packageName = nativeInfo?['packageName'] as String?;
    final versionName = nativeInfo?['versionName'] as String?;
    final versionCode = nativeInfo?['versionCode'] as int?;
    final targetSdk = nativeInfo?['targetSdkVersion'] as int?;
    final minSdk = nativeInfo?['minSdkVersion'] as int?;
    final rawPerms = (nativeInfo?['requestedPermissions'] as List<dynamic>?)?.cast<String>() ?? [];
    final signatureValid = nativeInfo?['signatureValid'] as bool? ?? false;
    final signerCertHash = nativeInfo?['signerCertHash'] as String?;

    final dangerousPerms = rawPerms.where((p) => AppConstants.highRiskPermissions.contains(p)).toList();
    final findings = <SecurityFinding>[];

    // Evaluate findings
    if (threatCheck.isMalicious) {
      findings.add(SecurityFinding(
        title: "Tasdiqlangan zararli dastur (Malware)",
        description: threatCheck.threatName ?? "Ma'lum tahdidlar bazasida aniqlangan zararli dastur.",
        evidence: "SHA-256: $sha256Hash (${threatCheck.source})",
        severity: RiskLevel.critical,
        category: "Ma'lum kiberxavf",
        confirmed: true,
        recommendation: "Ushbu faylni ASLO o'rnatmang va darhol o'chirib tashlang!",
      ));
    }

    if (!signatureValid) {
      findings.add(SecurityFinding(
        title: "APK raqamli imzosi yaroqsiz yoki mavjud emas",
        description: "Faylning yaxlitligi yoki haqiqiyligini tasdiqlab bo'lmadi. Bunday fayllar o'zgartirilgan bo'lishi mumkin.",
        evidence: "Imzo tekshiruvi: muvaffaqiyatsiz",
        severity: RiskLevel.high,
        category: "Raqamli imzo",
        confirmed: true,
        recommendation: "Faqat rasmiy va to'g'ri imzolangan APK larni o'rnating.",
      ));
    }

    if (rawPerms.contains('android.permission.BIND_ACCESSIBILITY_SERVICE')) {
      findings.add(SecurityFinding(
        title: "Maxsus imkoniyatlar (Accessibility) talabi",
        description: "Ushbu APK o'rnatilgach, ekranni boshqarish va parollarni o'g'irlash imkoniga ega bo'lishi mumkin.",
        evidence: "BIND_ACCESSIBILITY_SERVICE ruxsati topildi",
        severity: RiskLevel.high,
        category: "Xavfli huquqlar",
        confirmed: true,
        recommendation: "Dastur qanday maqsadga xizmat qilishini bilmasdan ruxsat bermang.",
      ));
    }

    if (rawPerms.any((p) => p.contains('SMS')) && rawPerms.contains('android.permission.INTERNET')) {
      findings.add(SecurityFinding(
        title: "SMS va Internet huquqi",
        description: "SMS orqali keluvchi bank xabarnomalari va OTP kodlarni yuborish imkoniyatiga ega.",
        evidence: "SMS va INTERNET ruxsatlari mavjud",
        severity: RiskLevel.medium,
        category: "Maxfiylik",
        confirmed: false,
        recommendation: "Telegram yoki noma'lum kanallardan olingan bo'lsa, xavfli bo'lishi mumkin.",
      ));
    }

    // Determine overall risk level
    RiskLevel finalRisk = RiskLevel.safe;
    if (threatCheck.isMalicious) {
      finalRisk = RiskLevel.critical;
    } else if (findings.any((f) => f.severity == RiskLevel.high)) {
      finalRisk = RiskLevel.high;
    } else if (dangerousPerms.length >= 4) {
      finalRisk = RiskLevel.medium;
    } else if (dangerousPerms.isNotEmpty) {
      finalRisk = RiskLevel.low;
    }

    return ApkScanResult(
      fileName: fileName,
      filePath: filePath,
      fileSizeBytes: fileSizeBytes,
      sha256Hash: sha256Hash,
      packageName: packageName,
      versionName: versionName,
      versionCode: versionCode,
      targetSdkVersion: targetSdk,
      minSdkVersion: minSdk,
      requestedPermissions: rawPerms,
      dangerousPermissions: dangerousPerms,
      riskLevel: finalRisk,
      findings: findings,
      scanTime: DateTime.now(),
      scanComplete: true,
      signatureValid: signatureValid,
      signerCertHash: signerCertHash,
      hashCheckedAgainstThreatDb: true,
      knownMaliciousHash: threatCheck.isMalicious,
      threatDbSource: threatCheck.source,
    );
  }

  static Future<String> _calculateSha256(File file) async {
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }
}
