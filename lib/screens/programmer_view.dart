import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/programmer_model.dart';
import '../themes/app_theme.dart';

class ProgrammerView extends StatefulWidget {
  final AppPalette palette;

  const ProgrammerView({super.key, required this.palette});

  @override
  State<ProgrammerView> createState() => _ProgrammerViewState();
}

class _ProgrammerViewState extends State<ProgrammerView> {
  final ProgrammerModel _model = ProgrammerModel();
  String _input = "0";

  void _onDigit(String d) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_input == "0") {
        _input = d;
      } else {
        if (_input.length < 15) _input += d;
      }
      _model.inputDec(_input);
    });
  }

  void _onClear() {
    HapticFeedback.lightImpact();
    setState(() {
      _input = "0";
      _model.clear();
    });
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_input.length <= 1) {
        _input = "0";
      } else {
        _input = _input.substring(0, _input.length - 1);
      }
      _model.inputDec(_input);
    });
  }

  void _onBitwiseNot() {
    HapticFeedback.selectionClick();
    setState(() {
      _model.bitwiseNot();
      _input = _model.dec;
    });
  }

  void _onShiftLeft() {
    HapticFeedback.selectionClick();
    setState(() {
      _model.shiftLeft(1);
      _input = _model.dec;
    });
  }

  void _onShiftRight() {
    HapticFeedback.selectionClick();
    setState(() {
      _model.shiftRight(1);
      _input = _model.dec;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Number representations display card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.palette.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.palette.divider.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              _buildRepRow("DEC", _model.dec, isPrimary: true),
              const Divider(),
              _buildRepRow("HEX", "0x${_model.hex}"),
              const Divider(),
              _buildRepRow("OCT", "0o${_model.oct}"),
              const Divider(),
              _buildRepRow("BIN", _model.bin),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Bitwise buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildBitwiseBtn("NOT", _onBitwiseNot),
              const SizedBox(width: 8),
              _buildBitwiseBtn("<< 1", _onShiftLeft),
              const SizedBox(width: 8),
              _buildBitwiseBtn(">> 1", _onShiftRight),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Keypad for programmer
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNumBtn("7"),
                _buildNumBtn("8"),
                _buildNumBtn("9"),
                _buildNumBtn("4"),
                _buildNumBtn("5"),
                _buildNumBtn("6"),
                _buildNumBtn("1"),
                _buildNumBtn("2"),
                _buildNumBtn("3"),
                _buildNumBtn("C", isAction: true, onTap: _onClear),
                _buildNumBtn("0"),
                _buildNumBtn("⌫", isAction: true, onTap: _onBackspace),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPrimary ? widget.palette.accent : widget.palette.displaySubText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isPrimary ? 22 : 16,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                color: isPrimary ? widget.palette.displayText : widget.palette.displaySubText,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBitwiseBtn(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: widget.palette.actionBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.palette.divider.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: widget.palette.actionText),
          ),
        ),
      ),
    );
  }

  Widget _buildNumBtn(String text, {bool isAction = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _onDigit(text),
      child: Container(
        decoration: BoxDecoration(
          color: isAction ? widget.palette.actionBg : widget.palette.numberBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.palette.divider.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isAction ? widget.palette.actionText : widget.palette.numberText,
          ),
        ),
      ),
    );
  }
}
