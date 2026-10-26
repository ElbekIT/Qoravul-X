import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_scan_result.dart';
import '../../models/risk_level.dart';
import '../../services/platform_security_service.dart';
import '../../services/security_provider.dart';

class InstalledAppsScreen extends StatefulWidget {
  const InstalledAppsScreen({super.key});

  @override
  State<InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  String _searchQuery = '';
  RiskLevel? _selectedRiskFilter;
  bool _hideSystemApps = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final allApps = provider.installedApps;

    final filteredApps = allApps.where((app) {
      if (_hideSystemApps && app.isSystemApp) return false;
      if (_selectedRiskFilter != null && app.riskLevel != _selectedRiskFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = app.appName.toLowerCase().contains(query);
        final matchPkg = app.packageName.toLowerCase().contains(query);
        if (!matchName && !matchPkg) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("O'rnatilgan dasturlar"),
        actions: [
          IconButton(
            icon: Icon(
              _hideSystemApps ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _hideSystemApps ? AppTheme.textMuted : AppTheme.accentCyan,
            ),
            tooltip: _hideSystemApps ? "Tizim ilovalarini ko'rsatish" : "Tizim ilovalarini yashirish",
            onPressed: () {
              setState(() {
                _hideSystemApps = !_hideSystemApps;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ilova nomi yoki paketini qidirish...",
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.cardDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Risk Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip("Barchasi", null),
                const SizedBox(width: 6),
                _buildFilterChip("Xavfli", RiskLevel.high),
                const SizedBox(width: 6),
                _buildFilterChip("O'rtacha", RiskLevel.medium),
                const SizedBox(width: 6),
                _buildFilterChip("Past xavf", RiskLevel.low),
                const SizedBox(width: 6),
                _buildFilterChip("Xavfsiz", RiskLevel.safe),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Apps List
          Expanded(
            child: allApps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apps, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          "Ilovalar ro'yxati olinmagan",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.performFullScan(),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Skanerlashni boshlash"),
                        ),
                      ],
                    ),
                  )
                : filteredApps.isEmpty
                    ? const Center(
                        child: Text(
                          "Mos keluvchi dastur topilmadi",
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          return _buildAppCard(context, app);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, RiskLevel? level) {
    final isSelected = _selectedRiskFilter == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.accentCyan.withOpacity(0.25),
      backgroundColor: AppTheme.cardDark,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.accentCyan : Colors.transparent,
      ),
      onSelected: (_) {
        setState(() {
          _selectedRiskFilter = level;
        });
      },
    );
  }

  Widget _buildAppCard(BuildContext context, AppScanResult app) {
    final riskColor = Color(app.riskLevel.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAppDetailsSheet(context, app),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Placeholder / App Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Center(
                  child: Text(
                    app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.appName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: riskColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            app.riskLevel.labelUz,
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      app.packageName,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.storefront_outlined, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          app.installSourceLabel,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        if (app.dangerousPermissionCount > 0) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.shield_outlined, size: 12, color: AppTheme.accentAmber),
                          const SizedBox(width: 3),
                          Text(
                            "${app.dangerousPermissionCount} ta nozik ruxsat",
                            style: const TextStyle(fontSize: 11, color: AppTheme.accentAmber),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppDetailsSheet(BuildContext context, AppScanResult app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            final riskColor = Color(app.riskLevel.colorValue);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Center(
                          child: Text(
                            app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentCyan,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.appName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Versiya: ${app.versionName} (${app.versionCode})",
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            Text(
                              app.packageName,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Risk status box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield, color: riskColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Xavf darajasi: ${app.riskLevel.labelUz}",
                                style: TextStyle(
                                  color: riskColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app.hasFindings
                                    ? "${app.findings.length} ta xavfsizlik parametri qayd etildi"
                                    : "Xavfli yoki zararli xulq-atvor aniqlanmadi",
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Technical metadata
                  _buildSectionHeader("TEXNIK MA'LUMOTLAR"),
                  _buildInfoRow("O'rnatish manbasi", app.installSourceLabel),
                  _buildInfoRow("Tizim ilovasi", app.isSystemApp ? "Ha (System App)" : "Yo'q (Uchinchi tomon)"),
                  _buildInfoRow("Target SDK", "${app.targetSdkVersion ?? "Noma'lum"}"),
                  _buildInfoRow("Min SDK", "${app.minSdkVersion ?? "Noma'lum"}"),
                  if (app.signingCertHash != null)
                    _buildInfoRow("Imzo xeshi (SHA-256)", app.signingCertHash!),

                  const SizedBox(height: 20),

                  // Security Findings (Reasons for classification)
                  if (app.hasFindings) ...[
                    _buildSectionHeader("XAVFSIZLIK TAHLILI VA SABABLARI"),
                    ...app.findings.map((f) => _buildFindingCard(f)),
                    const SizedBox(height: 20),
                  ],

                  // Permissions list
                  _buildSectionHeader("SO'RALGAN RUXSATLAR (${app.requestedPermissions.length})"),
                  if (app.requestedPermissions.isEmpty)
                    const Text("Hech qanday maxsus ruxsat so'ralmagan", style: TextStyle(color: AppTheme.textMuted))
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: app.requestedPermissions.map((perm) {
                        final isDangerous = app.dangerousPermissions.contains(perm);
                        final shortName = perm.replaceFirst('android.permission.', '');
                        return Chip(
                          label: Text(shortName, style: const TextStyle(fontSize: 11)),
                          backgroundColor: isDangerous
                              ? AppTheme.accentRed.withOpacity(0.18)
                              : AppTheme.cardDark,
                          side: BorderSide(
                            color: isDangerous ? AppTheme.accentRed.withOpacity(0.5) : Colors.white12,
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  // Action Buttons (App Info & Official Uninstall flow)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            PlatformSecurityService.openAppSettings(app.packageName);
                          },
                          icon: const Icon(Icons.settings_outlined, size: 18),
                          label: const Text("Tizim sozlamalari"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentCyan,
                            side: const BorderSide(color: AppTheme.accentCyan),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (!app.isSystemApp) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              PlatformSecurityService.requestUninstall(app.packageName);
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text("O'chirish"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingCard(SecurityFinding finding) {
    final severityColor = Color(finding.severity.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: severityColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  finding.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: severityColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  finding.severity.labelUz,
                  style: TextStyle(fontSize: 10, color: severityColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            finding.description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            "Dalil: ${finding.evidence}",
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(
            "Tavsiya: ${finding.recommendation}",
            style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan),
          ),
        ],
      ),
    );
  }
}
