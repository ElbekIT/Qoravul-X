import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';

class PermissionHubScreen extends StatefulWidget {
  final bool isOnboarding;

  const PermissionHubScreen({super.key, this.isOnboarding = false});

  @override
  State<PermissionHubScreen> createState() => _PermissionHubScreenState();
}

class _PermissionHubScreenState extends State<PermissionHubScreen> with WidgetsBindingObserver {
  bool _storageGranted = false;
  bool _overlayGranted = false;
  bool _smsGranted = false;
  bool _notificationGranted = false;
  bool _cameraGranted = false;
  bool _batteryGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);

    final storage = await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted;
    final overlay = await Permission.systemAlertWindow.isGranted;
    final sms = await Permission.sms.isGranted;
    final notification = await Permission.notification.isGranted;
    final camera = await Permission.camera.isGranted;
    final battery = await Permission.ignoreBatteryOptimizations.isGranted;

    if (mounted) {
      setState(() {
        _storageGranted = storage;
        _overlayGranted = overlay;
        _smsGranted = sms;
        _notificationGranted = notification;
        _cameraGranted = camera;
        _batteryGranted = battery;
        _isLoading = false;
      });
    }
  }

  int get _grantedCount {
    int count = 0;
    if (_storageGranted) count++;
    if (_overlayGranted) count++;
    if (_smsGranted) count++;
    if (_notificationGranted) count++;
    if (_cameraGranted) count++;
    if (_batteryGranted) count++;
    return count;
  }

  int get _totalCount => 6;

  double get _protectionPercent => (_grantedCount / _totalCount) * 100;

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    await _checkAllPermissions();
  }

  Future<void> _grantAllPermissions() async {
    await Permission.notification.request();
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    await Permission.systemAlertWindow.request();
    await Permission.sms.request();
    await Permission.camera.request();
    await Permission.ignoreBatteryOptimizations.request();
    await _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isOnboarding,
        title: Text(widget.isOnboarding ? "Xush kelibsiz — Qoravul X" : "Xavfsizlik Ruxsatlari Markazi"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isOnboarding)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: AppTheme.accentCyan, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Qoravul X telefoningizni Telegram, SMS va yuklamalardagi troyan hamda fishing xavflaridan 100% himoya qilishi uchun ushbu ruxsatlarni faollashtiring.",
                              style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Protection Score Banner
                  _buildProtectionBanner(),

                  const SizedBox(height: 20),

                  const Text(
                    "REAL VAQT HIMOYA RUXSATLARI",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Qoravul X telefoningizni to'liq skanerlashi va Telegram, SMS hamda yuklamalardagi xavflarni to'xtatishi uchun quyidagi ruxsatlar zarur:",
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),

                  const SizedBox(height: 16),

                  // 1. Storage & APK Inspection
                  _buildPermissionTile(
                    title: "Barcha fayllarni himoyalash",
                    subtitle:
                        "Telegram, WhatsApp va Yuklamalar (Downloads) papkalaridagi yangi APK fayllarni chuqur skanerlash va viruslardan tozalash.",
                    icon: Icons.folder_shared_outlined,
                    isGranted: _storageGranted,
                    onTap: () => _requestPermission(Permission.manageExternalStorage),
                  ),

                  // 2. Overlay / Pop-up Alerts
                  _buildPermissionTile(
                    title: "Boshqa ilovalar ustidan ogohlantirish",
                    subtitle:
                        "Telegram yoki brauzerda xavfli dastur o'rnatilmoqchi bo'lganda, ekranning ustida darhol Qizil Qalqon xavf oynasini chiqarish.",
                    icon: Icons.layers_outlined,
                    isGranted: _overlayGranted,
                    onTap: () => _requestPermission(Permission.systemAlertWindow),
                  ),

                  // 3. SMS Phishing Filter
                  _buildPermissionTile(
                    title: "SMS xavfsizligi va Fishing filtri",
                    subtitle:
                        "\"Kartangiz bloklandi\" yoki \"Yutuq yutdingiz\" kabi soxta bank xabarlarini va shubhali havolalarni avtomatik ushlash.",
                    icon: Icons.sms_outlined,
                    isGranted: _smsGranted,
                    onTap: () => _requestPermission(Permission.sms),
                  ),

                  // 4. Notifications
                  _buildPermissionTile(
                    title: "Zudlik bilan bildirishnomalar",
                    subtitle:
                        "Telefonda yangi xavf yoki shubhali fayl tushganda, kechiktirmasdan xavfsizlik signalini yuborish.",
                    icon: Icons.notifications_active_outlined,
                    isGranted: _notificationGranted,
                    onTap: () => _requestPermission(Permission.notification),
                  ),

                  // 5. Background Protection / Battery
                  _buildPermissionTile(
                    title: "24/7 Doimiy fon himoyasi",
                    subtitle:
                        "Android tizimi Qoravul X dasturini xotiradan yopib yubormasligi va telefonni doimiy qo'riqlab turishi uchun batareya cheklovini yechish.",
                    icon: Icons.battery_charging_full_outlined,
                    isGranted: _batteryGranted,
                    onTap: () => _requestPermission(Permission.ignoreBatteryOptimizations),
                  ),

                  // 6. Camera (QR Scanner)
                  _buildPermissionTile(
                    title: "Kamera (QR-kod tekshiruvi)",
                    subtitle:
                        "Kafelar, do'konlar va ko'chadagi QR-kodlar orqali tarqaluvchi fishing havolalarni xavfsiz skanerlash.",
                    icon: Icons.qr_code_scanner_outlined,
                    isGranted: _cameraGranted,
                    onTap: () => _requestPermission(Permission.camera),
                  ),

                  const SizedBox(height: 20),

                  // Global Action Button
                  if (_grantedCount < _totalCount)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _grantAllPermissions,
                      icon: const Icon(Icons.shield, color: Colors.black),
                      label: const Text(
                        "Barcha ruxsatlarni faollashtirish",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.white12),
                    ),
                    onPressed: openAppSettings,
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text("Tizim sozlamalarini ochish"),
                  ),

                  if (widget.isOnboarding) ...[
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('has_completed_permission_hub', true);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Himoyani boshlash (Asosiy ekranga o'tish)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildProtectionBanner() {
    final isFull = _grantedCount == _totalCount;
    final color = isFull
        ? AppTheme.accentGreen
        : (_protectionPercent >= 50 ? AppTheme.accentAmber : AppTheme.accentRed);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFull ? Icons.verified_user : Icons.gpp_maybe,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFull ? "To'liq himoyalangan (100%)" : "Himoya darajasi: ${_protectionPercent.toInt()}%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFull
                      ? "Barcha xavfsizlik qalqonlari faol. Telefon to'liq nazorat ostida."
                      : "$_grantedCount / $_totalCount ta ruxsat yoqilgan. Maksimal xavfsizlik uchun qolganlarini ham yoqing.",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    final statusColor = isGranted ? AppTheme.accentGreen : AppTheme.accentAmber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGranted ? statusColor.withValues(alpha: 0.3) : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isGranted ? Icons.check_circle : Icons.warning_amber_rounded,
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isGranted ? "Faol va himoyalangan" : "Ruxsat berilmagan",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isGranted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onTap,
                    child: const Text(
                      "Yoqish",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const Icon(Icons.check, color: AppTheme.accentGreen),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
