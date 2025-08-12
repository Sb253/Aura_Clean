import 'package:aura_clean/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _lastDeletionDateKey = 'lastDeletionDate';
  static const String _dailyDeletionCountKey = 'dailyDeletionCount';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _trialStartDateKey = 'trial_start_date';
  static const String _trialUsedKey = 'trial_used';
  static const String _trialEndDateKey = 'trial_end_date';

  Future<int> getDailyDeletionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDeletionDate = prefs.getString(_lastDeletionDateKey);

    if (today != lastDeletionDate) {
      return 0;
    }
    return prefs.getInt(_dailyDeletionCountKey) ?? 0;
  }

  Future<void> incrementDailyDeletionCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final currentCount = await getDailyDeletionCount();

    await prefs.setString(_lastDeletionDateKey, today);
    await prefs.setInt(_dailyDeletionCountKey, currentCount + count);
  }

  Future<bool> getThemeIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.themeIsDarkKey) ?? false;
  }

  Future<void> setThemeIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.themeIsDarkKey, isDark);
  }

  Future<bool> getOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, isComplete);
  }

  // Trial management methods
  Future<DateTime?> getTrialStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_trialStartDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<DateTime?> getTrialEndDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_trialEndDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 14));
    
    await prefs.setString(_trialStartDateKey, now.toIso8601String());
    await prefs.setString(_trialEndDateKey, trialEnd.toIso8601String());
    await prefs.setBool(_trialUsedKey, true);
  }

  Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final trialUsed = prefs.getBool(_trialUsedKey) ?? false;
    
    if (!trialUsed) {
      return true; // Trial hasn't been started yet
    }
    
    final trialEndDate = await getTrialEndDate();
    if (trialEndDate == null) {
      return true; // No trial end date, consider it active
    }
    
    final now = DateTime.now();
    return now.isBefore(trialEndDate);
  }

  Future<bool> hasTrialExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final trialUsed = prefs.getBool(_trialUsedKey) ?? false;
    
    if (!trialUsed) {
      return false; // Trial hasn't been started yet
    }
    
    final trialEndDate = await getTrialEndDate();
    if (trialEndDate == null) {
      return false; // No trial end date, consider it active
    }
    
    final now = DateTime.now();
    return now.isAfter(trialEndDate);
  }

  Future<int> getTrialDaysRemaining() async {
    final trialEndDate = await getTrialEndDate();
    if (trialEndDate == null) {
      return 14; // Trial hasn't started yet
    }
    
    final now = DateTime.now();
    if (now.isAfter(trialEndDate)) {
      return 0; // Trial expired
    }
    
    final remaining = trialEndDate.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  Future<bool> hasUsedTrial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialUsedKey) ?? false;
  }

  // Feature access methods
  Future<bool> canAccessFeature(String featureName) async {
    // Premium users can access all features
    // During trial, all features are accessible
    // After trial, only basic features are accessible
    
    final isPremium = false; // This will be updated by PurchaseBloc
    final trialActive = await isTrialActive();
    
    if (isPremium) return true;
    if (trialActive) return true;
    
    // After trial, only basic features are allowed
    return _isBasicFeature(featureName);
  }

  bool _isBasicFeature(String featureName) {
    const basicFeatures = [
      'photo_analysis',
      'duplicate_detection',
      'basic_review',
      'storage_info',
    ];
    
    return basicFeatures.contains(featureName);
  }

  // Ad display logic
  Future<bool> shouldShowAds() async {
    // Show ads during trial and after trial (unless premium)
    // This will be updated by PurchaseBloc with actual premium status
    return true;
  }
}
