enum AppLanguage { uz, ru, en }

class AppStrings {
  static AppLanguage currentLang = AppLanguage.uz;

  static const Map<String, Map<AppLanguage, String>> _localized = {
    'calculator': {
      AppLanguage.uz: 'Kalkulyator',
      AppLanguage.ru: 'Калькулятор',
      AppLanguage.en: 'Calculator',
    },
    'smartTools': {
      AppLanguage.uz: 'Aqlli Vositalar',
      AppLanguage.ru: 'Умные Инструменты',
      AppLanguage.en: 'Smart Tools',
    },
    'converter': {
      AppLanguage.uz: 'Birliklar',
      AppLanguage.ru: 'Конвертер',
      AppLanguage.en: 'Converter',
    },
    'finance': {
      AppLanguage.uz: 'Moliya',
      AppLanguage.ru: 'Финансы',
      AppLanguage.en: 'Finance',
    },
    'programmer': {
      AppLanguage.uz: 'Dasturchi',
      AppLanguage.ru: 'Программист',
      AppLanguage.en: 'Programmer',
    },
    'standard': {
      AppLanguage.uz: 'Standart',
      AppLanguage.ru: 'Стандартный',
      AppLanguage.en: 'Standard',
    },
    'scientific': {
      AppLanguage.uz: 'Ilmiy Muhandislik',
      AppLanguage.ru: 'Научный',
      AppLanguage.en: 'Scientific',
    },
    'history': {
      AppLanguage.uz: 'Hisoblar tarixi',
      AppLanguage.ru: 'История расчетов',
      AppLanguage.en: 'Calculation History',
    },
    'clear': {
      AppLanguage.uz: 'Tozalash',
      AppLanguage.ru: 'Очистить',
      AppLanguage.en: 'Clear',
    },
    'theme': {
      AppLanguage.uz: 'Mavzuni tanlang',
      AppLanguage.ru: 'Выберите тему',
      AppLanguage.en: 'Select Theme',
    },
    'voiceOn': {
      AppLanguage.uz: 'Ovozli rejim YOQILDI',
      AppLanguage.ru: 'Голосовой режим ВКЛЮЧЕН',
      AppLanguage.en: 'Voice mode ON',
    },
    'voiceOff': {
      AppLanguage.uz: 'Ovozli rejim O\'CHIRILDI',
      AppLanguage.ru: 'Голосовой режим ВЫКЛЮЧЕН',
      AppLanguage.en: 'Voice mode OFF',
    },
    'receiptCopied': {
      AppLanguage.uz: 'Chek nusxalandi! Telegramga yuborishingiz mumkin.',
      AppLanguage.ru: 'Чек скопирован! Можете отправить в Telegram.',
      AppLanguage.en: 'Receipt copied! You can share to Telegram.',
    },
    'batteryWarn': {
      AppLanguage.uz: 'Quvvatni tejash rejimi yoqildi.',
      AppLanguage.ru: 'Включен режим энергосбережения.',
      AppLanguage.en: 'Power saving mode enabled.',
    },
    'currencyRates': {
      AppLanguage.uz: 'Valyuta kursi (Jonli)',
      AppLanguage.ru: 'Курс валют (Онлайн)',
      AppLanguage.en: 'Exchange Rates (Live)',
    },
    'marketTrade': {
      AppLanguage.uz: 'Bozor & Savdo',
      AppLanguage.ru: 'Рынок & Торговля',
      AppLanguage.en: 'Market & Trade',
    },
    'fuelTrip': {
      AppLanguage.uz: 'Yoqilg\'i & Yo\'l',
      AppLanguage.ru: 'Топливо & Поездка',
      AppLanguage.en: 'Fuel & Trip',
    },
    'inWords': {
      AppLanguage.uz: 'So\'z bilan',
      AppLanguage.ru: 'Прописью',
      AppLanguage.en: 'In Words',
    },
    'studentGpa': {
      AppLanguage.uz: 'Talaba GPA',
      AppLanguage.ru: 'GPA Студента',
      AppLanguage.en: 'Student GPA',
    },
    'brainQuiz': {
      AppLanguage.uz: 'Aql charxi',
      AppLanguage.ru: 'Тренажер ума',
      AppLanguage.en: 'Brain Quiz',
    },
    'privacyPolicy': {
      AppLanguage.uz: 'Maxfiylik siyosati',
      AppLanguage.ru: 'Политика конфиденциальности',
      AppLanguage.en: 'Privacy Policy',
    },
    'aboutApp': {
      AppLanguage.uz: 'Ilova haqida',
      AppLanguage.ru: 'О приложении',
      AppLanguage.en: 'About App',
    },
  };

  static String tr(String key) {
    if (_localized.containsKey(key)) {
      return _localized[key]![currentLang] ?? key;
    }
    return key;
  }
}
