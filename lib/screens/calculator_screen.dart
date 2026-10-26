import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:in_app_update/in_app_update.dart';
import '../models/calculator_model.dart';
import '../themes/app_theme.dart';
import '../utils/app_localizations.dart';
import '../utils/audio_feedback.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_panel.dart';
import 'converter_view.dart';
import 'finance_view.dart';
import 'programmer_view.dart';
import 'smart_tools_view.dart';
import 'history_sheet.dart';
import '../utils/privacy_policy.dart';

enum AppMode {
  calculator,
  converter,
  finance,
  smartTools,
  programmer,
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorModel _calc = CalculatorModel();
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batterySubscription;

  ThemeType _currentTheme = ThemeType.amoledDark;
  AppMode _currentMode = AppMode.calculator;
  bool _isScientificExpanded = false;
  bool _isVoiceOn = true;

  int _batteryPercent = 100;
  bool _isCharging = false;
  bool _batteryWarningDismissed = false;

  AppPalette get _palette => AppTheme.palettes[_currentTheme]!;

  @override
  void initState() {
    super.initState();
    AudioFeedback.isVoiceEnabled = _isVoiceOn;
    _initBattery();
    _checkForPlayStoreUpdate();
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }

  // Google Play In-App Update tekshiruvchisi
  Future<void> _checkForPlayStoreUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Agar yangi versiya chiqsa, ekranda avtomatik yangilash oynasi chiqadi
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (_) {
      // Test rejimida yoki Play Store dan yuklanmagan bo'lsa xato bermaydi
    }
  }

  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryPercent = level;
        });
      }

      _batterySubscription = _battery.onBatteryStateChanged.listen((state) async {
        final currentLevel = await _battery.batteryLevel;
        if (mounted) {
          setState(() {
            _batteryPercent = currentLevel;
            _isCharging = (state == BatteryState.charging || state == BatteryState.full);
            if (currentLevel > 20) {
              _batteryWarningDismissed = false;
            }
          });
        }
      });
    } catch (_) {}
  }

  void _onButtonPress(String label) {
    AudioFeedback.playTap(label);

    setState(() {
      switch (label) {
        case 'AC':
        case 'C':
          _calc.clear();
          break;
        case '⌫':
          _calc.backspace();
          break;
        case '+/-':
          _calc.toggleSign();
          break;
        case '%':
          _calc.percentage();
          break;
        case '=':
          _calc.calculate();
          if (_calc.hasError) {
            AudioFeedback.playError();
          } else {
            AudioFeedback.playResult();
          }
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
        case '^':
          _calc.inputOperator(label);
          break;
        case 'sin':
        case 'cos':
        case 'tan':
        case 'ln':
        case 'log':
        case '√':
          _calc.inputFunction(label);
          break;
        case '(':
        case ')':
          _calc.inputParenthesis(label);
          break;
        case 'π':
        case 'e':
          _calc.inputConstant(label);
          break;
        case 'RAD':
        case 'DEG':
          _calc.toggleRadDeg();
          break;
        case 'x!':
          _calc.inputDigit('!');
          break;
        default:
          _calc.inputDigit(label);
          break;
      }
    });
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceOn = !_isVoiceOn;
      AudioFeedback.isVoiceEnabled = _isVoiceOn;
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isVoiceOn ? AppStrings.tr('voiceOn') : AppStrings.tr('voiceOff')),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _palette.bgCard,
      ),
    );
  }

  void _showBatteryInfo() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🔋 Batareya: $_batteryPercent% ${_isCharging ? '⚡' : ''}"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _palette.bgCard,
      ),
    );
  }

  void _shareReceiptToTelegram() {
    if (_calc.history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hisoblar tarixi bo'sh"), duration: Duration(seconds: 1)),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln("🧾 *ALGORIX HISOB CHEKI*");
    buffer.writeln("📅 Sana: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}");
    buffer.writeln("--------------------------");
    for (var item in _calc.history) {
      buffer.writeln("${item.expression} = *${item.result}*");
    }
    buffer.writeln("--------------------------");
    buffer.writeln("🚀 ALGORIX ilovasi orqali hisoblandi");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.tr('receiptCopied')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _palette.accent,
      ),
    );
  }

  void _openLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _palette.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _palette.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tilni tanlang / Выберите язык / Select Language",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _palette.displayText),
            ),
            const SizedBox(height: 16),
            _buildLangTile("🇺🇿 O'zbekcha", AppLanguage.uz),
            _buildLangTile("🇷🇺 Русский", AppLanguage.ru),
            _buildLangTile("🇬🇧 English", AppLanguage.en),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTile(String title, AppLanguage lang) {
    final isSel = AppStrings.currentLang == lang;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: isSel ? _palette.accent.withOpacity(0.15) : null,
      title: Text(title, style: TextStyle(color: _palette.displayText, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
      trailing: isSel ? Icon(Icons.check, color: _palette.accent) : null,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => AppStrings.currentLang = lang);
        Navigator.pop(context);
      },
    );
  }

  void _openHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => HistorySheet(
        history: _calc.history,
        palette: _palette,
        onSelect: (val) {
          setState(() {
            _calc.inputDigit(val);
          });
        },
        onClear: () {
          setState(() {
            _calc.clearHistory();
          });
        },
      ),
    );
  }

  void _openThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _palette.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _palette.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr('theme'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _palette.displayText,
              ),
            ),
            const SizedBox(height: 16),
            ...ThemeType.values.map((t) {
              final pal = AppTheme.palettes[t]!;
              final isSel = _currentTheme == t;
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isSel ? pal.accent.withOpacity(0.15) : null,
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: pal.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  pal.name,
                  style: TextStyle(
                    color: _palette.displayText,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSel ? Icon(Icons.check, color: pal.accent) : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentTheme = t);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openAboutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _palette.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _palette.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _palette.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.calculate, color: _palette.accent, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              "ALGORIX",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: _palette.displayText,
              ),
            ),
            Text(
              "Version 1.0.0",
              style: TextStyle(
                fontSize: 12,
                color: _palette.displaySubText,
              ),
            ),
            const SizedBox(height: 20),
            PrivacyPolicyService.buildTile(
              context: context,
              iconColor: _palette.accent,
              textColor: _palette.displayText,
              tileColor: _palette.bgCard,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildBatteryWarningBanner(),
            _buildAppBar(),
            Expanded(child: _buildCurrentModeContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryWarningBanner() {
    if (_batteryPercent > 20 || _isCharging || _batteryWarningDismissed) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: const Color(0xFFEF4444).withOpacity(0.9),
      child: Row(
        children: [
          const Icon(Icons.battery_alert, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Zaryad $_batteryPercent%! ${AppStrings.tr('batteryWarn')}",
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _batteryWarningDismissed = true),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Brand Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ALGORIX",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: _palette.displayText,
                ),
              ),
              Text(
                _getModeTitle(_currentMode),
                style: TextStyle(
                  fontSize: 11,
                  color: _palette.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Language Selector Button (UZ / RU / EN)
          GestureDetector(
            onTap: _openLanguageSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _palette.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _palette.divider.withOpacity(0.4)),
              ),
              child: Text(
                AppStrings.currentLang == AppLanguage.uz ? "UZ" : (AppStrings.currentLang == AppLanguage.ru ? "RU" : "EN"),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _palette.accent),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Real-time Battery Status Icon
          GestureDetector(
            onTap: _showBatteryInfo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _palette.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _batteryPercent <= 20 ? const Color(0xFFEF4444) : _palette.divider.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCharging
                        ? Icons.battery_charging_full
                        : (_batteryPercent <= 20 ? Icons.battery_alert : Icons.battery_std),
                    size: 15,
                    color: _batteryPercent <= 20 ? const Color(0xFFEF4444) : _palette.accent,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "$_batteryPercent%",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _batteryPercent <= 20 ? const Color(0xFFEF4444) : _palette.displayText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Voice Toggle
          IconButton(
            icon: Icon(
              _isVoiceOn ? Icons.volume_up : Icons.volume_off,
              color: _isVoiceOn ? _palette.accent : _palette.displaySubText,
              size: 22,
            ),
            tooltip: "Ovozli rejim",
            onPressed: _toggleVoice,
          ),

          // Telegram Receipt Share
          IconButton(
            icon: Icon(Icons.receipt_long, color: _palette.displaySubText, size: 22),
            tooltip: "Chek nusxalash",
            onPressed: _shareReceiptToTelegram,
          ),

          // Scientific Toggle
          if (_currentMode == AppMode.calculator)
            IconButton(
              icon: Icon(
                _isScientificExpanded ? Icons.functions : Icons.calculate_outlined,
                color: _isScientificExpanded ? _palette.accent : _palette.displaySubText,
                size: 22,
              ),
              tooltip: "Ilmiy kalkulyator",
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isScientificExpanded = !_isScientificExpanded);
              },
            ),

          // History
          IconButton(
            icon: Icon(Icons.history, color: _palette.displaySubText, size: 22),
            tooltip: "Tarix",
            onPressed: _openHistory,
          ),

          // Theme Switcher
          IconButton(
            icon: Icon(Icons.palette_outlined, color: _palette.displaySubText, size: 22),
            tooltip: AppStrings.tr('theme'),
            onPressed: _openThemeSelector,
          ),

          // About & Privacy Policy
          IconButton(
            icon: Icon(Icons.info_outline, color: _palette.displaySubText, size: 22),
            tooltip: AppStrings.tr('aboutApp'),
            onPressed: _openAboutModal,
          ),
        ],
      ),
    );
  }

  String _getModeTitle(AppMode mode) {
    switch (mode) {
      case AppMode.calculator:
        return _isScientificExpanded ? AppStrings.tr('scientific') : AppStrings.tr('standard');
      case AppMode.converter:
        return AppStrings.tr('converter');
      case AppMode.finance:
        return AppStrings.tr('finance');
      case AppMode.smartTools:
        return AppStrings.tr('smartTools');
      case AppMode.programmer:
        return AppStrings.tr('programmer');
    }
  }

  Widget _buildCurrentModeContent() {
    return Column(
      children: [
        // Mode Selector Bar (Pills)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _palette.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _palette.divider.withOpacity(0.3)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModePill(AppStrings.tr('calculator'), AppMode.calculator, Icons.calculate),
                _buildModePill(AppStrings.tr('smartTools'), AppMode.smartTools, Icons.auto_awesome),
                _buildModePill(AppStrings.tr('converter'), AppMode.converter, Icons.swap_horiz),
                _buildModePill(AppStrings.tr('finance'), AppMode.finance, Icons.trending_up),
                _buildModePill(AppStrings.tr('programmer'), AppMode.programmer, Icons.code),
              ],
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Main View with Animated Transition
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _currentMode == AppMode.calculator
                ? _buildCalculatorLayout()
                : (_currentMode == AppMode.smartTools
                    ? SmartToolsView(key: const ValueKey('smartTools'), palette: _palette)
                    : (_currentMode == AppMode.converter
                        ? ConverterView(key: const ValueKey('converter'), palette: _palette)
                        : (_currentMode == AppMode.finance
                            ? FinanceView(key: const ValueKey('finance'), palette: _palette)
                            : ProgrammerView(key: const ValueKey('programmer'), palette: _palette)))),
          ),
        ),
      ],
    );
  }

  Widget _buildModePill(String title, AppMode mode, IconData icon) {
    final isSel = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? _palette.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSel ? Colors.white : _palette.displaySubText),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                color: isSel ? Colors.white : _palette.displaySubText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorLayout() {
    return Column(
      key: const ValueKey('calculatorLayout'),
      children: [
        // Display Panel
        Expanded(
          flex: _isScientificExpanded ? 3 : 4,
          child: DisplayPanel(
            expression: _calc.expression,
            display: _calc.display,
            livePreview: _calc.livePreview,
            lastFullExpression: _calc.lastFullExpression,
            hasError: _calc.hasError,
            palette: _palette,
            onBackspace: () => _onButtonPress('⌫'),
          ),
        ),

        // Scientific Expandable Panel
        if (_isScientificExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: _palette.bgSecondary,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              childAspectRatio: 2.0,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSciBtn(_calc.isRadians ? "RAD" : "DEG"),
                _buildSciBtn("sin"),
                _buildSciBtn("cos"),
                _buildSciBtn("tan"),
                _buildSciBtn("π"),
                _buildSciBtn("ln"),
                _buildSciBtn("log"),
                _buildSciBtn("√"),
                _buildSciBtn("^"),
                _buildSciBtn("e"),
                _buildSciBtn("("),
                _buildSciBtn(")"),
                _buildSciBtn("x!"),
                _buildSciBtn("%"),
                _buildSciBtn("⌫"),
              ],
            ),
          ),

        // Main Keypad Area
        Expanded(
          flex: _isScientificExpanded ? 5 : 6,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: _palette.bgSecondary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: _buildMainKeypad(),
          ),
        ),
      ],
    );
  }

  Widget _buildSciBtn(String label) {
    return CalcButton(
      label: label,
      variant: ButtonVariant.scientific,
      palette: _palette,
      fontSize: 13,
      onPressed: () => _onButtonPress(label),
    );
  }

  Widget _buildMainKeypad() {
    final List<List<Map<String, dynamic>>> rows = [
      [
        {'label': 'AC', 'variant': ButtonVariant.action},
        {'label': '( )', 'variant': ButtonVariant.action, 'action': '('},
        {'label': '%', 'variant': ButtonVariant.action},
        {'label': '÷', 'variant': ButtonVariant.operator},
      ],
      [
        {'label': '7', 'variant': ButtonVariant.number},
        {'label': '8', 'variant': ButtonVariant.number},
        {'label': '9', 'variant': ButtonVariant.number},
        {'label': '×', 'variant': ButtonVariant.operator},
      ],
      [
        {'label': '4', 'variant': ButtonVariant.number},
        {'label': '5', 'variant': ButtonVariant.number},
        {'label': '6', 'variant': ButtonVariant.number},
        {'label': '-', 'variant': ButtonVariant.operator},
      ],
      [
        {'label': '1', 'variant': ButtonVariant.number},
        {'label': '2', 'variant': ButtonVariant.number},
        {'label': '3', 'variant': ButtonVariant.number},
        {'label': '+', 'variant': ButtonVariant.operator},
      ],
      [
        {'label': '+/-', 'variant': ButtonVariant.number},
        {'label': '0', 'variant': ButtonVariant.number},
        {'label': '.', 'variant': ButtonVariant.number},
        {'label': '=', 'variant': ButtonVariant.equal},
      ],
    ];

    return Column(
      children: rows.map((row) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: row.map((btn) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CalcButton(
                      label: btn['label'] as String,
                      variant: btn['variant'] as ButtonVariant,
                      palette: _palette,
                      onPressed: () => _onButtonPress(
                        btn['action'] != null ? btn['action'] as String : btn['label'] as String,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
