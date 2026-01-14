import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile.dart';
import '../services/sheet_api.dart';
import '../services/hive_service.dart';

class ProfileProvider with ChangeNotifier {
  static const String _profileKey = 'user_profile';
  
  late Box<UserProfile> _box;
  UserProfile? _profile;
  final SheetApi _sheetApi = SheetApi();

  ProfileProvider() {
    _box = HiveService.getProfileBox();
    _loadProfile();
  }

  void _loadProfile() {
    _profile = _box.get(_profileKey);
    notifyListeners();
  }

  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  // Achievement badges
  int get daysTracked => 0; // Will be calculated from logs
  int get currentStreak => 0; // Will be calculated from logs

  List<Map<String, String>> get badges {
    List<Map<String, String>> earned = [];
    if (daysTracked >= 7) earned.add({'icon': '🏆', 'label': 'Week Warrior'});
    if (daysTracked >= 30) earned.add({'icon': '👑', 'label': 'Month Master'});
    if (currentStreak >= 7) earned.add({'icon': '🔥', 'label': 'On Fire'});
    if (_profile != null && _profile!.weightHistory.length >= 4) {
      earned.add({'icon': '📊', 'label': 'Weight Tracker'});
    }
    return earned;
  }

  Future<void> createProfile(UserProfile profile) async {
    profile.lastModified = DateTime.now();
    await _box.put(_profileKey, profile);
    _profile = profile;
    
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    profile.lastModified = DateTime.now();
    await _box.put(_profileKey, profile);
    _profile = profile;
    
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> addWeightEntry(WeightEntry entry) async {
    if (_profile == null) return;

    _profile!.weightHistory.add(entry);
    _profile!.currentWeightKg = entry.weight;
    _profile!.lastWeightCheckIn = DateTime.now();
    _profile!.lastModified = DateTime.now();

    if (_profile != null) {
      await _box.put(_profileKey, _profile!);
    }
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> _syncToBackend() async {
    if (_profile == null) return;
    
    try {
      await _sheetApi.updateProfile(_profile!);
      debugPrint('✓ Profile synced to backend');
    } catch (e) {
      debugPrint('⚠️ Failed to sync profile: $e');
    }
  }

  Future<void> refreshFromSheets(Map<String, dynamic>? data) async {
    debugPrint('📥 ProfileProvider.refreshFromSheets called');
    debugPrint('📊 Data keys: ${data?.keys.toList()}');
    debugPrint('📊 Profile data exists: ${data?.containsKey('profile')}');
    
    if (data == null) {
      debugPrint('⚠️ refreshFromSheets: data is null');
      return;
    }
    
    if (!data.containsKey('profile')) {
      debugPrint('⚠️ refreshFromSheets: no profile key in data');
      return;
    }

    try {
      debugPrint('🔍 Profile data from backend: ${data['profile']}');
      final remoteProfile = UserProfile.fromJson(data['profile']);
      debugPrint('✅ Successfully parsed remote profile: ${remoteProfile.name}');
      
      if (_profile == null) {
        debugPrint('💾 No local profile, saving remote profile');
        await _box.put(_profileKey, remoteProfile);
        _profile = remoteProfile;
        notifyListeners();
        return;
      }

      debugPrint('⏰ Local lastModified: ${_profile!.lastModified}');
      debugPrint('⏰ Remote lastModified: ${remoteProfile.lastModified}');

      if (remoteProfile.lastModified.isAfter(_profile!.lastModified)) {
        debugPrint('🔄 Remote profile is newer, updating local');
        await _box.put(_profileKey, remoteProfile);
        _profile = remoteProfile;
        notifyListeners();
      } else if (_profile!.lastModified.isAfter(remoteProfile.lastModified)) {
        debugPrint('🔄 Local profile is newer, pushing to backend');
        await _syncToBackend();
      } else {
        debugPrint('✅ Profiles are in sync');
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to sync profile from sheets: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
