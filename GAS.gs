const SHEET_ID = '1yHlywlc4SwE7yFqgpWsTxDlu-uRYAIOkGqcG6aYBnIY';
const LOG_SHEET = 'Logs';
const NOTE_SHEET = 'Notes';
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
  if (action === 'list') return listData();

  return json({ error: 'unknown action' });
}

function initSheets() {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  ensureSheet(ss, LOG_SHEET, ['id', 'timestamp', 'foodName', 'foodEmoji', 'grams', 'calories', 'mealCategory']);
  ensureSheet(ss, NOTE_SHEET, ['date', 'note', 'lastModified']);
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

function listData() {
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const logs = readSheet(ss, LOG_SHEET);
  const notes = readSheet(ss, NOTE_SHEET);
  return json({ ok: true, logs, notes });
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

function json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
