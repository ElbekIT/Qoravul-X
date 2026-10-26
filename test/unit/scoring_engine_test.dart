import 'package:flutter_test/flutter_test.dart';
import 'package:qoravul_x/models/app_scan_result.dart';
import 'package:qoravul_x/models/device_security_info.dart';
import 'package:qoravul_x/models/risk_level.dart';
import 'package:qoravul_x/services/scoring/scoring_engine.dart';

void main() {
  group('ScoringEngine Unit Tests', () {
    test('Clean state with secure device produces high score', () {
      final secureDevice = DeviceSecurityInfo(
        androidVersion: '14',
        sdkVersion: 34,
        securityPatchLevel: DateTime.now().toIso8601String().substring(0, 10),
        isRooted: false,
        developerOptionsEnabled: false,
        usbDebuggingEnabled: false,
        screenLockEnabled: true,
        screenLockCheckAvailable: true,
        encryptionEnabled: true,
        encryptionCheckAvailable: true,
        deviceModel: 'Pixel 8',
        manufacturer: 'Google',
        checkTime: DateTime.now(),
      );

      final cleanApps = [
        AppScanResult(
          appName: 'Google Maps',
          packageName: 'com.google.android.apps.maps',
          versionName: '11.0',
          versionCode: 100,
          installerPackage: 'com.android.vending',
          requestedPermissions: ['android.permission.ACCESS_FINE_LOCATION'],
          dangerousPermissions: ['android.permission.ACCESS_FINE_LOCATION'],
          riskLevel: RiskLevel.safe,
          findings: [],
          scanTime: DateTime.now(),
          isSystemApp: true,
        ),
      ];

      final score = ScoringEngine.evaluate(
        installedApps: cleanApps,
        deviceInfo: secureDevice,
        urlChecksCount: 5,
        maliciousUrlsFound: 0,
        isScanComplete: true,
      );

      expect(score.overallScore, greaterThanOrEqualTo(90));
      expect(score.scanComplete, isTrue);
      expect(score.appSecurityScore, equals(100));
    });

    test('Rooted device causes significant system deduction', () {
      final rootedDevice = DeviceSecurityInfo(
        androidVersion: '14',
        sdkVersion: 34,
        securityPatchLevel: DateTime.now().toIso8601String().substring(0, 10),
        isRooted: true,
        developerOptionsEnabled: true,
        usbDebuggingEnabled: true,
        screenLockEnabled: true,
        screenLockCheckAvailable: true,
        encryptionEnabled: true,
        encryptionCheckAvailable: true,
        deviceModel: 'Test Device',
        manufacturer: 'Generic',
        checkTime: DateTime.now(),
      );

      final score = ScoringEngine.evaluate(
        installedApps: [],
        deviceInfo: rootedDevice,
        urlChecksCount: 1,
        maliciousUrlsFound: 0,
        isScanComplete: true,
      );

      // Root (-35) + ADB (-15) -> system score drops to <= 50
      expect(score.systemConfigScore, lessThanOrEqualTo(50));
    });

    test('Critical malware presence drops overall score dramatically', () {
      final infectedApps = [
        AppScanResult(
          appName: 'Malicious Trojan App',
          packageName: 'com.bad.malware',
          versionName: '1.0',
          versionCode: 1,
          requestedPermissions: [
            'android.permission.BIND_ACCESSIBILITY_SERVICE',
            'android.permission.READ_SMS',
            'android.permission.INTERNET',
          ],
          dangerousPermissions: [
            'android.permission.BIND_ACCESSIBILITY_SERVICE',
            'android.permission.READ_SMS',
          ],
          riskLevel: RiskLevel.critical,
          findings: [
            SecurityFinding(
              title: 'Confirmed Malware',
              description: 'Spyware payload',
              evidence: 'Trojan fingerprint',
              severity: RiskLevel.critical,
              category: 'Malware',
              confirmed: true,
              recommendation: 'Uninstall',
            )
          ],
          scanTime: DateTime.now(),
        ),
      ];

      final score = ScoringEngine.evaluate(
        installedApps: infectedApps,
        deviceInfo: null,
        urlChecksCount: 1,
        maliciousUrlsFound: 0,
        isScanComplete: true,
      );

      expect(score.appSecurityScore, lessThanOrEqualTo(75));
    });
  });
}
