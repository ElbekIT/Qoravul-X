import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/extra_tools_model.dart';
import '../themes/app_theme.dart';
import '../utils/app_localizations.dart';
import '../utils/currency_service.dart';

enum SmartToolType { currency, market, fuel, words, quiz }

class SmartToolsView extends StatefulWidget {
  final AppPalette palette;

  const SmartToolsView({super.key, required this.palette});

  @override
  State<SmartToolsView> createState() => _SmartToolsViewState();
}

class _SmartToolsViewState extends State<SmartToolsView> {
  SmartToolType _selectedTool = SmartToolType.currency;

  // Valyuta kurslari (Real-time online + offline backup)
  final _currAmountCtrl = TextEditingController(text: "100");
  String _fromCurr = "USD";
  String _toCurr = "UZS";
  double _currResult = 0;
  bool _isLoadingCurrency = false;

  // Bozor inputs
  final _marketPricePerKgCtrl = TextEditingController(text: "85000");
  final _marketGramsCtrl = TextEditingController(text: "350");
  double _marketWeightResult = 29750;

  // Yoqilg'i inputs
  final _fuelDistanceCtrl = TextEditingController(text: "300");
  final _fuelConsumpCtrl = TextEditingController(text: "8.5");
  final _fuelPriceCtrl = TextEditingController(text: "12500");
  double _fuelTotalCost = 318750;

  // Raqamni so'zga aylantirish
  final _numWordsCtrl = TextEditingController(text: "1500000");
  String _numWordsResult = "bir million besh yuz ming";

  // Aql charxi (Mini-game)
  MathQuizGenerator _quiz = MathQuizGenerator.randomQuestion(1);
  int _quizScore = 0;
  int _quizSecondsLeft = 30;
  Timer? _quizTimer;
  bool _isQuizRunning = false;
  final _quizAnswerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLiveCurrency();
    _recalcMarket();
    _recalcFuel();
    _recalcWords();
  }

  @override
  void dispose() {
    _quizTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLiveCurrency() async {
    setState(() => _isLoadingCurrency = true);
    await CurrencyService.fetchLiveRates();
    if (mounted) {
      setState(() {
        _isLoadingCurrency = false;
        _recalcCurrency();
      });
    }
  }

  void _recalcCurrency() {
    final amt = double.tryParse(_currAmountCtrl.text) ?? 0;
    final rateFrom = CurrencyService.ratesToUzs[_fromCurr] ?? 1.0;
    final rateTo = CurrencyService.ratesToUzs[_toCurr] ?? 1.0;
    setState(() {
      final inUzs = amt * rateFrom;
      _currResult = inUzs / rateTo;
    });
  }

  void _recalcMarket() {
    final p = double.tryParse(_marketPricePerKgCtrl.text) ?? 0;
    final g = double.tryParse(_marketGramsCtrl.text) ?? 0;
    setState(() {
      _marketWeightResult = MarketItemCalc.calcWeightPrice(pricePerKg: p, grams: g);
    });
  }

  void _recalcFuel() {
    final d = double.tryParse(_fuelDistanceCtrl.text) ?? 0;
    final c = double.tryParse(_fuelConsumpCtrl.text) ?? 0;
    final p = double.tryParse(_fuelPriceCtrl.text) ?? 0;
    setState(() {
      _fuelTotalCost = FuelCalc.calcTripCost(distanceKm: d, consumptionPer100Km: c, fuelPrice: p);
    });
  }

  void _recalcWords() {
    final num = int.tryParse(_numWordsCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() {
      _numWordsResult = NumberToWordsUz.convert(num);
    });
  }

  void _startQuiz() {
    _quizScore = 0;
    _quizSecondsLeft = 30;
    _isQuizRunning = true;
    _quiz = MathQuizGenerator.randomQuestion(1);
    _quizAnswerCtrl.clear();

    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_quizSecondsLeft <= 1) {
        t.cancel();
        setState(() => _isQuizRunning = false);
      } else {
        setState(() => _quizSecondsLeft--);
      }
    });
    setState(() {});
  }

  void _checkQuizAnswer() {
    final val = int.tryParse(_quizAnswerCtrl.text.trim());
    if (val == _quiz.correct) {
      HapticFeedback.lightImpact();
      _quizScore++;
      _quiz = MathQuizGenerator.randomQuestion(1);
      _quizAnswerCtrl.clear();
      setState(() {});
    }
  }

  String _formatNumber(double val) {
    if (val == val.truncateToDouble()) {
      return _formatWithSpaces(val.toInt().toString());
    }
    return val.toStringAsFixed(2);
  }

  String _formatWithSpaces(String s) {
    String res = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      res = s[i] + res;
      count++;
      if (count % 3 == 0 && i > 0) res = ' ' + res;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal tool selector (GPA siz, faqat kerakli 5 ta vosita)
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildToolChip(AppStrings.tr('currencyRates'), SmartToolType.currency, Icons.currency_exchange),
              _buildToolChip(AppStrings.tr('marketTrade'), SmartToolType.market, Icons.storefront),
              _buildToolChip(AppStrings.tr('fuelTrip'), SmartToolType.fuel, Icons.local_gas_station),
              _buildToolChip(AppStrings.tr('inWords'), SmartToolType.words, Icons.text_fields),
              _buildToolChip(AppStrings.tr('brainQuiz'), SmartToolType.quiz, Icons.sports_esports),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tool Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildToolBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildToolChip(String label, SmartToolType type, IconData icon) {
    final isSel = _selectedTool == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16, color: isSel ? Colors.white : widget.palette.displaySubText),
        label: Text(label),
        selected: isSel,
        selectedColor: widget.palette.accent,
        backgroundColor: widget.palette.bgCard,
        labelStyle: TextStyle(
          color: isSel ? Colors.white : widget.palette.displayText,
          fontSize: 12,
          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          HapticFeedback.selectionClick();
          setState(() => _selectedTool = type);
        },
      ),
    );
  }

  Widget _buildToolBody() {
    switch (_selectedTool) {
      case SmartToolType.currency:
        return _buildCurrencySection();
      case SmartToolType.market:
        return _buildMarketSection();
      case SmartToolType.fuel:
        return _buildFuelSection();
      case SmartToolType.words:
        return _buildWordsSection();
      case SmartToolType.quiz:
        return _buildQuizSection();
    }
  }

  // 1. REAL-TIME CURRENCY
  Widget _buildCurrencySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CurrencyService.lastUpdated,
              style: TextStyle(fontSize: 12, color: widget.palette.accent, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: _isLoadingCurrency
                  ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: widget.palette.accent))
                  : Icon(Icons.refresh, size: 18, color: widget.palette.accent),
              tooltip: "Yangilash",
              onPressed: _isLoadingCurrency ? null : _fetchLiveCurrency,
            ),
          ],
        ),
        _buildInputRow("Summa", _currAmountCtrl, _recalcCurrency),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.palette.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.palette.divider.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _fromCurr,
                dropdownColor: widget.palette.bgSecondary,
                underline: const SizedBox(),
                style: TextStyle(color: widget.palette.displayText, fontWeight: FontWeight.bold),
                items: CurrencyService.ratesToUzs.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _fromCurr = v);
                    _recalcCurrency();
                  }
                },
              ),
              Icon(Icons.arrow_forward, color: widget.palette.accent),
              DropdownButton<String>(
                value: _toCurr,
                dropdownColor: widget.palette.bgSecondary,
                underline: const SizedBox(),
                style: TextStyle(color: widget.palette.displayText, fontWeight: FontWeight.bold),
                items: CurrencyService.ratesToUzs.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _toCurr = v);
                    _recalcCurrency();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          "O'tkazma natijasi",
          "${_formatNumber(_currResult)} $_toCurr",
          sub: "1 USD = ${_formatNumber(CurrencyService.ratesToUzs['USD'] ?? 12850)} UZS",
        ),
      ],
    );
  }

  // 2. BOZOR
  Widget _buildMarketSection() {
    return Column(
      children: [
        _buildInputRow("1 kg narxi (so'm)", _marketPricePerKgCtrl, _recalcMarket),
        const SizedBox(height: 10),
        _buildInputRow("Og'irlik (gramm)", _marketGramsCtrl, _recalcMarket),
        const SizedBox(height: 16),
        _buildResultCard(
          "To'lanadigan summa",
          "${_formatNumber(_marketWeightResult)} so'm",
          sub: "${_marketGramsCtrl.text} gr uchun",
        ),
      ],
    );
  }

  // 3. FUEL
  Widget _buildFuelSection() {
    return Column(
      children: [
        _buildInputRow("Masofa (km)", _fuelDistanceCtrl, _recalcFuel),
        const SizedBox(height: 10),
        _buildInputRow("100 km sarfi (litr / kub)", _fuelConsumpCtrl, _recalcFuel),
        const SizedBox(height: 10),
        _buildInputRow("Yoqilg'i narxi (1 litr/kub so'm)", _fuelPriceCtrl, _recalcFuel),
        const SizedBox(height: 16),
        _buildResultCard(
          "Yo'l uchun jami xarajat",
          "${_formatNumber(_fuelTotalCost)} so'm",
          sub: "${((double.tryParse(_fuelDistanceCtrl.text) ?? 0) / 100 * (double.tryParse(_fuelConsumpCtrl.text) ?? 0)).toStringAsFixed(1)} litr yoqilg'i ketadi",
        ),
      ],
    );
  }

  // 4. NUMBER TO WORDS
  Widget _buildWordsSection() {
    return Column(
      children: [
        _buildInputRow("Raqamni kiriting", _numWordsCtrl, _recalcWords),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.palette.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.palette.accent.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("So'z bilan ifodasi:", style: TextStyle(fontSize: 12, color: widget.palette.displaySubText)),
              const SizedBox(height: 8),
              SelectableText(
                _numWordsResult,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.palette.displayText),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _numWordsResult));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nusxa olindi!"), duration: Duration(seconds: 1)),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text("Nusxa olish"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. QUIZ
  Widget _buildQuizSection() {
    return Column(
      children: [
        if (!_isQuizRunning)
          Center(
            child: Column(
              children: [
                Icon(Icons.timer_outlined, size: 50, color: widget.palette.accent),
                const SizedBox(height: 10),
                Text(
                  "30 soniyalik aql charxi!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.palette.displayText),
                ),
                const SizedBox(height: 6),
                Text(
                  "Tezkor matematik misollarni yechib ball to'plang",
                  style: TextStyle(fontSize: 13, color: widget.palette.displaySubText),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.palette.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _startQuiz,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("O'yinni boshlash"),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("⏱️ $_quizSecondsLeft soniya", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                  Text("🏆 Ball: $_quizScore", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.palette.accent)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "${_quiz.a} ${_quiz.op} ${_quiz.b} = ?",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: widget.palette.displayText),
              ),
              const SizedBox(height: 16),
              Container(
                width: 160,
                child: TextField(
                  controller: _quizAnswerCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.palette.displayText),
                  decoration: InputDecoration(
                    hintText: "Javob",
                    hintStyle: TextStyle(color: widget.palette.displaySubText),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onChanged: (_) => _checkQuizAnswer(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl, VoidCallback onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: widget.palette.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.palette.divider.withOpacity(0.3)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.palette.displayText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, color: widget.palette.displaySubText),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (_) => onChange(),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, {String? sub}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.palette.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.palette.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: widget.palette.displaySubText)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: widget.palette.accent),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 12, color: widget.palette.displaySubText)),
          ],
        ],
      ),
    );
  }
}
