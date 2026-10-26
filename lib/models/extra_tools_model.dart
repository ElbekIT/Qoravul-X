class MarketItemCalc {
  static double calcWeightPrice({
    required double pricePerKg,
    required double grams,
  }) {
    if (pricePerKg <= 0 || grams <= 0) return 0;
    return (pricePerKg / 1000.0) * grams;
  }

  static double calcPiecePrice({
    required double pricePerPiece,
    required int count,
  }) {
    if (pricePerPiece <= 0 || count <= 0) return 0;
    return pricePerPiece * count;
  }
}

class FuelCalc {
  static double calcTripCost({
    required double distanceKm,
    required double consumptionPer100Km,
    required double fuelPrice,
  }) {
    if (distanceKm <= 0 || consumptionPer100Km <= 0 || fuelPrice <= 0) return 0;
    final totalFuel = (distanceKm / 100.0) * consumptionPer100Km;
    return totalFuel * fuelPrice;
  }
}

class GpaItem {
  final String name;
  final int credits;
  final double grade;

  GpaItem({required this.name, required this.credits, required this.grade});
}

class GpaCalc {
  static double calculateGpa(List<GpaItem> items) {
    if (items.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;

    for (var item in items) {
      totalPoints += (item.grade * item.credits);
      totalCredits += item.credits;
    }

    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }
}

class NumberToWordsUz {
  static final List<String> _units = [
    '', 'bir', 'ikki', 'uch', 'to\'rt', 'besh', 'olti', 'yetti', 'sakkiz', 'to\'qqiz'
  ];
  static final List<String> _tens = [
    '', 'o\'n', 'yigirma', 'o\'ttiz', 'qirq', 'ellik', 'oltmish', 'yetmish', 'sakson', 'to\'qson'
  ];
  static final List<String> _scales = ['', 'ming', 'million', 'milliard', 'trillion'];

  static String convert(int number) {
    if (number == 0) return 'nol';
    if (number < 0) return 'minus ${convert(-number)}';

    String words = '';
    int scaleIndex = 0;

    while (number > 0) {
      int chunk = number % 1000;
      if (chunk != 0) {
        String chunkWords = _convertChunk(chunk);
        if (_scales[scaleIndex].isNotEmpty) {
          words = '$chunkWords ${_scales[scaleIndex]} $words';
        } else {
          words = '$chunkWords $words';
        }
      }
      number ~/= 1000;
      scaleIndex++;
    }

    return words.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _convertChunk(int number) {
    String words = '';
    int hundreds = number ~/ 100;
    int remainder = number % 100;

    if (hundreds > 0) {
      words += '${_units[hundreds]} yuz ';
    }

    int tens = remainder ~/ 10;
    int units = remainder % 10;

    if (tens > 0) {
      words += '${_tens[tens]} ';
    }
    if (units > 0) {
      words += '${_units[units]} ';
    }

    return words.trim();
  }
}

class MathQuizGenerator {
  final int a;
  final int b;
  final String op;
  final int correct;

  MathQuizGenerator({
    required this.a,
    required this.b,
    required this.op,
    required this.correct,
  });

  factory MathQuizGenerator.randomQuestion(int difficulty) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final r1 = (now % 20) + 1;
    final r2 = ((now ~/ 10) % 15) + 1;
    final opCode = (now ~/ 100) % 3;

    if (opCode == 0) {
      return MathQuizGenerator(a: r1, b: r2, op: '+', correct: r1 + r2);
    } else if (opCode == 1) {
      final big = r1 >= r2 ? r1 : r2;
      final small = r1 < r2 ? r1 : r2;
      return MathQuizGenerator(a: big, b: small, op: '-', correct: big - small);
    } else {
      final num1 = (now % 10) + 2;
      final num2 = ((now ~/ 5) % 9) + 2;
      return MathQuizGenerator(a: num1, b: num2, op: '×', correct: num1 * num2);
    }
  }
}
