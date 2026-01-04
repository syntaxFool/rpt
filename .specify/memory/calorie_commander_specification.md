# Calorie Commander - Specification

## Vision
Build a lightweight PWA for tracking daily calorie intake with offline-first design, smart food database, and background sync to Google Apps Script.

## Core Features

### 1. Smart Calorie Logging
- **Quick add**: Tap + button to open Smart Feeder calculator
- **Food autocomplete**: Type or select from 30+ foods
- **Real-time calculation**: Grams × food calories per 100g
- **Emoji indicators**: Visual food identification
- **Timestamp tracking**: Automatic timestamp on each entry

### 2. Daily Balance Tracking
- **Circle progress indicator**: Shows current vs target (2000 kcal default)
- **Today's meals list**: Chronologically ordered meal log
- **Quick delete**: Remove entries with delete button
- **Remaining calories**: Shows kcal left to target or "Over target" warning
- **Visual feedback**: Color-coded remaining calories

### 3. Configurable Settings
- **Daily target slider**: Adjust 1200-3500 kcal
- **Sync status display**: Shows unsynced entries count
- **Manual sync button**: Trigger sync to backend
- **App info**: Version and storage info

### 4. Background Sync
- **Google Apps Script integration**: POST logs to backend endpoint
- **Offline-first**: Works without internet
- **Connectivity check**: Only syncs when online
- **Synced flag**: Tracks which entries uploaded
- **Auto-sync ready**: Infrastructure for scheduled background sync

### 5. Local Data Persistence
- **Hive NoSQL database**: Fast offline storage
- **Food asset box**: 30+ pre-loaded foods
- **Log entry box**: All meal logs with sync status
- **Instant access**: No internet required for logging

## Food Database (30+ Foods)

**Grains & Carbs** (5): Rice, Bread, Pasta, Oatmeal, Quinoa
**Proteins** (6): Chicken Breast, Egg, Salmon, Tofu, Greek Yogurt, Beef
**Fruits** (6): Banana, Apple, Orange, Strawberry, Grapes, Avocado
**Vegetables** (6): Broccoli, Carrot, Spinach, Tomato, Potato, Sweet Potato
**Dairy** (3): Milk, Cheese, Butter
**Nuts & Seeds** (3): Almonds, Peanut Butter, Walnuts

## Success Criteria

✅ User can log meal in <10 seconds
✅ App launches instantly (offline-ready)
✅ All data persists across sessions
✅ Works on mobile & desktop browsers
✅ Installable as PWA (home screen)
✅ Syncs when online, queues when offline

## Out of Scope (v1)

- Photo logging
- Barcode scanning
- Recipe building
- Social sharing
- Multi-user accounts
- Cloud backup beyond Apps Script

## Architecture

- **State**: Provider (ChangeNotifier)
- **Database**: Hive (NoSQL)
- **Sync**: Custom SyncService + HTTP
- **UI**: Flutter Material 3
- **Theme**: "Cozy Red Panda" (Coral #F27D52, Cream #FFFDF9)
- **Font**: Quicksand
- **Platform**: Flutter Web (PWA)
