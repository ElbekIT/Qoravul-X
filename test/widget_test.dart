import 'package:flutter_test/flutter_test.dart';
import 'package:y_calc/models/calculator_model.dart';
import 'package:y_calc/models/extra_tools_model.dart';
import 'package:y_calc/utils/app_localizations.dart';

void main() {
  group('Advanced Calculator Tests', () {
    test('Matematik amallar tartibi va qavslar', () {
      final calc = CalculatorModel();
      calc.inputDigit('2');
      calc.inputOperator('+');
      calc.inputDigit('2');
      calc.inputOperator('×');
      calc.inputDigit('2');
      calc.calculate();
      // 2 + 2 * 2 = 6 bo'lishi kerak
      expect(calc.display, '6');
    });
  });

  group('Extra Tools Tests (without GPA)', () {
    test('Bozor narxi hisoblash', () {
      final price = MarketItemCalc.calcWeightPrice(pricePerKg: 100000, grams: 250);
      expect(price, 25000);
    });

    test('Yoqilg\'i xarajati', () {
      final cost = FuelCalc.calcTripCost(distanceKm: 200, consumptionPer100Km: 8, fuelPrice: 10000);
      expect(cost, 160000);
    });
  });
}
