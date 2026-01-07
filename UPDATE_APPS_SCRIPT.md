# Update Google Apps Script

## 🔴 IMPORTANT: Update Required for Settings Sync Fix

The settings sync issue has been fixed in the code, but you need to manually update your Google Apps Script to complete the fix.

## Steps to Update

1. **Open your Google Apps Script**
   - Go to: https://script.google.com/
   - Open your existing "Calorie Commander API" project

2. **Replace the entire GAS.gs content**
   - Select all the code in the script editor
   - Delete it
   - Copy the entire contents of `GAS.gs` from this project
   - Paste it into the Apps Script editor

3. **Deploy the updated script**
   - Click "Deploy" → "Manage deployments"
   - Click the edit icon (pencil) on your existing Web app deployment
   - Under "Version", select "New version"
   - Add description: "Fixed settings sync to preserve custom nutrition goals"
   - Click "Deploy"

4. **Verify the fix**
   - Open the app on one device and set custom nutrition goals
   - Click "Sync Data" in the hamburger menu
   - Open the app on a different device (or clear browser data)
   - Click "Sync Data" - your custom goals should now load correctly!

## What Was Fixed

### Problem
- Custom nutrition goals were being overwritten with defaults when syncing across devices
- The Apps Script was returning an empty object `{}` when no settings existed
- The app couldn't distinguish between "no settings saved yet" vs "settings saved with default values"

### Solution
1. **GAS.gs changes:**
   - `readSettings()` now returns `null` instead of `{}` when no settings exist
   - Added validation to check if row 2 actually contains data
   - Modified `listData()` to only include settings key if settings exist in Sheets

2. **App changes (already deployed):**
   - `refreshFromSheets()` now checks if settings exist in the response
   - If no settings found in Sheets, it pushes current local settings instead of overwriting
   - This ensures first device to sync becomes the source of truth

## Testing Checklist

- [ ] Updated Apps Script code
- [ ] Created new deployment version
- [ ] Set custom nutrition goals on Device A
- [ ] Synced on Device A
- [ ] Opened app on Device B (fresh/cleared data)
- [ ] Synced on Device B
- [ ] Verified custom goals appeared on Device B
- [ ] Changed goals on Device B
- [ ] Synced on Device B
- [ ] Verified changes appeared on Device A after sync

---

**Deployed to:** https://5012rpt.netlify.app
