import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/device_security_info.dart';
import '../../services/platform_security_service.dart';
import '../../services/security_provider.dart';

class DeviceAuditScreen extends StatelessWidget {
  const DeviceAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final info = provider.deviceInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Telefon xavfsizligi"),
      ),
      body: info == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phonelink_setup, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    "Qurilma tekshiruvi amalga oshirilmagan",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.performFullScan(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Qurilmani tekshirish"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Device Header Card
                  _buildDeviceHeader(info),

                  const SizedBox(height: 16),

                  const Text(
                    "QURILMA XAVFSIZLIK MEZONLARI",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 1. Root Status
                  _buildAuditCard(
                    title: "Root (Superuser) holati",
                    subtitle: info.isRooted
                        ? "DIQQAT: Qurilmada root huquqlari yoki test-keys aniqlandi"
                        : "Root huquqlari aniqlanmadi (Standart tizim)",
                    isSecure: !info.isRooted,
                    evidence: info.isRooted
                        ? "Tizim fayllari ichida 'su' binarysi yoki xavfli build-tags mavjud"
                        : "Standart xavfsizlik chegaralari butun",
                    actionText: info.isRooted ? "Root xavflari haqida" : null,
                  ),

                  const SizedBox(height: 10),

                  // 2. Security Patch Level
                  _buildAuditCard(
                    title: "Android xavfsizlik yangilanishi (Patch)",
                    subtitle: info.securityPatchLevel != null
                        ? "Oxirgi yangilanish sanasi: ${info.securityPatchLevel}"
                        : "Yangilanish sanasi aniqlanmadi",
                    isSecure: info.isPatchCurrent,
                    isWarning: !info.isPatchCurrent && info.securityPatchLevel != null,
                    evidence: info.patchAgeMonths >= 0
                        ? "Yangilanish yoshi: ~${info.patchAgeMonths} oy oldin"
                        : "Ishlab chiqaruvchi ma'lumoti cheklangan",
                  ),

                  const SizedBox(height: 10),

                  // 3. USB Debugging (ADB)
                  _buildAuditCard(
                    title: "USB orqali nosozliklarni tuzatish (ADB)",
                    subtitle: info.usbDebuggingEnabled
                        ? "Yoqilgan — Kompyuterga ulanganda tizim buyruqlarini bajarish mumkin"
                        : "O'chirilgan — Tizim himoyalangan",
                    isSecure: !info.usbDebuggingEnabled,
                    isWarning: info.usbDebuggingEnabled,
                    evidence: "Settings.Global.ADB_ENABLED holati",
                  ),

                  const SizedBox(height: 10),

                  // 4. Developer Options
                  _buildAuditCard(
                    title: "Dasturchi sozlamalari (Developer Options)",
                    subtitle: info.developerOptionsEnabled
                        ? "Faol holatda"
                        : "O'chirilgan (Standart foydalanuvchi rejimi)",
                    isSecure: !info.developerOptionsEnabled,
                    isWarning: info.developerOptionsEnabled,
                    evidence: "Dasturchi rejimi tizim xavfsizlik cheklovlarini kamaytirishi mumkin",
                  ),

                  const SizedBox(height: 10),

                  // 5. Screen Lock & Biometrics
                  _buildAuditCard(
                    title: "Ekran qulfi (PIN / Parol / Biometriya)",
                    subtitle: info.screenLockEnabled
                        ? "O'rnatilgan — Ma'lumotlar apparat darajasida shifrlangan"
                        : "O'rnatilmagan — Telefon qo'lga tushganda oson o'g'irlanadi",
                    isSecure: info.screenLockEnabled,
                    evidence: "KeyguardManager holati tekshirildi",
                  ),

                  const SizedBox(height: 20),

                  // System Settings Button
                  ElevatedButton.icon(
                    onPressed: () {
                      PlatformSecurityService.openSecuritySettings();
                    },
                    icon: const Icon(Icons.settings_suggest_outlined),
                    label: const Text("Tizim xavfsizlik sozlamalarini ochish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cardDarkAlt,
                      foregroundColor: AppTheme.accentCyan,
                      side: const BorderSide(color: AppTheme.accentCyan),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildDeviceHeader(DeviceSecurityInfo info) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smartphone, size: 36, color: AppTheme.accentBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${info.manufacturer.toUpperCase()} ${info.deviceModel}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  "Android ${info.androidVersion} (API darajasi: ${info.sdkVersion})",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  "Himoya: ${info.playProtectStatus ?? "Mavjud"}",
                  style: const TextStyle(fontSize: 11, color: AppTheme.accentGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCard({
    required String title,
    required String subtitle,
    required bool isSecure,
    bool isWarning = false,
    required String evidence,
    String? actionText,
  }) {
    Color statusColor = AppTheme.accentGreen;
    IconData statusIcon = Icons.check_circle_outline;

    if (!isSecure && !isWarning) {
      statusColor = AppTheme.accentRed;
      statusIcon = Icons.cancel_outlined;
    } else if (isWarning) {
      statusColor = AppTheme.accentAmber;
      statusIcon = Icons.warning_amber_rounded;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSecure ? AppTheme.textPrimary : statusColor,
                      fontWeight: isSecure ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Dalil: $evidence",
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
