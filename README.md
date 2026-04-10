# 💸 Expense Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Hive](https://img.shields.io/badge/Hive-Local%20Storage-FFD700?style=for-the-badge)](https://pub.dev/packages/hive)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://play.google.com)
[![Offline](https://img.shields.io/badge/Works-Offline-008751?style=for-the-badge)]()

> **Track your spending. Build financial responsibility.** — A personal expense tracker built to help you understand where your money goes every single day.

---

## 💡 Motivation

This app was created out of a personal need — to track daily spending and build financial responsibility. Knowing where your money goes is the first step to managing it better. This app makes that simple, fast, and completely offline.

---

## ✨ Features

- ➕ **Add expenses** — amount, category, and optional note
- ✏️ **Edit expenses** — tap any entry to update it
- 🗑️ **Delete expenses** — swipe left to remove
- 📅 **Daily grouping** — expenses grouped by Today, Yesterday, and older dates
- 📊 **Daily comparison** — see if you spent more or less today vs yesterday
- 💰 **Total spending** — all-time total displayed at the top
- 🏷️ **Categories** — Food, Transport, Bills, Others
- 💾 **Fully offline** — all data stored locally using Hive
- 🔄 **Persistent storage** — data survives app restarts

---

## 🏗️ Project Structure

```
expense_tracker/
├── lib/
│   ├── main.dart
│   ├── core/
│   └── features/
│       └── expenses/
│           ├── data/
│           │   ├── models/
│           │   │   ├── expense_model.dart       # Hive data model
│           │   │   └── expense_model.g.dart     # Auto-generated adapter
│           │   └── datasource/
│           │       └── expense_datasource.dart  # Hive read/write logic
│           └── presentation/
│               └── screens/
│                   ├── home_screen.dart         # Main screen
│                   └── add_expense_screen.dart  # Add & edit screen
└── pubspec.yaml
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.x | UI framework |
| Dart 3.x | Programming language |
| Hive | Offline local storage |
| hive_flutter | Flutter integration for Hive |
| hive_generator | Auto-generates Hive adapters |
| build_runner | Code generation tool |
| Google Fonts | Typography (Nunito) |
| intl | Date & number formatting |
| uuid | Unique ID generation per expense |

---

## 🧠 Architecture

Clean feature-based folder structure with separation of concerns:

- **Data layer** — `expense_model.dart` defines the schema, `expense_datasource.dart` handles all Hive operations
- **Presentation layer** — screens handle UI and call the datasource directly
- **State management** — simple `setState()` — no over-engineering
- **Storage** — Hive box acts as a local database, persists across sessions

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`

### Installation

```bash
# Clone the repository
git clone https://github.com/Georgeoloche/expense-tracker.git

# Navigate into the project
cd expense-tracker

# Install dependencies
flutter pub get

# Generate Hive adapter
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  google_fonts: ^6.1.0
  intl: ^0.19.0
  uuid: ^4.3.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

---

## 🎯 Key Implementation Details

**Hive model with type adapter:**
```dart
@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final double amount;
  @HiveField(2) final String category;
  @HiveField(3) final String? note;
  @HiveField(4) final DateTime date;
}
```

**Daily comparison logic:**
```dart
_todayTotal = all.where((e) {
  final d = DateTime(e.date.year, e.date.month, e.date.day);
  return d == today;
}).fold(0.0, (sum, e) => sum + e.amount);
```

**Edit mode — same screen for add and edit:**
```dart
bool get _isEditing => widget.expense != null;
```

---

## 🗺️ Roadmap

- [ ] Monthly spending summary
- [ ] Spending charts and graphs
- [ ] Budget limits per category
- [ ] Export expenses to CSV
- [ ] Filter by category or date range
- [ ] Dark mode support
- [ ] Splash screen and app icon

---

## 👨‍💻 Author

**George Oloche**
Junior Flutter Developer | Building for Africa 🌍

[![GitHub](https://img.shields.io/badge/GitHub-Georgeoloche-181717?style=flat&logo=github)](https://github.com/Georgeoloche)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-George%20Oloche-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/georgeoloche)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with ❤️ to encourage financial responsibility 💸</sub>
</div>
