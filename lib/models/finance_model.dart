import 'dart:math' as math;

class LoanResult {
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;

  LoanResult({
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
  });
}

class DiscountResult {
  final double savedAmount;
  final double finalPrice;

  DiscountResult({
    required this.savedAmount,
    required this.finalPrice,
  });
}

class TipResult {
  final double tipAmount;
  final double totalWithTip;
  final double perPerson;

  TipResult({
    required this.tipAmount,
    required this.totalWithTip,
    required this.perPerson,
  });
}

class AgeResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int daysToNextBirthday;

  AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.daysToNextBirthday,
  });
}

class FinanceModel {
  static LoanResult calculateLoan({
    required double principal,
    required double annualRatePercent,
    required int months,
  }) {
    if (principal <= 0 || months <= 0) {
      return LoanResult(monthlyPayment: 0, totalPayment: 0, totalInterest: 0);
    }

    if (annualRatePercent == 0) {
      final monthly = principal / months;
      return LoanResult(
        monthlyPayment: monthly,
        totalPayment: principal,
        totalInterest: 0,
      );
    }

    final double monthlyRate = (annualRatePercent / 100.0) / 12.0;
    final double factor = math.pow(1 + monthlyRate, months).toDouble();
    final double monthlyPayment = principal * (monthlyRate * factor) / (factor - 1);
    final double totalPayment = monthlyPayment * months;
    final double totalInterest = totalPayment - principal;

    return LoanResult(
      monthlyPayment: monthlyPayment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
    );
  }

  static DiscountResult calculateDiscount({
    required double originalPrice,
    required double discountPercent,
  }) {
    if (originalPrice <= 0) return DiscountResult(savedAmount: 0, finalPrice: 0);
    final double saved = originalPrice * (discountPercent / 100.0);
    final double finalPrice = originalPrice - saved;
    return DiscountResult(savedAmount: saved, finalPrice: finalPrice);
  }

  static TipResult calculateTip({
    required double billAmount,
    required double tipPercent,
    required int splitCount,
  }) {
    if (billAmount <= 0) return TipResult(tipAmount: 0, totalWithTip: 0, perPerson: 0);
    final int people = splitCount < 1 ? 1 : splitCount;
    final double tip = billAmount * (tipPercent / 100.0);
    final double total = billAmount + tip;
    final double perPerson = total / people;
    return TipResult(tipAmount: tip, totalWithTip: total, perPerson: perPerson);
  }

  static AgeResult calculateAge(DateTime birthDate) {
    final DateTime now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      final prevMonthDays = DateTime(now.year, now.month, 0).day;
      days += prevMonthDays;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = now.difference(birthDate).inDays;

    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    final daysToNext = nextBirthday.difference(now).inDays;

    return AgeResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      daysToNextBirthday: daysToNext,
    );
  }
}
