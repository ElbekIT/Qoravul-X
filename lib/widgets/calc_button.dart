import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_theme.dart';

enum ButtonVariant {
  number,
  operator,
  action,
  equal,
  scientific,
}

class CalcButton extends StatefulWidget {
  final String label;
  final ButtonVariant variant;
  final AppPalette palette;
  final VoidCallback onPressed;
  final double? fontSize;
  final Widget? customWidget;

  const CalcButton({
    super.key,
    required this.label,
    required this.variant,
    required this.palette,
    required this.onPressed,
    this.fontSize,
    this.customWidget,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    double radius = 20.0;
    Border? border;

    switch (widget.variant) {
      case ButtonVariant.equal:
        bg = widget.palette.equalBg;
        textColor = widget.palette.equalText;
        radius = 24.0;
        break;
      case ButtonVariant.operator:
        bg = widget.palette.operatorBg;
        textColor = widget.palette.operatorText;
        radius = 22.0;
        break;
      case ButtonVariant.action:
        bg = widget.palette.actionBg;
        textColor = widget.palette.actionText;
        radius = 20.0;
        break;
      case ButtonVariant.scientific:
        bg = widget.palette.bgCard;
        textColor = widget.palette.accent;
        radius = 16.0;
        break;
      case ButtonVariant.number:
      default:
        bg = widget.palette.numberBg;
        textColor = widget.palette.numberText;
        radius = 20.0;
        border = Border.all(color: widget.palette.divider.withOpacity(0.5), width: 1);
        break;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOutQuad,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          alignment: Alignment.center,
          child: widget.customWidget ??
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize ?? (widget.variant == ButtonVariant.scientific ? 16 : 24),
                  fontWeight: widget.variant == ButtonVariant.equal
                      ? FontWeight.bold
                      : (widget.variant == ButtonVariant.operator ? FontWeight.w600 : FontWeight.w500),
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
        ),
      ),
    );
  }
}
