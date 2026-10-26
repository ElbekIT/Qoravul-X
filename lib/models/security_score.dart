import 'dart:math' as math;

class SecurityScore {
  final int overallScore;
  final int appSecurityScore;
  final int permissionPrivacyScore;
  final int linkProtectionScore;
  final int systemConfigScore;
  final DateTime calculatedAt;
  final int checksCompleted;
  final int checksTotal;
  final bool scanComplete;
  final List<ScoreComponent> components;

  SecurityScore({
    required this.overallScore,
    required this.appSecurityScore,
    required this.permissionPrivacyScore,
    required this.linkProtectionScore,
    required this.systemConfigScore,
    required this.calculatedAt,
    required this.checksCompleted,
    required this.checksTotal,
    required this.scanComplete,
    required this.components,
  });

  double get completionPercentage => 
      checksTotal > 0 ? (checksCompleted / checksTotal) * 100 : 0;

  String get statusTextUz {
    if (!scanComplete) return 'Tekshiruv tugallanmagan';
    if (overallScore >= 90) return 'Telefoningiz xavfsiz holatda';
    if (overallScore >= 70) return "Ba'zi xavfsizlik xavflari bor";
    if (overallScore >= 50) return 'Xavfsizlik muammolari aniqlandi';
    if (overallScore >= 30) return "Jiddiy xavfsizlik xavflari mavjud";
    return 'Kritik xavfsizlik muammolari!';
  }

  String get statusTextRu {
    if (!scanComplete) return 'Проверка не завершена';
    if (overallScore >= 90) return 'Телефон в безопасном состоянии';
    if (overallScore >= 70) return 'Есть некоторые риски безопасности';
    if (overallScore >= 50) return 'Обнаружены проблемы безопасности';
    if (overallScore >= 30) return 'Серьёзные угрозы безопасности';
    return 'Критические проблемы безопасности!';
  }

  factory SecurityScore.initial() => SecurityScore(
    overallScore: 0,
    appSecurityScore: 0,
    permissionPrivacyScore: 0,
    linkProtectionScore: 0,
    systemConfigScore: 0,
    calculatedAt: DateTime.now(),
    checksCompleted: 0,
    checksTotal: 0,
    scanComplete: false,
    components: [],
  );
}

class ScoreComponent {
  final String name;
  final String description;
  final int pointsDeducted;
  final int maxPoints;
  final String category;
  final String evidence;

  ScoreComponent({
    required this.name,
    required this.description,
    required this.pointsDeducted,
    required this.maxPoints,
    required this.category,
    required this.evidence,
  });

  int get score => math.max(0, maxPoints - pointsDeducted);
}
