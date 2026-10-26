import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_theme.dart';

class DisplayPanel extends StatelessWidget {
  final String expression;
  final String display;
  final String livePreview;
  final String lastFullExpression;
  final bool hasError;
  final AppPalette palette;
  final VoidCallback onBackspace;

  const DisplayPanel({
    super.key,
    required this.expression,
    required this.display,
    required this.livePreview,
    required this.lastFullExpression,
    required this.hasError,
    required this.palette,
    required this.onBackspace,
  });

  double _getFontSize(String text) {
    if (text.length <= 6) return 56;
    if (text.length <= 9) return 46;
    if (text.length <= 12) return 38;
    if (text.length <= 16) return 30;
    return 24;
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: display));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Nusxa olindi: $display"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.bgCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Chapga yoki o'ngga surilsa - o'chirish (backspace)
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
          HapticFeedback.selectionClick();
          onBackspace();
        }
      },
      onLongPress: () => _copyToClipboard(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: palette.bgPrimary,
          border: Border(
            bottom: BorderSide(color: palette.divider.withOpacity(0.4), width: 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Oxirgi hisob ifodasi
            if (lastFullExpression.isNotEmpty)
              Text(
                lastFullExpression,
                style: TextStyle(
                  fontSize: 16,
                  color: palette.displaySubText.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 4),

            // Asosiy kiritilayotgan ifoda yoki raqam
            Text(
              display,
              style: TextStyle(
                fontSize: _getFontSize(display),
                fontWeight: FontWeight.w400,
                color: hasError ? const Color(0xFFEF4444) : palette.displayText,
                letterSpacing: -0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),

            // Jonli hisoblash natijasi (Live Preview)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: livePreview.isNotEmpty ? 28 : 8,
              alignment: Alignment.centerRight,
              child: livePreview.isNotEmpty
                  ? Text(
                      "= $livePreview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: palette.accent,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
