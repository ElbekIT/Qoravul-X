import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/finance_model.dart';
import '../themes/app_theme.dart';

enum FinanceSubTab { loan, discount, tip, age }

class FinanceView extends StatefulWidget {
  final AppPalette palette;

  const FinanceView({super.key, required this.palette});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  FinanceSubTab _subTab = FinanceSubTab.loan;

  // Loan inputs
  final _loanPrincipalCtrl = TextEditingController(text: "10000000");
  final _loanRateCtrl = TextEditingController(text: "24");
  final _loanMonthsCtrl = TextEditingController(text: "12");
  LoanResult? _loanResult;

  // Discount inputs
  final _discPriceCtrl = TextEditingController(text: "500000");
  final _discPercentCtrl = TextEditingController(text: "20");
  DiscountResult? _discResult;

  // Tip inputs
  final _tipBillCtrl = TextEditingController(text: "200000");
  final _tipPercentCtrl = TextEditingController(text: "10");
  final _tipPeopleCtrl = TextEditingController(text: "4");
  TipResult? _tipResult;

  // Age input
  DateTime _selectedBirthDate = DateTime(2000, 1, 1);
  AgeResult? _ageResult;

  @override
  void initState() {
    super.initState();
    _calcAll();
  }

  void _calcAll() {
    // 1. Loan
    final p = double.tryParse(_loanPrincipalCtrl.text) ?? 0;
    final r = double.tryParse(_loanRateCtrl.text) ?? 0;
    final m = int.tryParse(_loanMonthsCtrl.text) ?? 1;
    _loanResult = FinanceModel.calculateLoan(principal: p, annualRatePercent: r, months: m);

    // 2. Discount
    final orig = double.tryParse(_discPriceCtrl.text) ?? 0;
    final dp = double.tryParse(_discPercentCtrl.text) ?? 0;
    _discResult = FinanceModel.calculateDiscount(originalPrice: orig, discountPercent: dp);

    // 3. Tip
    final b = double.tryParse(_tipBillCtrl.text) ?? 0;
    final tp = double.tryParse(_tipPercentCtrl.text) ?? 0;
    final ppl = int.tryParse(_tipPeopleCtrl.text) ?? 1;
    _tipResult = FinanceModel.calculateTip(billAmount: b, tipPercent: tp, splitCount: ppl);

    // 4. Age
    _ageResult = FinanceModel.calculateAge(_selectedBirthDate);
  }

  String _formatSum(double val) {
    String intStr = val.toInt().toString();
    String res = '';
    int count = 0;
    for (int i = intStr.length - 1; i >= 0; i--) {
      res = intStr[i] + res;
      count++;
      if (count % 3 == 0 && i > 0) res = ' ' + res;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SubTabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTabBtn("Kredit", FinanceSubTab.loan),
              const SizedBox(width: 6),
              _buildTabBtn("Chegirma", FinanceSubTab.discount),
              const SizedBox(width: 6),
              _buildTabBtn("Choypuli", FinanceSubTab.tip),
              const SizedBox(width: 6),
              _buildTabBtn("Yosh", FinanceSubTab.age),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSubTabContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBtn(String label, FinanceSubTab tab) {
    final isSel = _subTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _subTab = tab;
            _calcAll();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? widget.palette.accent : widget.palette.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.palette.divider.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              color: isSel ? Colors.white : widget.palette.displayText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabContent() {
    switch (_subTab) {
      case FinanceSubTab.loan:
        return _buildLoanTab();
      case FinanceSubTab.discount:
        return _buildDiscountTab();
      case FinanceSubTab.tip:
        return _buildTipTab();
      case FinanceSubTab.age:
        return _buildAgeTab();
    }
  }

  // 1. LOAN TAB
  Widget _buildLoanTab() {
    return Column(
      children: [
        _buildInputField("Kredit summasi (so'm)", _loanPrincipalCtrl),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInputField("Yillik foiz (%)", _loanRateCtrl)),
            const SizedBox(width: 10),
            Expanded(child: _buildInputField("Muddat (oy)", _loanMonthsCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        if (_loanResult != null) ...[
          _buildResultCard([
            _buildResultRow("Oylik to'lov", "${_formatSum(_loanResult!.monthlyPayment)} so'm", isBold: true),
            const Divider(),
            _buildResultRow("Ortiqcha foiz to'lovi", "${_formatSum(_loanResult!.totalInterest)} so'm"),
            const Divider(),
            _buildResultRow("Jami to'lov", "${_formatSum(_loanResult!.totalPayment)} so'm"),
          ]),
        ],
      ],
    );
  }

  // 2. DISCOUNT TAB
  Widget _buildDiscountTab() {
    return Column(
      children: [
        _buildInputField("Mahsulotning asl narxi", _discPriceCtrl),
        const SizedBox(height: 10),
        _buildInputField("Chegirma foizi (%)", _discPercentCtrl),
        const SizedBox(height: 16),
        if (_discResult != null) ...[
          _buildResultCard([
            _buildResultRow("Yakuniy narx", "${_formatSum(_discResult!.finalPrice)} so'm", isBold: true),
            const Divider(),
            _buildResultRow("Tejashingiz", "${_formatSum(_discResult!.savedAmount)} so'm", color: const Color(0xFF10B981)),
          ]),
        ],
      ],
    );
  }

  // 3. TIP / BILL SPLIT
  Widget _buildTipTab() {
    return Column(
      children: [
        _buildInputField("Umumiy hisob summasi", _tipBillCtrl),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInputField("Choypuli (%)", _tipPercentCtrl)),
            const SizedBox(width: 10),
            Expanded(child: _buildInputField("Odamlar soni", _tipPeopleCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        if (_tipResult != null) ...[
          _buildResultCard([
            _buildResultRow("Har bir kishi to'laydi", "${_formatSum(_tipResult!.perPerson)} so'm", isBold: true),
            const Divider(),
            _buildResultRow("Choypuli summasi", "${_formatSum(_tipResult!.tipAmount)} so'm"),
            const Divider(),
            _buildResultRow("Jami to'lov", "${_formatSum(_tipResult!.totalWithTip)} so'm"),
          ]),
        ],
      ],
    );
  }

  // 4. AGE / DATE
  Widget _buildAgeTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.palette.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.palette.divider.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tug'ilgan sana:",
                style: TextStyle(fontSize: 15, color: widget.palette.displayText),
              ),
              TextButton(
                onPressed: () async {
                  final dt = await showDatePicker(
                    context: context,
                    initialDate: _selectedBirthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (dt != null) {
                    setState(() {
                      _selectedBirthDate = dt;
                      _calcAll();
                    });
                  }
                },
                child: Text(
                  "${_selectedBirthDate.day}.${_selectedBirthDate.month}.${_selectedBirthDate.year}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.palette.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_ageResult != null) ...[
          _buildResultCard([
            _buildResultRow("Sizning yoshingiz", "${_ageResult!.years} yosh, ${_ageResult!.months} oy, ${_ageResult!.days} kun", isBold: true),
            const Divider(),
            _buildResultRow("Yashagan umumiy kunlaringiz", "${_formatSum(_ageResult!.totalDays.toDouble())} kun"),
            const Divider(),
            _buildResultRow("Keyingi tug'ilgan kungacha", "${_ageResult!.daysToNextBirthday} kun qoldi", color: widget.palette.accent),
          ]),
        ],
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: widget.palette.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.palette.divider.withOpacity(0.4)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 16, color: widget.palette.displayText, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, color: widget.palette.displaySubText),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (_) => setState(_calcAll),
      ),
    );
  }

  Widget _buildResultCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.palette.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.palette.accent.withOpacity(0.3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: widget.palette.displaySubText)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 17 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? widget.palette.displayText,
            ),
          ),
        ],
      ),
    );
  }
}
