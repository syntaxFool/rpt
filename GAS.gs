const SHEET_ID = '1yHlywlc4SwE7yFqgpWsTxDlu-uRYAIOkGqcG6aYBnIY';
const LOG_SHEET = 'Logs';
const NOTE_SHEET = 'Notes';
const FOOD_SHEET = 'Foods';
const SETTINGS_SHEET = 'Settings';
function doOptions(e) {
  return ContentService.createTextOutput('').setMimeType(ContentService.MimeType.TEXT);
}

function doGet(e) {
  return json({ ok: true, action: 'get' });
}

function doPost(e) {
  const body = JSON.parse(e.postData.contents || '{}');
  const action = body.action;

  if (action === 'init') return initSheets();
  if (action === 'addLog') return addLog(body);
  if (action === 'addNote') return addNote(body);
  if (action === 'addOrUpdateFood') return addOrUpdateFood(body);
  if (action === 'deleteFood') return deleteFood(body);
  if (action === 'updateSettings') return updateSettings(body);
  if (action === 'list') return listData();

  return json({ error: 'unknown action' });
}

function initSheets() {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  ensureSheet(ss, LOG_SHEET, ['id', 'timestamp', 'foodName', 'foodEmoji', 'grams', 'calories', 'mealCategory']);
  ensureSheet(ss, NOTE_SHEET, ['date', 'note', 'lastModified']);
  ensureSheet(ss, FOOD_SHEET, ['name', 'emoji', 'caloriesPer100g', 'proteinPer100g', 'carbsPer100g', 'fatPer100g']);
  ensureSheet(ss, SETTINGS_SHEET, ['dailyCalorieTarget', 'proteinTarget', 'carbsTarget', 'fatTarget']);
  return json({ ok: true });
}

function ensureSheet(ss, name, header) {
  let sh = ss.getSheetByName(name);
  if (!sh) sh = ss.insertSheet(name);
  const currentHeader = sh.getRange(1, 1, 1, header.length).getValues()[0];
  if (currentHeader.join('') !== header.join('')) {
    sh.clear();
    sh.getRange(1, 1, 1, header.length).setValues([header]);
  }
}

function addLog(b) {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sh = ss.getSheetByName(LOG_SHEET);
  const row = [b.id, b.timestamp, b.foodName, b.foodEmoji, b.grams, b.calories, b.mealCategory];
  sh.appendRow(row);
  return json({ ok: true });
}

function addNote(b) {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sh = ss.getSheetByName(NOTE_SHEET);
  const row = [b.date, b.note, b.lastModified];
  sh.appendRow(row);
  return json({ ok: true });
}

function addOrUpdateFood(b) {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sh = ss.getSheetByName(FOOD_SHEET);
  const values = sh.getDataRange().getValues();
  const header = values[0];
  const nameIdx = header.indexOf('name');

  let updated = false;
  for (let i = 1; i < values.length; i++) {
    if (values[i][nameIdx] === b.name) {
      sh.getRange(i + 1, 1, 1, header.length).setValues([[b.name, b.emoji, b.caloriesPer100g, b.proteinPer100g, b.carbsPer100g, b.fatPer100g]]);
      updated = true;
      break;
    }
  }

  if (!updated) {
    sh.appendRow([b.name, b.emoji, b.caloriesPer100g, b.proteinPer100g, b.carbsPer100g, b.fatPer100g]);
  }
  return json({ ok: true });
}

function deleteFood(b) {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sh = ss.getSheetByName(FOOD_SHEET);
  const values = sh.getDataRange().getValues();
  const header = values[0];
  const nameIdx = header.indexOf('name');

  for (let i = 1; i < values.length; i++) {
    if (values[i][nameIdx] === b.name) {
      sh.deleteRow(i + 1);
      break;
    }
  }
  return json({ ok: true });
}

function updateSettings(b) {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  ensureSheet(ss, SETTINGS_SHEET, ['dailyCalorieTarget', 'proteinTarget', 'carbsTarget', 'fatTarget']);
  const sh = ss.getSheetByName(SETTINGS_SHEET);
  const header = ['dailyCalorieTarget', 'proteinTarget', 'carbsTarget', 'fatTarget'];
  const row = [b.dailyCalorieTarget, b.proteinTarget, b.carbsTarget, b.fatTarget];
  // Always write to row 2 to keep a single settings record
  sh.getRange(2, 1, 1, header.length).setValues([row]);
  return json({ ok: true });
}

function listData() {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const logs = readSheet(ss, LOG_SHEET);
  const notes = readSheet(ss, NOTE_SHEET);
  const foods = readSheet(ss, FOOD_SHEET);
  const settings = readSettings(ss);
  // Only include settings if they exist; null means no settings saved yet
  const response = { ok: true, logs, notes, foods };
  if (settings !== null) {
    response.settings = settings;
  }
  return json(response);
}

function readSheet(ss, name) {
  const sh = ss.getSheetByName(name);
  if (!sh) return [];
  const values = sh.getDataRange().getValues();
  if (values.length <= 1) return [];
  const header = values[0];
  return values.slice(1).map(r => {
    const o = {};
    header.forEach((h, i) => o[h] = r[i]);
    return o;
  });
}

function readSettings(ss) {
  const sh = ss.getSheetByName(SETTINGS_SHEET);
  if (!sh) return null;
  const values = sh.getDataRange().getValues();
  if (values.length <= 1) return null;
  const header = values[0];
  const row = values[1];
  // Check if row actually has data (not all empty)
  const hasData = row.some(cell => cell !== null && cell !== undefined && cell !== '');
  if (!hasData) return null;
  const o = {};
  header.forEach((h, i) => o[h] = row[i]);
  return o;
}

function json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
