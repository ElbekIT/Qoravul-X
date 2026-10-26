import 'dart:convert';
import 'package:flutter/services.dart';

/// Platform channel service to communicate with Android native APIs
/// for package inspection, device info, and security checks.
class PlatformSecurityService {
  static const MethodChannel _channel = MethodChannel('com.qoravulx.app/security');

  /// Get list of all installed packages with metadata
  /// Falls back to basic info if detailed inspection fails
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } on PlatformException catch (_) {
      return [];
    } on MissingPluginException catch (_) {
      // Platform channel not implemented - return empty
      return [];
    }
  }

  /// Get detailed info about a specific package
  static Future<Map<String, dynamic>?> getPackageInfo(String packageName) async {
    try {
      final result = await _channel.invokeMethod('getPackageInfo', {
        'packageName': packageName,
      });
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } on PlatformException catch (_) {
      return null;
    } on MissingPluginException catch (_) {
      return null;
    }
  }

  /// Get device security information
  static Future<Map<String, dynamic>> getDeviceSecurityInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceSecurityInfo');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return _getBasicDeviceInfo();
    } on PlatformException catch (_) {
      return _getBasicDeviceInfo();
    } on MissingPluginException catch (_) {
      return _getBasicDeviceInfo();
    }
  }

  /// Check if a specific security setting is enabled
  static Future<bool?> checkSecuritySetting(String setting) async {
    try {
      final result = await _channel.invokeMethod('checkSecuritySetting', {
        'setting': setting,
      });
      return result as bool?;
    } catch (_) {
      return null;
    }
  }

  /// Open app info settings page for a package
  static Future<bool> openAppSettings(String packageName) async {
    try {
      final result = await _channel.invokeMethod('openAppSettings', {
        'packageName': packageName,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Request uninstall of a package (shows system confirmation dialog)
  static Future<bool> requestUninstall(String packageName) async {
    try {
      final result = await _channel.invokeMethod('requestUninstall', {
        'packageName': packageName,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Open security settings
  static Future<bool> openSecuritySettings() async {
    try {
      final result = await _channel.invokeMethod('openSecuritySettings');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _getBasicDeviceInfo() {
    return {
      'androidVersion': 'Unknown',
      'sdkVersion': 0,
      'securityPatchLevel': null,
      'deviceModel': 'Unknown',
      'manufacturer': 'Unknown',
      'isRooted': false,
      'rootCheckAvailable': false,
    };
  }
}
