enum RiskLevel {
  safe,
  low,
  medium,
  high,
  critical,
  unknown;

  String get labelUz {
    switch (this) {
      case RiskLevel.safe: return 'Xavfsiz';
      case RiskLevel.low: return 'Past xavf';
      case RiskLevel.medium: return "O'rtacha xavf";
      case RiskLevel.high: return 'Yuqori xavf';
      case RiskLevel.critical: return 'Juda xavfli';
      case RiskLevel.unknown: return "Noma'lum";
    }
  }

  String get labelRu {
    switch (this) {
      case RiskLevel.safe: return 'Безопасно';
      case RiskLevel.low: return 'Низкий риск';
      case RiskLevel.medium: return 'Средний риск';
      case RiskLevel.high: return 'Высокий риск';
      case RiskLevel.critical: return 'Критический';
      case RiskLevel.unknown: return 'Неизвестно';
    }
  }

  String get labelEn {
    switch (this) {
      case RiskLevel.safe: return 'Safe';
      case RiskLevel.low: return 'Low Risk';
      case RiskLevel.medium: return 'Medium Risk';
      case RiskLevel.high: return 'High Risk';
      case RiskLevel.critical: return 'Critical';
      case RiskLevel.unknown: return 'Unknown';
    }
  }

  int get colorValue {
    switch (this) {
      case RiskLevel.safe: return 0xFF00E676;
      case RiskLevel.low: return 0xFF66BB6A;
      case RiskLevel.medium: return 0xFFFFB300;
      case RiskLevel.high: return 0xFFFF5722;
      case RiskLevel.critical: return 0xFFF44336;
      case RiskLevel.unknown: return 0xFF9E9E9E;
    }
  }

  int get sortOrder {
    switch (this) {
      case RiskLevel.critical: return 0;
      case RiskLevel.high: return 1;
      case RiskLevel.medium: return 2;
      case RiskLevel.low: return 3;
      case RiskLevel.safe: return 4;
      case RiskLevel.unknown: return 5;
    }
  }
}
