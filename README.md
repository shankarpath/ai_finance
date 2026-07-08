# AI Finance Assistant

A local-first Android app that reads bank transaction SMS, parses them, categorizes
spending, and shows a live dashboard. **All data stays on the device.**

This repo currently implements a **working vertical slice**:

```
Incoming/existing bank SMS
        │
        ▼
  SmsService (another_telephony)   → reads inbox + listens for new SMS
        │
        ▼
  ParserService (regex)            → amount, debit/credit, merchant,
        │                            account last-4, balance, payment method
        ▼
  CategorizerService (rule-based)  → Food / Shopping / Travel / … (offline, no AI)
        │
        ▼
  AppDatabase (Drift / SQLite)     → de-duplicated persistence
        │
        ▼
  Riverpod providers               → live derived stats
        │
        ▼
  DashboardScreen                  → today's spend, count, biggest expense, tx list
```

## Project structure

```
lib/
├── models/
│   ├── categories.dart          # Canonical categories + colors/icons
│   └── parsed_sms.dart          # Parser output value object
├── services/
│   ├── sms_service.dart         # Permissions + inbox read + live listen
│   ├── parser_service.dart      # Bank-SMS → structured data (the core)
│   ├── categorizer_service.dart # Merchant/keyword → category (offline rules)
│   ├── database_service.dart    # Drift tables + queries
│   └── database_service.g.dart  # Generated (build_runner)
├── repositories/
│   └── transaction_repository.dart  # SMS → parse → categorize → store pipeline
├── providers/
│   ├── app_providers.dart       # Riverpod wiring + permission controller
│   └── dashboard_stats.dart     # Derived today/week/month stats
├── screens/
│   ├── permission_screen.dart   # Consent + privacy explanation gate
│   └── dashboard_screen.dart    # Main dashboard
├── widgets/
│   ├── stat_card.dart
│   └── transaction_tile.dart
├── utils/
│   └── formatters.dart          # ₹ / date formatting (en_IN)
└── main.dart
test/
└── parser_service_test.dart     # 8 tests covering the parser + categorizer
```

## Tech stack

| Concern            | Choice                                  |
|--------------------|-----------------------------------------|
| Framework          | Flutter 3.44 / Dart 3.12                 |
| State management   | Riverpod 3 (`Notifier` / providers)      |
| Database           | Drift (SQLite)                           |
| SMS access         | `another_telephony`                      |
| Formatting         | `intl` (en_IN locale)                    |

## Running it

SMS reading is **Android-only** and needs a real inbox, so run on a physical
phone (or an emulator with SMS injected):

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # if models change
flutter run                                                 # with a device attached
```

On first launch you'll be asked for SMS permission (with a privacy explanation),
then the app scans your inbox, imports recognized bank transactions, and shows
the dashboard. New SMS are ingested live while the app is open.

> No Android device is currently connected. Attach a phone with USB debugging,
> or create an emulator: `flutter emulators --create` then `flutter emulators --launch <id>`.

## Testing the parser

```bash
flutter test test/parser_service_test.dart
```

## Privacy

- SMS are read, parsed, categorized, and stored **entirely on-device**.
- Nothing is sent to any server. There is no cloud/AI call in this slice.
- No banking passwords or OTPs are used; OTP messages are explicitly ignored.

## Not yet built (next phases)

- Encrypted database (SQLCipher via `drift`/`sqlcipher_flutter_libs`) + biometric lock
- Analytics screen (pie/bar charts via `fl_chart`)
- Budgets, weekly/monthly reports
- AI layer (insights, chat, predictions) behind the existing service interfaces
- Background SMS ingestion (top-level isolate handler)
- Tunable/editable merchant→category mappings
