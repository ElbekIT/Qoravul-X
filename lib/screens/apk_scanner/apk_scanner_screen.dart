import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart' if (dart.library.html) '';
import '../../core/theme/app_theme.dart';
import '../../models/apk_scan_result.dart';
import '../../models/risk_level.dart';
import '../../services/security_provider.dart';

class ApkScannerScreen extends StatefulWidget {
  final String? initialApkPath;

  const ApkScannerScreen({super.key, this.initialApkPath});

  @override
  State<ApkScannerScreen> createState() => _ApkScannerScreenState();
}

class _ApkScannerScreenState extends State<ApkScannerScreen> {
  bool _isLoading = false;
  ApkScanResult? _currentResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialApkPath != null) {
      _scanFile(widget.initialApkPath!);
    }
  }

  Future<void> _pickAndScanApk() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (result != null && result.files.single.path != null) {
        await _scanFile(result.files.single.path!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Faylni tanlashda xatolik: $e";
      });
    }
  }

  Future<void> _scanFile(String path) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<SecurityProvider>();
      final result = await provider.scanApkFile(path);
      setState(() {
        _currentResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "APK tekshiruvida xatolik: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("APK fayl tahlili"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pick Card / Telegram info
            _buildPickerCard(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentRed.withOpacity(0.4)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppTheme.accentRed, fontSize: 13),
                ),
              ),
            ],

            if (_isLoading) ...[
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(color: AppTheme.accentCyan),
                    SizedBox(height: 14),
                    Text(
                      "APK fayl, imzo va xavfsizlik tahlili o'tkazilmoqda...",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ] else if (_currentResult != null) ...[
              const SizedBox(height: 20),
              _buildResultReport(_currentResult!),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_zip_outlined, size: 40, color: AppTheme.accentCyan),
          ),
          const SizedBox(height: 14),
          const Text(
            "APK faylini tekshirish",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Telegram, brauzer yoki fayl menejerdan yuklab olingan har qanday APK faylni o'rnatishdan oldin tekshiring.",
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickAndScanApk,
            icon: const Icon(Icons.file_open_outlined),
            label: const Text("Faylni tanlash"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: AppTheme.primaryDark,
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultReport(ApkScanResult res) {
    final riskColor = Color(res.riskLevel.colorValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: riskColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.security, size: 36, color: riskColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Xavf darajasi: ${res.riskLevel.labelUz}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      res.knownMaliciousHash
                          ? "DIQQAT: Ma'lum zararli dasturlar bazasida topildi!"
                          : (res.findings.isNotEmpty
                              ? "${res.findings.length} ta xavfsizlik parametri qayd etildi"
                              : "Zararli alomatlar aniqlanmadi"),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Metadata Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FAYL VA PAKET METAMA'LUMOTLARI",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildRow("Fayl nomi", res.fileName),
                _buildRow("Hajmi", res.fileSizeFormatted),
                _buildRow("Paket nomi", res.packageName ?? "Aniqlanmadi"),
                _buildRow("Versiya", "${res.versionName ?? "?"} (${res.versionCode ?? "?"})"),
                _buildRow("Target SDK", "${res.targetSdkVersion ?? "Noma'lum"}"),
                _buildRow("Min SDK", "${res.minSdkVersion ?? "Noma'lum"}"),
                _buildRow("Raqamli imzo", res.signatureValid ? "Mavjud va haqiqiy" : "Yaroqsiz / Yo'q"),
                _buildRow("Imzo xeshi", res.signerCertHash ?? "Aniqlanmadi"),
                _buildRow("Fayl SHA-256", res.sha256Hash),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Findings
        if (res.findings.isNotEmpty) ...[
          const Text(
            "Xavfsizlik topilmalari",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...res.findings.map((f) => _buildFindingItem(f)),
          const SizedBox(height: 16),
        ],

        // Permissions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SO'RALGAN RUXSATLAR (${res.requestedPermissions.length})",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                if (res.requestedPermissions.isEmpty)
                  const Text("Maxsus ruxsatlar talab qilinmagan", style: TextStyle(color: AppTheme.textMuted))
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: res.requestedPermissions.map((p) {
                      final isDangerous = res.dangerousPermissions.contains(p);
                      final name = p.replaceFirst('android.permission.', '');
                      return Chip(
                        label: Text(name, style: const TextStyle(fontSize: 11)),
                        backgroundColor: isDangerous ? AppTheme.accentRed.withOpacity(0.2) : AppTheme.surfaceDark,
                        side: BorderSide(
                          color: isDangerous ? AppTheme.accentRed.withOpacity(0.5) : Colors.white12,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Install Advice Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: res.riskLevel == RiskLevel.critical || res.riskLevel == RiskLevel.high
                ? AppTheme.accentRed.withOpacity(0.15)
                : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: res.riskLevel == RiskLevel.critical ? AppTheme.accentRed : Colors.white12,
            ),
          ),
          child: Column(
            children: [
              Text(
                res.riskLevel == RiskLevel.critical
                    ? "OGOHLANTIRISH: Ushbu dasturni o'rnatish telefoningiz va shaxsiy ma'lumotlaringiz uchun jiddiy xavf tug'diradi!"
                    : "Qoravul X sizning ruxsatingizsiz hech qanday dasturni o'rnatmaydi yoki o'chirmaydi.",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: res.riskLevel == RiskLevel.critical ? AppTheme.accentRed : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingItem(dynamic f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            f.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentAmber),
          ),
          const SizedBox(height: 4),
          Text(f.description, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text("Tavsiya: ${f.recommendation}", style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan)),
        ],
      ),
    );
  }
}
