class DeviceSecurityInfo {
  final String androidVersion;
  final int sdkVersion;
  final String? securityPatchLevel;
  final bool isRooted;
  final bool rootCheckAvailable;
  final bool developerOptionsEnabled;
  final bool usbDebuggingEnabled;
  final bool unknownSourcesEnabled;
  final bool screenLockEnabled;
  final bool screenLockCheckAvailable;
  final bool encryptionEnabled;
  final bool encryptionCheckAvailable;
  final String deviceModel;
  final String manufacturer;
  final String? playProtectStatus;
  final bool playProtectCheckAvailable;
  final DateTime checkTime;

  DeviceSecurityInfo({
    required this.androidVersion,
    required this.sdkVersion,
    this.securityPatchLevel,
    this.isRooted = false,
    this.rootCheckAvailable = true,
    this.developerOptionsEnabled = false,
    this.usbDebuggingEnabled = false,
    this.unknownSourcesEnabled = false,
    this.screenLockEnabled = true,
    this.screenLockCheckAvailable = false,
    this.encryptionEnabled = true,
    this.encryptionCheckAvailable = false,
    required this.deviceModel,
    required this.manufacturer,
    this.playProtectStatus,
    this.playProtectCheckAvailable = false,
    required this.checkTime,
  });

  bool get hasSecurityPatch => securityPatchLevel != null;

  bool get isPatchCurrent {
    if (securityPatchLevel == null) return false;
    try {
      final patchDate = DateTime.parse(securityPatchLevel!);
      final monthsAgo = DateTime.now().difference(patchDate).inDays ~/ 30;
      return monthsAgo <= 3;
    } catch (_) {
      return false;
    }
  }

  int get patchAgeMonths {
    if (securityPatchLevel == null) return -1;
    try {
      final patchDate = DateTime.parse(securityPatchLevel!);
      return DateTime.now().difference(patchDate).inDays ~/ 30;
    } catch (_) {
      return -1;
    }
  }
}
