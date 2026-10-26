import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sozlamalar va Maxfiylik"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Identity Card
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/qoravul_x_logo.jpg',
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppConstants.appTagline,
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Versiya: ${AppConstants.appVersion} (Build ${AppConstants.appVersionCode})",
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "MAXFIYLIK SIYOSATI (PRIVACY POLICY)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 10),

            _buildPrivacyCard(
              title: "1. Mahalliy (Offline) tahlil",
              content:
                  "Qoravul X ilovalarni, tizim ruxsatlarini va APK fayllarini tahlil qilishni 100% sizning telefoningizda (lokal tarzda) amalga oshiradi. Telefoningizdagi shaxsiy xabarlar, fotosuratlar, kontaktlar yoki fayllar hech qachon tashqi serverlarga yuklanmaydi.",
              icon: Icons.phonelink_lock,
            ),

            const SizedBox(height: 10),

            _buildPrivacyCard(
              title: "2. Internet talab qiluvchi funksiyalar",
              content:
                  "Faqatgina havolalarni (URL) fishing yoki zararli veb-saytlar bazasi bilan solishtirish hamda yangi kiberxavflar xesh-bazalarini tekshirish uchun internet ulanishidan foydalaniladi. Bunda hech qanday shaxsiy hisob ma'lumotlari uzatilmaydi.",
              icon: Icons.cloud_outlined,
            ),

            const SizedBox(height: 10),

            _buildPrivacyCard(
              title: "3. Haqiqiy va shaffof tahlil",
              content:
                  "Ilova soxta yashil qalqonlar yoki uydirma sonlardan foydalanmaydi. Har bir xavfsizlik bali Android tizimining rasmiy PackageManager API, KeyguardManager va sertifikat tekshiruvlarining aniq natijalariga asoslangan.",
              icon: Icons.verified_outlined,
            ),

            const SizedBox(height: 10),

            _buildPrivacyCard(
              title: "4. Foydalanuvchi to'liq nazorati",
              content:
                  "Qoravul X hech qachon sizning roziligingizsiz ilovalarni yashirincha o'chirmaydi yoki tizim sozlamalarini o'zboshimchalik bilan o'zgartirmaydi. O'chirish va sozlash har doim Android tizimining rasmiy tasdiqlash dialoglari orqali foydalanuvchi tomonidan tasdiqlanadi.",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 24),

            const Text(
              "Dasturchi: Qoravul X Security Team",
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppTheme.accentCyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
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
