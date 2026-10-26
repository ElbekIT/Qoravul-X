class PermissionInfo {
  final String permission;
  final String nameUz;
  final String descriptionUz;
  final String iconName;
  final bool isDangerous;
  final List<String> legitimateUses;
  final List<String> suspiciousUses;

  const PermissionInfo({
    required this.permission,
    required this.nameUz,
    required this.descriptionUz,
    required this.iconName,
    this.isDangerous = false,
    this.legitimateUses = const [],
    this.suspiciousUses = const [],
  });

  static const List<PermissionInfo> allPermissions = [
    PermissionInfo(
      permission: 'android.permission.READ_SMS',
      nameUz: 'SMS o\'qish',
      descriptionUz: 'Dastur SMS xabarlaringizni o\'qiy oladi',
      iconName: 'sms',
      isDangerous: true,
      legitimateUses: ['SMS orqali tasdiqlash kodlari', 'SMS boshqaruvchi dasturlar'],
      suspiciousUses: ['Bank SMS larini o\'g\'irlash', 'OTP kodlarini tutib olish'],
    ),
    PermissionInfo(
      permission: 'android.permission.SEND_SMS',
      nameUz: 'SMS yuborish',
      descriptionUz: 'Dastur sizning nomingizdan SMS yuborishi mumkin',
      iconName: 'send',
      isDangerous: true,
      legitimateUses: ['SMS dasturlari', 'Ikki faktorli autentifikatsiya'],
      suspiciousUses: ['Pulli SMS xizmatlariga obuna', 'Spam tarqatish'],
    ),
    PermissionInfo(
      permission: 'android.permission.CAMERA',
      nameUz: 'Kamera',
      descriptionUz: 'Dastur kamerangizdan foydalanishi mumkin',
      iconName: 'camera_alt',
      isDangerous: true,
      legitimateUses: ['Suratga olish', 'Video qo\'ng\'iroq', 'QR kod skanerlash'],
      suspiciousUses: ['Yashirin suratga olish', 'Shaxsiy hayotga tajovuz'],
    ),
    PermissionInfo(
      permission: 'android.permission.RECORD_AUDIO',
      nameUz: 'Mikrofon',
      descriptionUz: 'Dastur mikrofoningiz orqali ovoz yozishi mumkin',
      iconName: 'mic',
      isDangerous: true,
      legitimateUses: ['Ovozli xabar', 'Qo\'ng\'iroq', 'Ovoz yozish'],
      suspiciousUses: ['Yashirin tinglash', 'Suhbatlarni yozib olish'],
    ),
    PermissionInfo(
      permission: 'android.permission.ACCESS_FINE_LOCATION',
      nameUz: 'Aniq joylashuv',
      descriptionUz: 'Dastur aniq GPS joylashuvingizni bilishi mumkin',
      iconName: 'location_on',
      isDangerous: true,
      legitimateUses: ['Xarita dasturlari', 'Ob-havo', 'Taksiga buyurtma'],
      suspiciousUses: ['Kuzatuv', 'Joylashuvni sotish'],
    ),
    PermissionInfo(
      permission: 'android.permission.ACCESS_BACKGROUND_LOCATION',
      nameUz: 'Fon joylashuvi',
      descriptionUz: 'Dastur yopiq bo\'lganda ham joylashuvingizni kuzatadi',
      iconName: 'share_location',
      isDangerous: true,
      legitimateUses: ['Fitness kuzatuvi', 'Oilaviy joylashuv ulashish'],
      suspiciousUses: ['Doim kuzatib borish', 'Joylashuv tarixini yig\'ish'],
    ),
    PermissionInfo(
      permission: 'android.permission.READ_CONTACTS',
      nameUz: 'Kontaktlar',
      descriptionUz: 'Dastur kontaktlaringizni o\'qiy oladi',
      iconName: 'contacts',
      isDangerous: true,
      legitimateUses: ['Messenger dasturlari', 'Qo\'ng\'iroq dasturlari'],
      suspiciousUses: ['Kontaktlarni o\'g\'irlash', 'Spam uchun ma\'lumot yig\'ish'],
    ),
    PermissionInfo(
      permission: 'android.permission.REQUEST_INSTALL_PACKAGES',
      nameUz: 'Dastur o\'rnatish',
      descriptionUz: 'Boshqa APK fayllarni o\'rnatishga ruxsat so\'raydi',
      iconName: 'install_mobile',
      isDangerous: true,
      legitimateUses: ['Dastur do\'konlari', 'Yangilash tizimlari'],
      suspiciousUses: ['Zararli dasturlarni o\'rnatish', 'Reklama dasturlarini tiqish'],
    ),
    PermissionInfo(
      permission: 'android.permission.SYSTEM_ALERT_WINDOW',
      nameUz: 'Ustiga chiqish',
      descriptionUz: 'Boshqa dasturlar ustida oyna ochishi mumkin',
      iconName: 'picture_in_picture',
      isDangerous: true,
      legitimateUses: ['Suzuvchi pleyerlar', 'Ekran yozish', 'Messenger pufakchalar'],
      suspiciousUses: ['Soxta login oynalar', 'Tugmalarni yashirish'],
    ),
    PermissionInfo(
      permission: 'android.permission.BIND_ACCESSIBILITY_SERVICE',
      nameUz: 'Maxsus imkoniyatlar',
      descriptionUz: 'Ekrandagi barcha matnni o\'qiy oladi va tugmalarni bosa oladi',
      iconName: 'accessibility',
      isDangerous: true,
      legitimateUses: ['Nogironlar uchun dasturlar', 'Parol menejerlari'],
      suspiciousUses: ['Klaviatura kuzatuvi', 'Avtomatik tugma bosish', 'Ma\'lumot o\'g\'irlash'],
    ),
    PermissionInfo(
      permission: 'android.permission.BIND_NOTIFICATION_LISTENER_SERVICE',
      nameUz: 'Bildirishnomalar',
      descriptionUz: 'Barcha bildirishnomalaringizni o\'qiy oladi',
      iconName: 'notifications',
      isDangerous: true,
      legitimateUses: ['Smart soat dasturlari', 'Bildirishnoma boshqaruvchilari'],
      suspiciousUses: ['OTP kodlarini o\'g\'irlash', 'Shaxsiy xabarlarni o\'qish'],
    ),
    PermissionInfo(
      permission: 'android.permission.BIND_VPN_SERVICE',
      nameUz: 'VPN xizmati',
      descriptionUz: 'Internet trafigingizni yo\'naltirishi mumkin',
      iconName: 'vpn_key',
      isDangerous: true,
      legitimateUses: ['VPN dasturlari', 'Xavfsizlik dasturlari'],
      suspiciousUses: ['Trafik kuzatuvi', 'DNS manipulyatsiyasi'],
    ),
    PermissionInfo(
      permission: 'android.permission.BIND_DEVICE_ADMIN',
      nameUz: 'Qurilma boshqaruvi',
      descriptionUz: 'Telefon ma\'muri sifatida keng huquqlarga ega bo\'ladi',
      iconName: 'admin_panel_settings',
      isDangerous: true,
      legitimateUses: ['Korxona boshqaruvi', 'Topish va o\'chirish dasturlari'],
      suspiciousUses: ['O\'chirishni oldini olish', 'Qurilmani qulflash'],
    ),
  ];

  static PermissionInfo? getInfo(String permission) {
    try {
      return allPermissions.firstWhere((p) => p.permission == permission);
    } catch (_) {
      return null;
    }
  }
}
