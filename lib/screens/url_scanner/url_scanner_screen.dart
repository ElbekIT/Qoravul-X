import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../models/risk_level.dart';
import '../../models/url_scan_result.dart';
import '../../services/security_provider.dart';
import '../qr_scanner/qr_scanner_screen.dart';

class UrlScannerScreen extends StatefulWidget {
  final String? initialUrl;

  const UrlScannerScreen({super.key, this.initialUrl});

  @override
  State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  UrlScanResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _performScan();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _performScan() async {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final provider = context.read<SecurityProvider>();
      final res = await provider.scanUrl(text);
      setState(() {
        _result = res;
      });
    } catch (_) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openSafeUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<SecurityProvider>().urlHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Havola va fishing tekshiruvi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: "QR koddan o'qish",
            onPressed: () async {
              final scannedUrl = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
              if (scannedUrl != null && scannedUrl.isNotEmpty) {
                _urlController.text = scannedUrl;
                _performScan();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Input Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Veb-sayt yoki havola manzilini kiriting:",
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: "https://misol-sayt.uz yoki telegram...",
                      prefixIcon: const Icon(Icons.link, color: AppTheme.accentCyan),
                      suffixIcon: _urlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _urlController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    onSubmitted: (_) => _performScan(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _performScan,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDark),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isLoading ? "Tahlil qilinmoqda..." : "Havolani tekshirish"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCyan,
                            foregroundColor: AppTheme.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final scannedUrl = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                          );
                          if (scannedUrl != null && scannedUrl.isNotEmpty) {
                            _urlController.text = scannedUrl;
                            _performScan();
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner, color: AppTheme.accentCyan),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceDark,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Scan Result Card
            if (_result != null) ...[
              _buildResultCard(_result!),
              const SizedBox(height: 20),
            ],

            // History Section
            if (history.isNotEmpty) ...[
              const Text(
                "Oxirgi tekshirilgan havolalar",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              ...history.take(5).map((item) => _buildHistoryItem(item)),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(UrlScanResult res) {
    final riskColor = Color(res.riskLevel.colorValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: riskColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.riskLevel.labelUz,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    Text(
                      res.domain,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          _buildRow("To'liq manzil", res.originalUrl),
          _buildRow("HTTPS shifrlash", res.isHttps ? "Mavjud (Xavfsiz ulanish)" : "Mavjud emas (Oddiy HTTP)"),
          if (res.finalUrl != null)
            _buildRow("Yakuniy manzil (Redirect)", res.finalUrl!),
          _buildRow("Tahlil vaqti", "${res.scanTime.hour}:${res.scanTime.minute.toString().padLeft(2, '0')}"),

          const SizedBox(height: 12),

          // Findings List
          if (res.findings.isNotEmpty) ...[
            const Text(
              "Aniqlangan belgilar:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            ...res.findings.map((f) {
              final col = Color(f.severity.colorValue);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, size: 16, color: col),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
                          Text(f.description, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],

          // Recommendation Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: riskColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    res.recommendation,
                    style: TextStyle(fontSize: 11, color: riskColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Open URL Button (Safe Browsing Mode confirmation)
          ElevatedButton.icon(
            onPressed: () => _openSafeUrl(res.originalUrl),
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: Text(res.riskLevel == RiskLevel.critical ? "Xavfga qaramasdan ochish" : "Havolani ochish"),
            style: ElevatedButton.styleFrom(
              backgroundColor: res.riskLevel == RiskLevel.critical ? AppTheme.accentRed : AppTheme.accentCyan,
              foregroundColor: res.riskLevel == RiskLevel.critical ? Colors.white : AppTheme.primaryDark,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(UrlScanResult item) {
    final color = Color(item.riskLevel.colorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.public, color: color, size: 20),
        title: Text(
          item.domain,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          item.originalUrl,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            item.riskLevel.labelUz,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          setState(() {
            _urlController.text = item.originalUrl;
            _result = item;
          });
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
