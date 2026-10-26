class AppConstants {
  static const String appName = 'Qoravul X';
  static const String appTagline = "Telefoningiz xavfsizligi — har bir tekshiruvda.";
  static const String packageName = 'com.qoravulx.app';
  static const String appVersion = '1.0.0';
  static const int appVersionCode = 1;

  // Score weights (configurable)
  static const double weightAppSecurity = 0.30;
  static const double weightPermissionPrivacy = 0.25;
  static const double weightLinkProtection = 0.15;
  static const double weightSystemConfig = 0.30;

  // Risk thresholds
  static const int maxDangerousPermsForLowRisk = 3;
  static const int maxDangerousPermsForMediumRisk = 6;
  static const int maxDangerousPermsForHighRisk = 10;

  // Sensitive permission categories
  static const List<String> highRiskPermissions = [
    'android.permission.READ_SMS',
    'android.permission.SEND_SMS',
    'android.permission.RECEIVE_SMS',
    'android.permission.READ_CALL_LOG',
    'android.permission.PROCESS_OUTGOING_CALLS',
    'android.permission.READ_CONTACTS',
    'android.permission.WRITE_CONTACTS',
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.MANAGE_EXTERNAL_STORAGE',
    'android.permission.REQUEST_INSTALL_PACKAGES',
    'android.permission.BIND_ACCESSIBILITY_SERVICE',
    'android.permission.BIND_NOTIFICATION_LISTENER_SERVICE',
    'android.permission.BIND_DEVICE_ADMIN',
    'android.permission.BIND_VPN_SERVICE',
    'android.permission.SYSTEM_ALERT_WINDOW',
    'android.permission.PACKAGE_USAGE_STATS',
  ];

  // Known trusted installer packages
  static const List<String> trustedInstallers = [
    'com.android.vending',
    'com.huawei.appmarket',
    'com.samsung.android.vending',
    'com.amazon.venezia',
    'com.sec.android.app.samsungapps',
    'org.fdroid.fdroid',
  ];

  // Permission explanations in Uzbek
  static const Map<String, String> permissionExplanationsUz = {
    'android.permission.READ_SMS': 'SMS xabarlaringizni o\'qiy oladi. Moliyaviy firibgarlik uchun ishlatilishi mumkin.',
    'android.permission.SEND_SMS': 'Sizning nomingizdan SMS yuborishi mumkin. Pulli SMS xizmatlariga obuna qilishi mumkin.',
    'android.permission.RECEIVE_SMS': 'Kiruvchi SMS xabarlarni ushlab qolishi mumkin.',
    'android.permission.READ_CALL_LOG': 'Qo\'ng\'iroqlar tarixini ko\'ra oladi.',
    'android.permission.READ_CONTACTS': 'Kontaktlaringizni o\'qiy oladi va ulashishi mumkin.',
    'android.permission.CAMERA': 'Kamerangizdan suratga olishi yoki video yozishi mumkin.',
    'android.permission.RECORD_AUDIO': 'Mikrofoningiz orqali ovoz yozishi mumkin.',
    'android.permission.ACCESS_FINE_LOCATION': 'Aniq joylashuvingizni bilishi mumkin.',
    'android.permission.ACCESS_BACKGROUND_LOCATION': 'Dastur yopiq bo\'lganda ham joylashuvingizni kuzatishi mumkin.',
    'android.permission.MANAGE_EXTERNAL_STORAGE': 'Telefondagi barcha fayllarga kirishi mumkin.',
    'android.permission.REQUEST_INSTALL_PACKAGES': 'Boshqa dasturlarni o\'rnatishga urinishi mumkin.',
    'android.permission.BIND_ACCESSIBILITY_SERVICE': 'Ekrandagi barcha matnni o\'qiy oladi, tugmalarni bosishi mumkin.',
    'android.permission.BIND_NOTIFICATION_LISTENER_SERVICE': 'Barcha bildirishnomalaringizni o\'qiy oladi.',
    'android.permission.BIND_DEVICE_ADMIN': 'Telefon ma\'muri sifatida keng huquqlarga ega bo\'lishi mumkin.',
    'android.permission.BIND_VPN_SERVICE': 'Internet trafigingizni yo\'naltirishi mumkin.',
    'android.permission.SYSTEM_ALERT_WINDOW': 'Boshqa dasturlar ustida oyna ochishi mumkin.',
    'android.permission.PACKAGE_USAGE_STATS': 'Qaysi dasturlardan qancha foydalanganingizni ko\'ra oladi.',
  };
}
