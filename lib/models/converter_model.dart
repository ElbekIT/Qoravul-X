enum UnitCategory {
  length,
  mass,
  temperature,
  speed,
  storage,
}

class UnitItem {
  final String id;
  final String name;
  final double toBaseFactor;

  const UnitItem({
    required this.id,
    required this.name,
    required this.toBaseFactor,
  });
}

class ConverterModel {
  static const Map<UnitCategory, String> categoryNames = {
    UnitCategory.length: "Uzunlik",
    UnitCategory.mass: "Og'irlik",
    UnitCategory.temperature: "Harorat",
    UnitCategory.speed: "Tezlik",
    UnitCategory.storage: "Xotira / Fayl",
  };

  static const Map<UnitCategory, List<UnitItem>> units = {
    UnitCategory.length: [
      UnitItem(id: 'm', name: 'Metr (m)', toBaseFactor: 1.0),
      UnitItem(id: 'km', name: 'Kilometr (km)', toBaseFactor: 1000.0),
      UnitItem(id: 'cm', name: 'Santimetr (cm)', toBaseFactor: 0.01),
      UnitItem(id: 'mm', name: 'Millimetr (mm)', toBaseFactor: 0.001),
      UnitItem(id: 'inch', name: 'Dyuym (in)', toBaseFactor: 0.0254),
      UnitItem(id: 'ft', name: 'Fut (ft)', toBaseFactor: 0.3048),
      UnitItem(id: 'mi', name: 'Milya (mi)', toBaseFactor: 1609.344),
    ],
    UnitCategory.mass: [
      UnitItem(id: 'kg', name: 'Kilogramm (kg)', toBaseFactor: 1.0),
      UnitItem(id: 'g', name: 'Gramm (g)', toBaseFactor: 0.001),
      UnitItem(id: 'mg', name: 'Milligramm (mg)', toBaseFactor: 0.000001),
      UnitItem(id: 't', name: 'Tonna (t)', toBaseFactor: 1000.0),
      UnitItem(id: 'lb', name: 'Funt (lb)', toBaseFactor: 0.45359237),
      UnitItem(id: 'oz', name: 'Unsiya (oz)', toBaseFactor: 0.0283495),
    ],
    UnitCategory.temperature: [
      UnitItem(id: 'C', name: 'Selsiy (°C)', toBaseFactor: 1.0),
      UnitItem(id: 'F', name: 'Farengeyt (°F)', toBaseFactor: 1.0),
      UnitItem(id: 'K', name: 'Kelvin (K)', toBaseFactor: 1.0),
    ],
    UnitCategory.speed: [
      UnitItem(id: 'kmh', name: 'km / soat', toBaseFactor: 1.0),
      UnitItem(id: 'ms', name: 'm / sekund', toBaseFactor: 3.6),
      UnitItem(id: 'mph', name: 'mil / soat (mph)', toBaseFactor: 1.60934),
    ],
    UnitCategory.storage: [
      UnitItem(id: 'B', name: 'Bayt (B)', toBaseFactor: 1.0),
      UnitItem(id: 'KB', name: 'Kilobayt (KB)', toBaseFactor: 1024.0),
      UnitItem(id: 'MB', name: 'Megabayt (MB)', toBaseFactor: 1048576.0),
      UnitItem(id: 'GB', name: 'Gigabayt (GB)', toBaseFactor: 1073741824.0),
      UnitItem(id: 'TB', name: 'Terabayt (TB)', toBaseFactor: 1099511627776.0),
    ],
  };

  static double convert({
    required UnitCategory category,
    required double value,
    required UnitItem from,
    required UnitItem to,
  }) {
    if (from.id == to.id) return value;

    if (category == UnitCategory.temperature) {
      // Selsiyga o'tkazish
      double celsius;
      if (from.id == 'C') {
        celsius = value;
      } else if (from.id == 'F') {
        celsius = (value - 32) * 5 / 9;
      } else {
        celsius = value - 273.15;
      }

      // Selsiydan maqsad birlikka
      if (to.id == 'C') return celsius;
      if (to.id == 'F') return (celsius * 9 / 5) + 32;
      return celsius + 273.15;
    }

    // Boshqa o'lchovlar uchun proporsiya
    double baseValue = value * from.toBaseFactor;
    return baseValue / to.toBaseFactor;
  }
}
