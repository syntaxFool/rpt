# Calorie Commander 🐼

A lightweight, offline-first calorie tracking PWA built with Flutter. Log your meals instantly, sync when online, and stay cozy while tracking your nutrition.

## Features

✅ **Smart Food Logging** - Quick add with 30+ pre-loaded foods with complete nutritional data
✅ **Macro Tracking** - Track protein, carbs, and fat for every meal (per 100g standard)
✅ **Chef's Creation** - Add custom foods with full nutritional information (🍱)
✅ **Daily Balance Circle** - Visual progress toward 2000 kcal target (customizable 1200-3500)
✅ **Real-time Calculations** - See calories & macros update as you type grams
✅ **Offline-First** - Works without internet, syncs when online
✅ **Background Sync** - Auto-queue meals and sync to Google Apps Script
✅ **PWA Ready** - Install to home screen on iOS & Android
✅ **Zero Dependencies** - Local Hive database, no cloud required

## Architecture

```
Calorie Commander
├── lib/
│   ├── main.dart              # App entry, theme setup, food pre-load
│   ├── models/
│   │   ├── food_asset.dart    # Food database model (30+ foods)
│   │   └── log_entry.dart     # Meal log model with sync flag
│   ├── providers/
│   │   ├── food_provider.dart # Food database CRUD
│   │   └── log_provider.dart  # Meal logging & sync management
│   ├── services/
│   │   ├── hive_service.dart  # Database initialization
│   │   └── sync_service.dart  # Google Apps Script sync
│   ├── screens/
│   │   ├── home_screen.dart   # Daily balance & meal list
│   │   └── settings_screen.dart # Target slider & sync controls
│   └── widgets/
│       ├── balance_circle.dart      # Circular progress indicator
│       ├── calculator_sheet.dart    # Smart Feeder meal input
│       ├── log_entry_card.dart      # Meal display with delete
│       ├── add_food_sheet.dart      # Chef's Creation custom food form
│       └── calorie_commander_logo.dart # App logo widget
├── web/
│   ├── manifest.json          # PWA manifest (installable)
│   └── index.html             # PWA meta tags
└── test/
    └── widget_test.dart       # Basic widget testing

**State Management**: Provider (ChangeNotifier)
**Database**: Hive NoSQL (offline persistence)
**Sync**: Custom SyncService + HTTP POST
**UI**: Flutter Material 3 + Quicksand font
**Theme**: "Cozy Red Panda" (Coral #F27D52, Cream #FFFDF9)
```

## Getting Started

### Prerequisites
- Flutter 3.10.4+
- Dart 3.10.4+
- No Android SDK required (web platform)

### Installation

```bash
# Clone or navigate to project
cd red_panda_tracker

# Get dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build

# Run on web
flutter run -d web-server
```

### Configuration

**Google Apps Script Sync** (Optional):
1. Create a Google Apps Script with POST endpoint
2. Update `lib/services/sync_service.dart` line 12:
   ```dart
   static const String _syncEndpoint = 'YOUR_GOOGLE_APPS_SCRIPT_URL';
   ```

## Usage
 to open Smart Feeder
2. Search or select food from database
3. Enter grams (defaults to 100g if empty)
4. See real-time macro breakdown: **🔥 XXX kcal** + **P: Xg | C: Xg | F: Xg**
5. Tap **Add to Log**

### Creating Custom Foods (Chef's Creation 🍱)
1. Open Smart Feeder with **+** button
2. Tap **Create New Food** button
3. Enter food name (e.g., "Mom's Lasagna")
4. Fill in nutritional values per 100g:
   - **Calories** (kcal) - Orange field
   - **Protein** (g) - Blue "P" field
   - **Carbs** (g) - Green "C" field
   - **Fat** (g) - Amber "F" field
5. Tap **Save to Pantry**
6. Your custom food now appears in searches with 🍱 emoji
3. Enter grams
4. Tap **Add** (calculates calories automatically)
 with complete macros (Calories, Protein, Carbs, Fat per 100g):

**Grains & Carbs** (5):
- Rice (130 cal, 2.7g P, 28g C, 0.3g F)
- Bread (265 cal, 9g P, 49g C, 3.2g F)
- Pasta (158 cal, 5.3g P, 30.9g C, 1.1g F)
- Oatmeal (389 cal, 16.9g P, 66.3g C, 6.9g F)
- Quinoa (120 cal, 4.4g P, 21.3g C, 1.9g F)

**Proteins** (6):
- Chicken Breast (165 cal, 31g P, 0g C, 3.6g F)
- Egg (155 cal, 13g P, 1.1g C, 11g F)
- Salmon (208 cal, 20g P, 0g C, 13g F)
- Tofu (76 cal, 8g P, 1.9g C, 4.8g F)
- Greek Yogurt (59 cal, 10g P, 2.5g C, 0.4g F)
- Beef (250 cal, 26g P, 0g C, 15g F)

**Fruits** (6):
- Banana, Apple, Orange, Strawberry, Grapes, Avocado

**Vegetables** (6):
- Broccoli, Carrot, Spinach, Tomato, Potato, Sweet Potato

**Dairy** (3):
- Milk, Cheese, Butter

**Nuts & Seeds** (3):
- Almonds, Peanut Butter, Walnuts

**+ Custom Foods**: Create your own with Chef's Creation 🍱

*All values per 100g. Macro calculation formula: `(grams / 100) × per100g_value`s internet)
3. App automatically queues offline entries

## Food Database

30+ pre-loaded foods:
- **Grains**: Rice (130), Bread (265), Pasta (158), Oatmeal (389), Quinoa (120)
- **Proteins**: Chicken Breast (165), Egg (155), Salmowith macros (Hive TypeId: 10) |
| `lib/models/log_entry.dart` | Meal log schema with sync flag (Hive TypeId: 11) |
| `lib/services/sync_service.dart` | Background sync to Google Apps Script |
| `lib/widgets/balance_circle.dart` | Circular progress indicator (0-2000 kcal) |
| `lib/widgets/calculator_sheet.dart` | Smart Feeder with real-time macro display |
| `lib/widgets/add_food_sheet.dart` | Chef's Creation custom food form |
| `lib/widgets/calorie_commander_logo.dart` | App logo with animated panda

*Calories shown are per 100g*

## Development

### Code Quality
```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format .
```

### Build

```bash
# Web build
flutter build web

# Clean & rebuild
flutter clean && flutter pub get && dart run build_runner build
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/models/food_asset.dart` | Food database schema (Hive TypeId: 10) |
| `lib/models/log_entry.dart` | Meal log schema with sync flag (Hive TypeId: 11) |
| `lib/services/sync_service.dart` | Background sync to Google Apps Script |
| `lib/widgets/balance_circle.dart` | Circular progress indicator (0-2000 kcal) |
| `lib/widgets/calculator_sheet.dart` | Food autocomplete + gram input |
| `web/manifest.json` | PWA install manifest |

## Testing

```bash
# Run widget test
flutter test test/widget_test.dart

# Test with coverage
flutter test --coverage
``` & charts
- [ ] Meal presets (breakfast, lunch, dinner templates)
- [ ] Daily macro goals (protein/carbs/fat targets)
- [ ] Push notifications for offline sync completion
- [ ] Barcode scanning for packaged foods
- [ ] Export nutrition data to CSV/PDF
- [ ] Water intake tracking
- [ ] Meal photos & notadd
- **Sync**: ~2 seconds per 10 entries (online)
- **Storage**: ~1MB per 1000 meal entries (local Hive)

## Browser Support

| Browser | Status |
|---------|--------|
| Chrome | ✅ Full support |
| Safari | ✅ Full support (iOS 14.5+) |
| Firefox | ✅ Full support |
| Edge | ✅ Full support |

## PWA Installation

**iOS**: Safari → Share → Add to Home Screen
**Android**: Chrome → Menu → Install app

## Future Enhancements

- [ ] Weekly/monthly nutrition trends
- [ ] Meal presets (breakfast, lunch, dinner)
- [ ] Macro tracking (protein, carbs, fats)
- [ ] Push notifications for offline sync
- [ ] Barcode scanning
- [ ] Custom food entries

## License

MIT License - See LICENSE file

## Contributing

Built with Spec-Driven Development using [specify](https://github.com/cagostino/specify)

## Support

For issues or feature requests, check the `.specify/memory/` directory for project documentation.

---

**Made with ❤️ by Calorie Commander Team**
*Keep it cozy, keep it simple.*

