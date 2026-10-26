import 'risk_level.dart';

class AppScanResult {
  final String appName;
  final String packageName;
  final String versionName;
  final int versionCode;
  final String? installerPackage;
  final List<String> requestedPermissions;
  final List<String> dangerousPermissions;
  final RiskLevel riskLevel;
  final List<SecurityFinding> findings;
  final DateTime scanTime;
  final bool scanComplete;
  final String? appIconBase64;
  final int? targetSdkVersion;
  final int? minSdkVersion;
  final bool isSystemApp;
  final String? signingCertHash;
  final int installTimeMs;
  final int updateTimeMs;

  AppScanResult({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    this.installerPackage,
    required this.requestedPermissions,
    required this.dangerousPermissions,
    required this.riskLevel,
    required this.findings,
    required this.scanTime,
    this.scanComplete = true,
    this.appIconBase64,
    this.targetSdkVersion,
    this.minSdkVersion,
    this.isSystemApp = false,
    this.signingCertHash,
    this.installTimeMs = 0,
    this.updateTimeMs = 0,
  });

  int get dangerousPermissionCount => dangerousPermissions.length;
  
  bool get hasFindings => findings.isNotEmpty;
  
  List<SecurityFinding> get criticalFindings =>
      findings.where((f) => f.severity == RiskLevel.critical).toList();
  
  List<SecurityFinding> get highFindings =>
      findings.where((f) => f.severity == RiskLevel.high).toList();

  String get installSourceLabel {
    if (installerPackage == null) return "Noma'lum manba";
    switch (installerPackage) {
      case 'com.android.vending': return 'Google Play Store';
      case 'com.huawei.appmarket': return 'Huawei AppGallery';
      case 'com.samsung.android.vending': return 'Samsung Galaxy Store';
      case 'com.amazon.venezia': return 'Amazon Appstore';
      case 'org.fdroid.fdroid': return 'F-Droid';
      default:
        if (installerPackage!.contains('browser') || installerPackage!.contains('download')) {
          return "Brauzerdan yuklangan";
        }
        return installerPackage!;
    }
  }

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'packageName': packageName,
    'versionName': versionName,
    'versionCode': versionCode,
    'installerPackage': installerPackage,
    'requestedPermissions': requestedPermissions,
    'dangerousPermissions': dangerousPermissions,
    'riskLevel': riskLevel.name,
    'findings': findings.map((f) => f.toJson()).toList(),
    'scanTime': scanTime.toIso8601String(),
    'scanComplete': scanComplete,
    'targetSdkVersion': targetSdkVersion,
    'minSdkVersion': minSdkVersion,
    'isSystemApp': isSystemApp,
    'signingCertHash': signingCertHash,
  };
}

class SecurityFinding {
  final String title;
  final String description;
  final String evidence;
  final RiskLevel severity;
  final String category;
  final bool confirmed;
  final String recommendation;
  final DateTime detectedAt;

  SecurityFinding({
    required this.title,
    required this.description,
    required this.evidence,
    required this.severity,
    required this.category,
    this.confirmed = false,
    required this.recommendation,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'evidence': evidence,
    'severity': severity.name,
    'category': category,
    'confirmed': confirmed,
    'recommendation': recommendation,
    'detectedAt': detectedAt.toIso8601String(),
  };
}
