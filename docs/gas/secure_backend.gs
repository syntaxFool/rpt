// Secure Google Apps Script backend for Calorie Commander
// Implements non-destructive sheet init, input sanitization, concurrency locks,
// and optional pagination/date-range listing.

/**
 * Entry point (POST). Routes actions and returns JSON
 */
function doPost(e) {
  try {
    const body = safeParse(e);
    if (!body) return jsonErr('Invalid JSON body');
    const action = String(body.action || '').trim();
    const ss = getSpreadsheet();

    switch (action) {
      case 'init':
        return initSheets(ss);
      case 'addLog':
        return addLog(ss, body);
      case 'deleteLog':
        return deleteLog(ss, body);
      case 'addOrUpdateFood':
        return addOrUpdateFood(ss, body);
      case 'deleteFood':
        return deleteFood(ss, body);
      case 'updateSettings':
        return updateSettings(ss, body);
      case 'updateProfile':
        return updateProfile(ss, body);
      case 'list':
        return listData(ss, body);
      default:
        return jsonErr('Unknown action: ' + action);
    }
  } catch (err) {
    return jsonErr('Server error: ' + err);
  }
}

/**
 * Optional GET for debugging
 */
function doGet(e) {
  return jsonOk({ ok: true, message: 'Calorie Commander GAS online' });
}

// ===== Configuration =====
const SHEET_NAMES = {
  LOGS: 'Logs',
  FOODS: 'Foods',
  SETTINGS: 'Settings',
  PROFILE: 'Profile',
};

const HEADERS = {
  Logs: ['id', 'timestamp', 'foodName', 'foodEmoji', 'grams', 'calories', 'mealCategory'],
  Foods: ['name', 'emoji', 'caloriesPer100g', 'proteinPer100g', 'carbsPer100g', 'fatPer100g'],
  Settings: ['dailyCalorieTarget', 'proteinTarget', 'carbsTarget', 'fatTarget', 'lastModified'],
  Profile: ['name', 'age', 'gender', 'heightCm', 'currentWeightKg', 'goalWeightKg', 'lastWeightCheckIn', 'weightHistory', 'createdAt', 'lastModified'],
};

function getSpreadsheet() {
  const SHEET_ID = PropertiesService.getScriptProperties().getProperty('SHEET_ID');
  if (!SHEET_ID) throw new Error('Missing SHEET_ID in Script Properties');
  return SpreadsheetApp.openById(SHEET_ID);
}

// ===== Utilities =====
function safeParse(e) {
  try {
    if (!e || !e.postData || !e.postData.contents) return null;
    return JSON.parse(e.postData.contents);
  } catch (_) {
    return null;
  }
}

function jsonOk(data) {
  return ContentService.createTextOutput(JSON.stringify({ ok: true, data }))
    .setMimeType(ContentService.MimeType.JSON);
}

function jsonErr(message) {
  return ContentService.createTextOutput(JSON.stringify({ ok: false, error: String(message) }))
    .setMimeType(ContentService.MimeType.JSON);
}

function sanitizeText(value) {
  if (value == null) return '';
  let s = String(value);
  // Prevent sheet formula injection
  if (s && (s[0] === '=' || s[0] === '+' || s[0] === '-' || s[0] === '@')) {
    s = "'" + s;
  }
  // Normalize newlines
  s = s.replace(/\r\n|\r|\n/g, ' ');
  return s;
}

function asNumber(x, fallback) {
  const n = Number(x);
  return isFinite(n) ? n : (fallback != null ? fallback : 0);
}

function parseDateISO(s) {
  if (!s) return null;
  try {
    return new Date(String(s));
  } catch (_) {
    return null;
  }
}

function ensureSheet(ss, name, header) {
  let sh = ss.getSheetByName(name);
  if (!sh) {
    sh = ss.insertSheet(name);
    sh.getRange(1, 1, 1, header.length).setValues([header]);
    sh.setFrozenRows(1);
    return sh;
  }
  // Ensure header exists in row 1 without destructive clears
  const firstRow = sh.getRange(1, 1, 1, Math.max(sh.getMaxColumns(), header.length)).getValues()[0];
  const current = firstRow.slice(0, header.length);
  let needsHeaderSet = false;
  for (let i = 0; i < header.length; i++) {
    if (!current[i]) needsHeaderSet = true;
  }
  if (needsHeaderSet) {
    sh.getRange(1, 1, 1, header.length).setValues([header]);
    sh.setFrozenRows(1);
  } else {
    // Non-destructive migration: append missing columns at end
    const currentHeadersFull = sh.getRange(1, 1, 1, sh.getMaxColumns()).getValues()[0];
    const missing = header.filter(h => currentHeadersFull.indexOf(h) === -1);
    if (missing.length > 0) {
      sh.insertColumnsAfter(sh.getMaxColumns(), missing.length);
      sh.getRange(1, sh.getMaxColumns() - missing.length + 1, 1, missing.length).setValues([missing]);
    }
    sh.setFrozenRows(1);
  }
  return sh;
}

// ===== Actions =====
function initSheets(ss) {
  ensureSheet(ss, SHEET_NAMES.LOGS, HEADERS.Logs);
  ensureSheet(ss, SHEET_NAMES.FOODS, HEADERS.Foods);
  ensureSheet(ss, SHEET_NAMES.SETTINGS, HEADERS.Settings);
  ensureSheet(ss, SHEET_NAMES.PROFILE, HEADERS.Profile);
  return jsonOk({ initialized: true });
}

function addLog(ss, b) {
  const lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
    const sh = ensureSheet(ss, SHEET_NAMES.LOGS, HEADERS.Logs);
    const row = [
      sanitizeText(b.id),
      String(b.timestamp || new Date().toISOString()),
      sanitizeText(b.foodName),
      sanitizeText(b.foodEmoji),
      asNumber(b.grams, 0),
      asNumber(b.calories, 0),
      sanitizeText(b.mealCategory || 'Other'),
    ];
    sh.appendRow(row);
    return jsonOk({ added: true });
  } catch (err) {
    return jsonErr(err);
  } finally {
    lock.releaseLock();
  }
}

function addOrUpdateFood(ss, b) {
  const lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
    const sh = ensureSheet(ss, SHEET_NAMES.FOODS, HEADERS.Foods);
    const values = sh.getDataRange().getValues();

    const name = sanitizeText(b.name);
    const emoji = sanitizeText(b.emoji);
    const cals = asNumber(b.caloriesPer100g, 0);
    const prot = asNumber(b.proteinPer100g, 0);
    const carbs = asNumber(b.carbsPer100g, 0);
    const fat = asNumber(b.fatPer100g, 0);

    const indexMap = new Map();
    for (let i = 1; i < values.length; i++) {
      const key = String(values[i][0]);
      indexMap.set(key, i + 1); // 1-based row index
    }

    const payload = [name, emoji, cals, prot, carbs, fat];
    if (indexMap.has(name)) {
      const rowIdx = indexMap.get(name);
      sh.getRange(rowIdx, 1, 1, HEADERS.Foods.length).setValues([payload]);
      return jsonOk({ updated: true });
    } else {
      sh.appendRow(payload);
      return jsonOk({ added: true });
    }
  } catch (err) {
    return jsonErr(err);
  } finally {
    lock.releaseLock();
  }
}

function deleteFood(ss, b) {
  const lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
    const sh = ensureSheet(ss, SHEET_NAMES.FOODS, HEADERS.Foods);
    const values = sh.getDataRange().getValues();
    const name = sanitizeText(b.name);

    for (let i = 1; i < values.length; i++) {
      if (String(values[i][0]) === name) {
        sh.deleteRow(i + 1);
        return jsonOk({ deleted: true });
      }
    }
    return jsonOk({ deleted: false, reason: 'not-found' });
  } catch (err) {
    return jsonErr(err);
  } finally {
    lock.releaseLock();
  }
}

function deleteLog(ss, b) {
  const lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
    const sh = ensureSheet(ss, SHEET_NAMES.LOGS, HEADERS.Logs);
    const values = sh.getDataRange().getValues();
    const logId = sanitizeText(b.id);

    for (let i = 1; i < values.length; i++) {
      if (String(values[i][0]) === logId) { // col 0 = id
        sh.deleteRow(i + 1);
        return jsonOk({ deleted: true });
      }
    }
    return jsonOk({ deleted: false, reason: 'not-found' });
  } catch (err) {
    return jsonErr(err);
  } finally {
    lock.releaseLock();
  }
}

function updateSettings(ss, b) {
  const lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
    const sh = ensureSheet(ss, SHEET_NAMES.SETTINGS, HEADERS.Settings);
    const rowIdx = 2; // single-row settings
    sh.getRange(rowIdx, 1, 1, HEADERS.Settings.length).setValues([
      [
        asNumber(b.dailyCalorieTarget, 2000),
        asNumber(b.proteinTarget, 150),
        asNumber(b.carbsTarget, 250),
        asNumber(b.fatTarget, 70),
        String(b.lastModified || new Date().toISOString()),
      ],
    ]);
    return jsonOk({ updated: true });
  } catch (err) {
    return jsonErr(err);
  } finally {
    lock.releaseLock();
  }
}

function updateProfile(ss, b) {
  const lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
    const sh = ensureSheet(ss, SHEET_NAMES.PROFILE, HEADERS.Profile);
    const rowIdx = 2; // single-row profile
    
    // Parse weightHistory JSON array
    let weightHistoryStr = '[]';
    if (b.weightHistory) {
      try {
        weightHistoryStr = JSON.stringify(b.weightHistory);
      } catch (e) {
        weightHistoryStr = String(b.weightHistory);
      }
    }
    
    sh.getRange(rowIdx, 1, 1, HEADERS.Profile.length).setValues([
      [
        sanitizeText(b.name),
        asNumber(b.age, 0),
        sanitizeText(b.gender),
        asNumber(b.heightCm, 0),
        asNumber(b.currentWeightKg, 0),
        asNumber(b.goalWeightKg, 0),
        String(b.lastWeightCheckIn || ''),
        weightHistoryStr,
        String(b.createdAt || new Date().toISOString()),
        String(b.lastModified || new Date().toISOString()),
      ],
    ]);
    return jsonOk({ updated: true });
  } catch (err) {
    return jsonErr(err);
  } finally {
    lock.releaseLock();
  }
}

function listData(ss, b) {
  const logsSh = ensureSheet(ss, SHEET_NAMES.LOGS, HEADERS.Logs);
  const foodsSh = ensureSheet(ss, SHEET_NAMES.FOODS, HEADERS.Foods);
  const settingsSh = ensureSheet(ss, SHEET_NAMES.SETTINGS, HEADERS.Settings);
  const profileSh = ensureSheet(ss, SHEET_NAMES.PROFILE, HEADERS.Profile);

  // Optional filters
  const startDate = parseDateISO(b.startDate);
  const endDate = parseDateISO(b.endDate);
  const pageSize = asNumber(b.pageSize, 0);
  const page = asNumber(b.page, 1);

  const logsVals = logsSh.getDataRange().getValues();
  const foodsVals = foodsSh.getDataRange().getValues();
  const settingsVals = settingsSh.getDataRange().getValues();
  const profileVals = profileSh.getDataRange().getValues();

  // Logs mapping
  let logs = [];
  for (let i = 1; i < logsVals.length; i++) {
    const row = logsVals[i];
    const ts = parseDateISO(row[1]);
    const item = {
      id: String(row[0] || ''),
      timestamp: row[1],
      foodName: String(row[2] || ''),
      foodEmoji: String(row[3] || ''),
      grams: asNumber(row[4], 0),
      calories: asNumber(row[5], 0),
      mealCategory: String(row[6] || 'Other'),
    };
    if (startDate && ts && ts < startDate) continue;
    if (endDate && ts && ts > endDate) continue;
    logs.push(item);
  }
  // Sort desc by timestamp
  logs.sort((a, b) => String(b.timestamp).localeCompare(String(a.timestamp)));

  const totalLogs = logs.length;
  if (pageSize > 0) {
    const totalPages = Math.max(1, Math.ceil(totalLogs / pageSize));
    const p = Math.min(Math.max(1, page), totalPages);
    const start = (p - 1) * pageSize;
    logs = logs.slice(start, start + pageSize);
  }

  // Foods mapping
  const foods = [];
  for (let i = 1; i < foodsVals.length; i++) {
    const row = foodsVals[i];
    foods.push({
      name: String(row[0] || ''),
      emoji: String(row[1] || ''),
      caloriesPer100g: asNumber(row[2], 0),
      proteinPer100g: asNumber(row[3], 0),
      carbsPer100g: asNumber(row[4], 0),
      fatPer100g: asNumber(row[5], 0),
    });
  }

  // Settings mapping (single row)
  // Only include settings if there is any non-empty value in the row.
  // This avoids sending hardcoded defaults when the sheet is empty.
  let settings; // undefined unless populated
  if (settingsVals.length >= 2) {
    const row = settingsVals[1];
    const hasAny = row.slice(0, 5).some(v => v != null && String(v) !== '');
    if (hasAny) {
      settings = {
        dailyCalorieTarget: asNumber(row[0], 2000),
        proteinTarget: asNumber(row[1], 150),
        carbsTarget: asNumber(row[2], 250),
        fatTarget: asNumber(row[3], 70),
        // If lastModified is missing, set to current time so remote wins on first migration
        lastModified: String(row[4] || new Date().toISOString()),
      };
    }
  }

  // Profile mapping (single row)
  let profile; // undefined unless populated
  if (profileVals.length >= 2) {
    const row = profileVals[1];
    const hasAny = row.slice(0, 10).some(v => v != null && String(v) !== '');
    if (hasAny) {
      // Parse weightHistory JSON
      let weightHistory = [];
      if (row[7]) {
        try {
          weightHistory = JSON.parse(String(row[7]));
        } catch (e) {
          weightHistory = [];
        }
      }
      
      // Helper to convert date values to ISO strings
      const toISOString = (val) => {
        if (!val) return '';
        if (val instanceof Date) return val.toISOString();
        return String(val);
      };
      
      profile = {
        name: String(row[0] || ''),
        age: asNumber(row[1], 0),
        gender: String(row[2] || ''),
        heightCm: asNumber(row[3], 0),
        currentWeightKg: asNumber(row[4], 0),
        goalWeightKg: asNumber(row[5], 0),
        lastWeightCheckIn: toISOString(row[6]),
        weightHistory: weightHistory,
        createdAt: toISOString(row[8]) || new Date().toISOString(),
        lastModified: toISOString(row[9]) || new Date().toISOString(),
      };
    }
  }

  return jsonOk({
    logs,
    foods,
    // settings will be omitted from JSON if undefined
    ...(typeof settings !== 'undefined' ? { settings } : {}),
    // profile will be omitted from JSON if undefined
    ...(typeof profile !== 'undefined' ? { profile } : {}),
    meta: {
      totalLogs,
      page: pageSize > 0 ? page : null,
      pageSize: pageSize > 0 ? pageSize : null,
    },
  });
}
