import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/converter_model.dart';
import '../themes/app_theme.dart';

class ConverterView extends StatefulWidget {
  final AppPalette palette;

  const ConverterView({super.key, required this.palette});

  @override
  State<ConverterView> createState() => _ConverterViewState();
}

class _ConverterViewState extends State<ConverterView> {
  UnitCategory _selectedCategory = UnitCategory.length;
  late UnitItem _fromUnit;
  late UnitItem _toUnit;
  String _inputVal = "1";
  double _outputVal = 1.0;

  @override
  void initState() {
    super.initState();
    _resetUnits();
  }

  void _resetUnits() {
    final list = ConverterModel.units[_selectedCategory]!;
    _fromUnit = list[0];
    _toUnit = list.length > 1 ? list[1] : list[0];
    _recalc();
  }

  void _recalc() {
    final double? parsed = double.tryParse(_inputVal);
    if (parsed == null) {
      _outputVal = 0.0;
    } else {
      _outputVal = ConverterModel.convert(
        category: _selectedCategory,
        value: parsed,
        from: _fromUnit,
        to: _toUnit,
      );
    }
  }

  void _onDigit(String d) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_inputVal == "0" && d != ".") {
        _inputVal = d;
      } else if (d == "." && _inputVal.contains(".")) {
        return;
      } else {
        if (_inputVal.length < 12) _inputVal += d;
      }
      _recalc();
    });
  }

  void _onClear() {
    HapticFeedback.lightImpact();
    setState(() {
      _inputVal = "0";
      _recalc();
    });
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_inputVal.length <= 1) {
        _inputVal = "0";
      } else {
        _inputVal = _inputVal.substring(0, _inputVal.length - 1);
      }
      _recalc();
    });
  }

  void _swapUnits() {
    HapticFeedback.lightImpact();
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _recalc();
    });
  }

  String _formatResult(double val) {
    if (val == val.truncateToDouble() && val.abs() < 1e12) {
      return val.toInt().toString();
    }
    String s = val.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final unitList = ConverterModel.units[_selectedCategory]!;

    return Column(
      children: [
        // Category chips row
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: UnitCategory.values.map((cat) {
              final isSel = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(ConverterModel.categoryNames[cat]!),
                  selected: isSel,
                  selectedColor: widget.palette.accent,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : widget.palette.displayText,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  backgroundColor: widget.palette.bgCard,
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                        _resetUnits();
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Conversion display card
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
              // FROM row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<UnitItem>(
                    value: _fromUnit,
                    dropdownColor: widget.palette.bgSecondary,
                    underline: const SizedBox(),
                    style: TextStyle(color: widget.palette.displayText, fontSize: 16, fontWeight: FontWeight.w600),
                    items: unitList.map((u) {
                      return DropdownMenuItem(value: u, child: Text(u.name));
                    }).toList(),
                    onChanged: (newU) {
                      if (newU != null) {
                        setState(() {
                          _fromUnit = newU;
                          _recalc();
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      _inputVal,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: widget.palette.displayText),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Swap icon button
              Center(
                child: IconButton(
                  onPressed: _swapUnits,
                  icon: Icon(Icons.swap_vert, color: widget.palette.accent, size: 28),
                ),
              ),

              // TO row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<UnitItem>(
                    value: _toUnit,
                    dropdownColor: widget.palette.bgSecondary,
                    underline: const SizedBox(),
                    style: TextStyle(color: widget.palette.displayText, fontSize: 16, fontWeight: FontWeight.w600),
                    items: unitList.map((u) {
                      return DropdownMenuItem(value: u, child: Text(u.name));
                    }).toList(),
                    onChanged: (newU) {
                      if (newU != null) {
                        setState(() {
                          _toUnit = newU;
                          _recalc();
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      _formatResult(_outputVal),
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: widget.palette.accent),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Mini Numpad for Converter
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
