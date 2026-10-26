import 'risk_level.dart';
import 'app_scan_result.dart';

class ApkScanResult {
  final String fileName;
  final String filePath;
  final int fileSizeBytes;
  final String sha256Hash;
  final String? packageName;
  final String? versionName;
  final int? versionCode;
  final int? targetSdkVersion;
  final int? minSdkVersion;
  final List<String> requestedPermissions;
  final List<String> dangerousPermissions;
  final RiskLevel riskLevel;
  final List<SecurityFinding> findings;
  final DateTime scanTime;
  final bool scanComplete;
  final bool signatureValid;
  final String? signerCertHash;
  final bool hashCheckedAgainstThreatDb;
  final bool knownMaliciousHash;
  final String? threatDbSource;

  ApkScanResult({
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    required this.sha256Hash,
    this.packageName,
    this.versionName,
    this.versionCode,
    this.targetSdkVersion,
    this.minSdkVersion,
    required this.requestedPermissions,
    required this.dangerousPermissions,
    required this.riskLevel,
    required this.findings,
    required this.scanTime,
    this.scanComplete = true,
    this.signatureValid = false,
    this.signerCertHash,
    this.hashCheckedAgainstThreatDb = false,
    this.knownMaliciousHash = false,
    this.threatDbSource,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1048576) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    if (fileSizeBytes < 1073741824) return '${(fileSizeBytes / 1048576).toStringAsFixed(1)} MB';
    return '${(fileSizeBytes / 1073741824).toStringAsFixed(1)} GB';
  }
}
