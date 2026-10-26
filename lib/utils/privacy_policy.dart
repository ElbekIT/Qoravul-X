import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_localizations.dart';

class PrivacyPolicyService {
  /// Google Play Console va ilova uchun rasmiy Maxfiylik siyosati havolasi
  static const String privacyPolicyUrl =
      'https://doc-hosting.flycricket.io/algorix-privacy-policy/c4d08e27-947b-47ef-ab2d-2a19231d8522/privacy';

  /// Maxfiylik siyosati sahifasini tashqi brauzerda xavfsiz ochish funksiyasi
  static Future<bool> openPrivacyPolicy({BuildContext? context}) async {
    final Uri uri = Uri.parse(privacyPolicyUrl);

    try {
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return launched;
      } else {
        debugPrint('URL ochib bo\'lmadi: $privacyPolicyUrl');
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maxfiylik siyosatini ochishda xatolik yuz berdi.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('Maxfiylik siyosatini ochishda istisno: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Sozlamalar yoki "Ilova haqida" ekrani uchun chiroyli tayyor ListTile vidjeti
  static Widget buildTile({
    required BuildContext context,
    Color? iconColor,
    Color? textColor,
    Color? tileColor,
  }) {
    return ListTile(
      leading: Icon(
        Icons.privacy_tip_outlined,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        AppStrings.tr('privacyPolicy'),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: tileColor,
      onTap: () => openPrivacyPolicy(context: context),
    );
  }
}
