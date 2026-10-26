import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/permission_info.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_scan_result.dart';
import '../../services/platform_security_service.dart';
import '../../services/security_provider.dart';

class PermissionAuditScreen extends StatelessWidget {
  const PermissionAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final apps = provider.installedApps;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruxsatlar auditi"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: PermissionInfo.allPermissions.length,
        itemBuilder: (context, index) {
          final perm = PermissionInfo.allPermissions[index];
          final matchingApps = apps.where((a) =>
              !a.isSystemApp && a.requestedPermissions.contains(perm.permission)).toList();

          return _buildPermissionCard(context, perm, matchingApps);
        },
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, PermissionInfo perm, List<AppScanResult> apps) {
    final hasApps = apps.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hasApps ? AppTheme.accentAmber.withOpacity(0.15) : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getIconData(perm.iconName),
            color: hasApps ? AppTheme.accentAmber : AppTheme.textMuted,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                perm.nameUz,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hasApps ? AppTheme.accentAmber.withOpacity(0.2) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${apps.length} ta ilova",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hasApps ? AppTheme.accentAmber : AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          perm.descriptionUz,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Legitimate vs Suspicious explanations
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Qonuniy foydalanish:",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        perm.legitimateUses.join(', '),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Shubhali yoki xavfli holatlar:",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentRed),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        perm.suspiciousUses.join(', '),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Apps with this permission
                if (apps.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Uchinchi tomon ilovalarida bu ruxsat topilmadi",
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  )
                else ...[
                  const Text(
                    "Ushbu ruxsatga ega ilovalar:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  ...apps.map((app) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.cardDarkAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              app.appName.isNotEmpty ? app.appName[0] : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                            ),
                          ),
                        ),
                        title: Text(app.appName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text(app.packageName, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                        trailing: IconButton(
                          icon: const Icon(Icons.settings, size: 16, color: AppTheme.accentCyan),
                          onPressed: () {
                            PlatformSecurityService.openAppSettings(app.packageName);
                          },
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'sms': return Icons.sms_outlined;
      case 'send': return Icons.send_outlined;
      case 'camera_alt': return Icons.camera_alt_outlined;
      case 'mic': return Icons.mic_none_outlined;
      case 'location_on': return Icons.location_on_outlined;
      case 'share_location': return Icons.share_location_outlined;
      case 'contacts': return Icons.contacts_outlined;
      case 'install_mobile': return Icons.install_mobile_outlined;
      case 'picture_in_picture': return Icons.picture_in_picture_outlined;
      case 'accessibility': return Icons.accessibility_new_outlined;
      case 'notifications': return Icons.notifications_none_outlined;
      case 'vpn_key': return Icons.vpn_key_outlined;
      case 'admin_panel_settings': return Icons.admin_panel_settings_outlined;
      default: return Icons.security;
    }
  }
}
