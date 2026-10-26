import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculator_model.dart';
import '../themes/app_theme.dart';

class HistorySheet extends StatelessWidget {
  final List<HistoryItem> history;
  final AppPalette palette;
  final Function(String) onSelect;
  final VoidCallback onClear;

  const HistorySheet({
    super.key,
    required this.history,
    required this.palette,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.bgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: palette.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hisoblar tarixi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: palette.displayText,
                ),
              ),
              if (history.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onClear();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                  label: const Text(
                    "Tozalash",
                    style: TextStyle(color: Color(0xFFEF4444)),
                  ),
                ),
            ],
          ),
          const Divider(),

          // History items list
          history.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: palette.displaySubText.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      Text(
                        "Hozircha tarix bo'sh",
                        style: TextStyle(color: palette.displaySubText),
                      ),
                    ],
                  ),
                )
              : Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => Divider(color: palette.divider.withOpacity(0.3)),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.expression,
                          style: TextStyle(
                            fontSize: 15,
                            color: palette.displaySubText,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Text(
                          "= ${item.result}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: palette.accent,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelect(item.result);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
