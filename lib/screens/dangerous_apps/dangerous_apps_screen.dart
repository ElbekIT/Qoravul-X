import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_scan_result.dart';
import '../../models/risk_level.dart';
import '../../services/platform_security_service.dart';
import '../../services/security_provider.dart';

class DangerousAppsScreen extends StatefulWidget {
  const DangerousAppsScreen({super.key});

  @override
  State<DangerousAppsScreen> createState() => _DangerousAppsScreenState();
}

class _DangerousAppsScreenState extends State<DangerousAppsScreen> {
  String _sortBy = 'risk'; // 'risk' or 'name'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final criticalApps = provider.criticalApps;
    final highApps = provider.highRiskApps;
    final mediumApps = provider.mediumRiskApps;
    final dangerousApps = [...criticalApps, ...highApps, ...mediumApps];

    if (_sortBy == 'name') {
      dangerousApps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    } else {
      dangerousApps.sort((a, b) => a.riskLevel.sortOrder.compareTo(b.riskLevel.sortOrder));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xavfli dasturlar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: "Hisobotni ulashish",
            onPressed: dangerousApps.isEmpty
                ? null
                : () => _exportReport(context, dangerousApps),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. STATS BANNER
            _buildStatsHeader(criticalApps.length, highApps.length, mediumApps.length),

            const SizedBox(height: 16),

            // 2. SORT CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Topilgan xavflar (${dangerousApps.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                PopupMenuButton<String>(
                  initialValue: _sortBy,
                  onSelected: (val) => setState(() => _sortBy = val),
                  child: Row(
                    children: [
                      const Icon(Icons.sort, size: 16, color: AppTheme.accentCyan),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy == 'risk' ? "Xavf bo'yicha" : "Nomi bo'yicha",
                        style: const TextStyle(fontSize: 12, color: AppTheme.accentCyan),
                      ),
                    ],
                  ),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'risk', child: Text("Xavf darajasi bo'yicha")),
                    const PopupMenuItem(value: 'name', child: Text("Ilova nomi bo'yicha")),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 3. FINDINGS LIST OR EMPTY STATE
            if (dangerousApps.isEmpty)
              _buildEmptyState(context, provider)
            else
              ...dangerousApps.map((app) => _buildDangerousAppCard(context, app)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int critical, int high, int medium) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            "XAVFSIZLIK XULOSASI",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  count: critical,
                  label: "Zararli",
                  color: AppTheme.accentRed,
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              Expanded(
                child: _buildStatItem(
                  count: high,
                  label: "Yuqori xavf",
                  color: AppTheme.accentOrange,
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              Expanded(
                child: _buildStatItem(
                  count: medium,
                  label: "Shubhali",
                  color: AppTheme.accentAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: count > 0 ? color : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, SecurityProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.verified_user_outlined, size: 56, color: AppTheme.accentGreen),
          const SizedBox(height: 16),
          const Text(
            "Xavfli dasturlar topilmadi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "O'tkazilgan tekshiruvlar natijasida qurilmangizda ma'lum zararli dastur indikatorlari yoki jiddiy ruxsat xavflari aniqlanmadi.",
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "(Eslatma: bu qurilmada mutlaqo hech qanday xavf yo'qligi kafolati emas, balki amalga oshirilgan tahlillar bo'yicha toza holatni bildiradi)",
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerousAppCard(BuildContext context, AppScanResult app) {
    final riskColor = Color(app.riskLevel.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: riskColor.withOpacity(0.4), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        app.packageName,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: riskColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    app.riskLevel.labelUz.toUpperCase(),
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Findings Details
            if (app.findings.isNotEmpty) ...[
              ...app.findings.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.report_problem_outlined, size: 14, color: riskColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              f.title,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: riskColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.description,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Dalil: ${f.evidence}",
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Tavsiya: ${f.recommendation}",
                        style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Text(
                "Sabab: ${app.dangerousPermissions.length} ta nozik ruxsatlar kombinatsiyasi mavjud.",
                style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              ),
            ],

            const SizedBox(height: 12),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    PlatformSecurityService.openAppSettings(app.packageName);
                  },
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text("Sozlamalar"),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.accentCyan),
                ),
                if (!app.isSystemApp) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      PlatformSecurityService.requestUninstall(app.packageName);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text("O'chirish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportReport(BuildContext context, List<AppScanResult> apps) {
    final buffer = StringBuffer();
    buffer.writeln("=== QORAVUL X: XAVFSIZLIK HISOBOTI ===");
    buffer.writeln("Tekshiruv sanasi: ${DateTime.now().toLocal()}");
    buffer.writeln("Topilgan xavfli dasturlar soni: ${apps.length}\n");

    for (final app in apps) {
      buffer.writeln("Dastur: ${app.appName}");
      buffer.writeln("Paket: ${app.packageName}");
      buffer.writeln("Xavf darajasi: ${app.riskLevel.labelUz}");
      buffer.writeln("Manba: ${app.installSourceLabel}");
      for (final f in app.findings) {
        buffer.writeln("- Muammo: ${f.title}");
        buffer.writeln("  Dalil: ${f.evidence}");
      }
      buffer.writeln("-----------------------------------------");
    }
    buffer.writeln("\nHisobot Qoravul X — Maximum Security ilovasi orqali shakllantirildi.");

    Share.share(buffer.toString(), subject: "Qoravul X Xavfsizlik Hisoboti");
  }
}
