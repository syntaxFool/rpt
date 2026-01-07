# Secure Google Apps Script Backend for Calorie Commander

This folder provides a hardened `script.gs` you can paste into your Google Apps Script project to avoid data loss, add basic security, and support optional pagination.

## Key Improvements
- Non-destructive sheet initialization: never clears data if headers change; appends missing columns.
- Input sanitization: prevents formula (CSV) injection by prefixing risky strings.
- Concurrency safety: uses `LockService` around read-modify-write operations.
- Error handling: robust JSON parsing and consistent JSON responses.
- Optional pagination and date-range filters for `list` action.
- Configuration via Script Properties: no hardcoded `SHEET_ID`.

## Setup Steps
1. Open your Apps Script project powering the Google Sheet backend.
2. Set Script Property `SHEET_ID`:
   - In Apps Script: Project Settings → Script properties → Add `SHEET_ID` with value: `1GMYq3-s3VGuNxVlo2VPCHu1umHjhDgx2UzkfTvOF8MQ`
3. Replace your backend code:
   - Copy contents of `secure_backend.gs` into your Apps Script editor (or a new file) and save.
4. Deploy:
   - Deploy as Web App (Execute as: Me, Who has access: Anyone)
   - The current deployment URL is: `https://script.google.com/macros/s/AKfycbyEW0hyxy0zRo5SqLj3KqUboyQVV5oZbqa2Y-JDnKyI9afZR6M0Ho-pENSBQgY6JpqC8g/exec`

## Client Compatibility
- Existing client calls (action `list`, `addLog`, `addNote`, `addOrUpdateFood`, `deleteFood`, `updateSettings`, `init`) continue to work.
- `list` now supports optional fields: `startDate`, `endDate` (ISO strings), `page`, `pageSize`.

## Testing
- Use curl or Postman against your Web App URL:

```bash
# Init
curl -X POST -H "Content-Type: application/json" \
  -d '{"action":"init"}' "https://script.google.com/macros/s/<DEPLOY_ID>/exec"

# List last week, paginated
curl -X POST -H "Content-Type: application/json" \
  -d '{"action":"list","startDate":"2025-12-31T00:00:00Z","endDate":"2026-01-07T23:59:59Z","page":1,"pageSize":100}' \
  "https://script.google.com/macros/s/<DEPLOY_ID>/exec"
```

## Notes
- Column headers used:
  - `Logs`: id, timestamp, foodName, foodEmoji, grams, calories, mealCategory
  - `Notes`: date, note, lastModified
  - `Foods`: name, emoji, caloriesPer100g, proteinPer100g, carbsPer100g, fatPer100g
  - `Settings`: dailyCalorieTarget, proteinTarget, carbsTarget, fatTarget
- `Settings` stored as a single row (row 2) under headers.

## Troubleshooting
- If you see `Missing SHEET_ID in Script Properties`, ensure `SHEET_ID` is set.
- For large datasets, use pagination/date-range to reduce payload size.
