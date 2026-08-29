# IDIN — I Do It Now

## Proje Özeti

**IDIN** (I Do It Now), kullanıcıların ne *planladıklarını* değil ne *yaptıklarını* kayıt altına almasını sağlayan minimal bir zaman takip uygulamasıdır. Tagline: *"Not what you planned. What you did."*

İki ayrı native uygulama olarak geliştirilmiştir:
- **macOS uygulaması** — Daima ekranda kalan, hafif bir floating widget
- **iOS uygulaması** — iPhone için tam ekran companion app

Her ikisi de birbirleriyle **iCloud Key-Value Store** aracılığıyla gerçek zamanlı senkronize olur.

---

## Teknik Stack

| Katman | Teknoloji |
|---|---|
| Dil | Swift 5.9+ |
| UI Framework | SwiftUI |
| Gözlemlenebilirlik | `@Observable` (Swift 5.9 macro) |
| Takvim | EventKit (`EKEventStore`) |
| Senkronizasyon | `NSUbiquitousKeyValueStore` (iCloud KV) |
| Mimari | Single-source-of-truth, iki bağımsız target |

---

## Proje Yapısı

```
işwidget.xcodeproj
├── işwidget/                    ← macOS target
│   ├── ContentView.swift
│   ├── CalendarManager.swift
│   ├── SyncManager.swift
│   ├── AppSettings.swift
│   ├── SettingsView.swift
│   └── is_widgetApp.swift
│
└── işwidget iOS/                ← iOS target
    ├── ContentView.swift
    ├── CalendarManager.swift
    ├── SyncManager.swift
    ├── SettingsView.swift
    └── is_widget_iOSApp.swift
```

Her iki target ayrı Swift dosyalarına sahiptir. Paylaşılan kod yoktur — bilinçli bir tercih, platform farklılıklarını net tutmak için.

---

## Temel Bileşenler

### `SyncManager` (her iki platform)
- `NSUbiquitousKeyValueStore` üzerinden çalışan görev senkronizasyonu
- `RunningTaskInfo` adlı `Codable` struct: `text`, `startTime`, `calendarIdentifier`
- iCloud değişiklik bildirimi: `NSUbiquitousKeyValueStore.didChangeExternallyNotification`
- `startTask()` → KV store'a yazar, `stopTask()` → siler
- KV store key'leri: `iswidget_runningTask`, `iswidget_lastTaskText`

### `CalendarManager` (her iki platform)
- `EKEventStore` ile EventKit entegrasyonu
- `requestFullAccessToEvents()` async ile izin yönetimi
- Yalnızca `allowsContentModifications == true` olan takvimler listelenir
- Seçili takvim `UserDefaults`'a kaydedilir
- `createEvent()` ile başlangıç/bitiş saatli EventKit etkinliği oluşturur

### `AppSettings` (yalnızca macOS)
- `@Observable` class
- Ayarlar: `appName` (String), `headerColor` (SwiftUI Color), `themeName` (String)
- `AppTheme` enum: `.indigo`, `.ocean`, `.sunset` — her birinin SwiftUI accent rengi var
- Ayarlar `UserDefaults`'a serialize edilir

---

## Kullanıcı Akışı

```
[Kullanıcı metin girer]
        ↓
[Start'a basar]
        ↓
[SyncManager.startTask() → iCloud KV Store'a yazar]
        ↓
[Her iki platform eş zamanlı timer gösterir]
        ↓
[Herhangi bir platformdan Done'a basar]
        ↓
[platform.CalendarManager.createEvent() → EventKit'e kaydeder]
        ↓
[SyncManager.stopTask() → KV Store'dan siler]
        ↓
[Diğer platform iCloud bildirimiyle idle'a döner]
```

**Önemli:** Her platform, görev sonlandırılırken kendi `selectedCalendar`'ını kullanır. iCloud ve macOS arasında aynı takvim için farklı `calendarIdentifier` üretildiğinden, platform-agnostic ID yerine yerel seçim tercih edilmektedir.

---

## macOS Uygulaması Detayları

- **Floating widget**: `window.level = .floating`, tüm Space'lerde görünür
- **Boyut**: Sabit 320pt genişlik, içeriğe göre yükseklik
- **Başlık çubuğu**: Gizli (`hiddenTitleBar`), pencere arka planından sürüklenebilir
- **Kapatma koruması**: Kırmızı X ve Cmd+Q'da NSAlert onay dialogu — çalışan görev varken yanlışlıkla kapanmayı önler
- **Header**: Canlı saat, uygulama adı, takvim seçici, ayarlar (⚙)
- **Ayarlar Sheet**: App adı, header rengi, 3 tema (Indigo/Ocean/Sunset)

---

## iOS Uygulaması Detayları

- **NavigationStack** tabanlı tam ekran uygulama
- **Toolbar**: Ortada IDIN logosu (30pt bold + "I Do It Now" subtitle), sağda ⚙ butonu
- **Idle ekranı**: Büyük dijital saat (72pt thin), tarih, tagline, son görev hatırlatıcısı, görev giriş kartı
- **Running ekranı**: Görev adı, elapsed timer (56pt monospaced, kırmızı), Done butonu
- **Settings Sheet**:
  - Takvim seçimi (renkli göstergelerle)
  - 3 renk teması (swatch seçici)
  - Arkadaşa paylaş (UIActivityViewController)
- **Tema**: `@AppStorage("iOSTheme")` ile kalıcı, seçilen tema rengi Start butonuna yansır

---

## iCloud Entitlements

Her iki target da aynı KV Store container'ını paylaşır:

```
com.apple.developer.ubiquity-kvstore-identifier = $(TeamIdentifierPrefix)PIXLORD.is-widget
```

---

## App Store Hedefleri

- **macOS**: Mac App Store (sandbox etkin, calendar entitlement mevcut)
- **iOS**: App Store (iPhone, iOS 16+)
- **Bundle prefix**: `PIXLORD`
- **Geliştirici**: Erdem Özden (`erdem.ozden@visiott.com`)
