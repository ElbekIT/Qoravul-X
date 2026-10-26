# Qoravul X — Maximum Security 🛡️
> **"Telefoningiz xavfsizligi — har bir tekshiruvda."**

Qoravul X — Android qurilmalari uchun mo'ljallangan, yuqori darajadagi xavfsizlik, ilovalar tahlili, nozik ruxsatlar auditi, zararli APK larni aniqlash va fishing veb-saytlaridan himoya qiluvchi to'liq tizim.

---

## 🚀 Asosiy imkoniyatlar

### 1. Telefon xavfsizligi indeksi (0 — 100 ball)
- **Hech qanday tasodifiy yoki uydirma sonlarsiz**: Har bir ball Android tizimining rasmiy API'lari orqali olingan aniq ma'lumotlarga tayanadi.
- **5 ta alohida ko'rsatkich**:
  1. Umumiy telefon xavfsizligi
  2. O'rnatilgan dasturlar xavfsizligi
  3. Nozik ruxsatlar va maxfiylik
  4. Havolalar va fishingdan himoya
  5. Tizim va qurilma konfiguratsiyasi
- **Shaffof ball modeli**: Har bir ayirib tashlangan ballning aniq sababi va dalili ko'rsatiladi.

### 2. O'rnatilgan dasturlar skaneri
- Barcha o'rnatilgan ilovalarning xulq-atvori, imzolari va so'ralgan ruxsatlari tahlili.
- O'rnatish manbasini aniqlash (Google Play Store, F-Droid yoki Noma'lum manbalar / brauzer yuklamalari).
- Xavf darajasi tasnifi: **Juda xavfli**, **Yuqori xavf**, **O'rtacha xavf**, **Past xavf**, **Xavfsiz**.
- Har bir ilova uchun batafsil xavfsizlik hisoboti va Android rasmiy dialogi orqali o'chirish.

### 3. Xavfli dasturlar bo'limi
- Tasdiqlangan zararli dasturlar (Malware), yuqori xavfli va shubhali ilovalarning yagona nazorat markazi.
- Maxfiylikni saqlagan holda hisobotni eksport qilish imkoniyati.

### 4. Telegram va Fayllar APK tahlili ("Scan-before-install")
- Telegram yoki fayl menejerlaridan **"Share / Open with Qoravul X"** orqali ulashilgan APK larni o'rnatishdan oldin tahlil qilish.
- Faylning SHA-256 xeshini hisoblash va ma'lum troyanlar/josuslik dasturlari bazasi bilan solishtirish.
- Raqamli imzo haqiqiyligini tekshirish.
- Foydalanuvchi roziligisiz hech qanday APK o'rnatilmaydi yoki ishga tushirilmaydi.

### 5. Havola va Fishing (URL) tekshiruvi
- Soxta bank (Uzcard, Humo, Payme, Click) sahifalarini va firibgarlik domenlarini aniqlash.
- Gomografik hujumlar (lotin va kirill harflarini aralashtirib yozilgan soxta domenlar) tahlili.
- IP-manzilli va shubhali ko'p pog'onali subdomenlarni aniqlash.
- Xavfsiz brauzer rejimi (Safe Browsing Mode).

### 6. QR Kod xavfsiz skaneri
- QR kod tarkibidagi havolalarni avtomatik ochmasdan, xavfsizlik tahlilidan o'tkazish.

### 7. Maxfiylik va Ruxsatlar auditi
- SMS, Kamera, Mikrofon, Aniq joylashuv, Maxsus imkoniyatlar (Accessibility), Bildirishnomalar va Qurilma ma'muri huquqlarini chuqur tahlil qilish.
- O'zbek tilida tushunarli tushuntirishlar.

---

## 🔒 Maxfiylik va Xavfsizlik qoidalari
- **100% lokal tahlil**: Telefoningizdagi shaxsiy yozishmalar, fotosuratlar yoki kontaktlar tashqi serverlarga yuklanmaydi.
- **Ruxsatsiz harakat qilinmaydi**: Ilovalarni o'chirish yoki sozlamalarni o'zgartirish har doim foydalanuvchi tasdig'i orqali amalga oshiriladi.
- **Mutlaq 100% da'vo qilinmaydi**: Qoravul X o'tkazilgan tekshiruvlar qamrovini shaffof ko'rsatadi.

---

## 🛠️ Loyihani yig'ish (Build & Delivery)

### Talablar:
- Flutter SDK 3.0.0+
- Java 17
- Android SDK 36 (minSdk 21)

### Release APK yig'ish:
```bash
flutter build apk --release
```

### Google Play App Bundle (.aab) yig'ish:
```bash
flutter build appbundle --release
```

Yig'ilgan fayl: `build/app/outputs/bundle/release/app-release.aab`
Yuklash kaliti: `android/app/upload-keystore.jks` (`key.properties` bilan sozlangan).
