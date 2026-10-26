import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/risk_level.dart';
import '../../services/security_provider.dart';
import '../installed_apps/installed_apps_screen.dart';
import '../dangerous_apps/dangerous_apps_screen.dart';
import '../apk_scanner/apk_scanner_screen.dart';
import '../url_scanner/url_scanner_screen.dart';
import '../device_audit/device_audit_screen.dart';
import '../permission_audit/permission_audit_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final score = provider.score;
    final isScanning = provider.isScanning;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/qoravul_x_logo.jpg',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.performFullScan(),
        color: AppTheme.accentCyan,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. MAIN SECURITY SCORE CARD
              _buildMainScoreCard(context, provider),

              const SizedBox(height: 20),

              // 2. QUICK ACTION BUTTONS
              _buildQuickActions(context, provider),

              const SizedBox(height: 20),

              // 3. SEPARATE SCORES BREAKDOWN
              _buildCategoryScores(context, provider),

              const SizedBox(height: 20),

              // 4. SECURITY MODULE CARDS
              _buildModuleCards(context, provider),

              const SizedBox(height: 20),

              // 5. TRANSPARENCY & DISCLAIMER NOTE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Text(
                  "Eslatma: Qoravul X tekshiruv natijalari real texnik tahlilga asoslangan. 100/100 ball o'tkazilgan tekshiruvlarda xavf topilmaganini anglatadi, ammo hech bir dastur 100% mutlaq xavfsizlikni kafolatlay olmaydi.",
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScoreCard(BuildContext context, SecurityProvider provider) {
    final score = provider.score;
    final isScanning = provider.isScanning;

    Color scoreColor = AppTheme.accentGreen;
    if (score.overallScore < 50) {
      scoreColor = AppTheme.accentRed;
    } else if (score.overallScore < 70) {
      scoreColor = AppTheme.accentAmber;
    } else if (score.overallScore < 90) {
      scoreColor = AppTheme.accentCyan;
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.cardDark,
              AppTheme.cardDarkAlt,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: scoreColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TELEFON XAVFSIZLIGI",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (!score.scanComplete && !isScanning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "To'liq tekshirilmagan",
                      style: TextStyle(fontSize: 11, color: AppTheme.accentAmber, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 20),

            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              animation: true,
              percent: isScanning ? provider.scanProgress : (score.overallScore / 100.0).clamp(0.0, 1.0),
              center: isScanning
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.accentCyan),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(provider.scanProgress * 100).toInt()}%",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${score.overallScore}",
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        const Text(
                          "/ 100 ball",
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: scoreColor,
              backgroundColor: const Color(0xFF1E3050),
            ),

            const SizedBox(height: 18),

            Text(
              isScanning ? provider.currentScanAction : score.statusTextUz,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isScanning ? AppTheme.accentCyan : scoreColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  "Qamrov: ${score.checksCompleted}/${score.checksTotal} ta mezon",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                if (provider.lastScanTime != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    "${provider.lastScanTime!.hour.toString().padLeft(2, '0')}:${provider.lastScanTime!.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, SecurityProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.isScanning
                ? null
                : () => provider.performFullScan(),
            icon: const Icon(Icons.shield_outlined, size: 20),
            label: Text(provider.isScanning ? "Skaner..." : "Tekshirish"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: AppTheme.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApkScannerScreen()),
              );
            },
            icon: const Icon(Icons.install_mobile, size: 20),
            label: const Text("APK tahlili"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cardDarkAlt,
              foregroundColor: AppTheme.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UrlScannerScreen()),
              );
            },
            icon: const Icon(Icons.link, size: 20),
            label: const Text("Havola"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cardDarkAlt,
              foregroundColor: AppTheme.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryScores(BuildContext context, SecurityProvider provider) {
    final score = provider.score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alohidaxavfsizlik indekslari",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniScoreCard(
                title: "Ilovalar",
                score: score.appSecurityScore,
                icon: Icons.apps,
                color: AppTheme.accentGreen,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InstalledAppsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniScoreCard(
                title: "Maxfiylik",
                score: score.permissionPrivacyScore,
                icon: Icons.privacy_tip_outlined,
                color: AppTheme.accentCyan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PermissionAuditScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniScoreCard(
                title: "Havolalar",
                score: score.linkProtectionScore,
                icon: Icons.travel_explore,
                color: AppTheme.accentAmber,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UrlScannerScreen()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniScoreCard(
                title: "Tizim sozlama",
                score: score.systemConfigScore,
                icon: Icons.phonelink_setup,
                color: AppTheme.accentBlue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceAuditScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniScoreCard({
    required String title,
    required int score,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "$score%",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: score >= 80 ? AppTheme.accentGreen : (score >= 50 ? AppTheme.accentAmber : AppTheme.accentRed),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCards(BuildContext context, SecurityProvider provider) {
    final dangerousCount = provider.dangerousApps.length;
    final totalApps = provider.installedApps.length;

    return Column(
      children: [
        _buildModuleCard(
          title: "Xavfli dasturlar",
          subtitle: dangerousCount > 0
              ? "$dangerousCount ta e'tibor talab ilova aniqlangan"
              : "Xavfli yoki zararli ilovalar topilmadi",
          badge: dangerousCount > 0 ? "$dangerousCount" : null,
          badgeColor: AppTheme.accentRed,
          icon: Icons.warning_amber_rounded,
          iconColor: dangerousCount > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DangerousAppsScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildModuleCard(
          title: "O'rnatilgan dasturlar",
          subtitle: totalApps > 0
              ? "$totalApps ta ilova o'rganildi va tasniflandi"
              : "Ilovalar ro'yxatini olish uchun bosing",
          badge: totalApps > 0 ? "$totalApps" : null,
          badgeColor: AppTheme.accentCyan,
          icon: Icons.apps_outlined,
          iconColor: AppTheme.accentCyan,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InstalledAppsScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildModuleCard(
          title: "Maxfiylik va ruxsatlar auditi",
          subtitle: "SMS, Kamera, Mikrofon va Maxsus imkoniyatlar tahlili",
          icon: Icons.lock_outline,
          iconColor: AppTheme.accentAmber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PermissionAuditScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildModuleCard(
          title: "Telefon xavfsizligi auditi",
          subtitle: "Root holati, xavfsizlik patchi, ADB va ekran qulfi",
          icon: Icons.security_update_good,
          iconColor: AppTheme.accentBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeviceAuditScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.accentCyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
