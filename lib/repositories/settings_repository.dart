import 'package:aura_clean/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _lastDeletionDateKey = 'lastDeletionDate';
  static const String _dailyDeletionCountKey = 'dailyDeletionCount';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _trialStartDateKey = 'trial_start_date';
  static const String _trialUsedKey = 'trial_used';

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

  Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_trialStartDateKey, now.toIso8601String());
    await prefs.setBool(_trialUsedKey, true);
  }

  Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final trialUsed = prefs.getBool(_trialUsedKey) ?? false;
    
    if (!trialUsed) {
      return true; // Trial hasn't been started yet
    }
    
    final trialStartDate = await getTrialStartDate();
    if (trialStartDate == null) {
      return true; // No trial start date, consider it active
    }
    
    final now = DateTime.now();
    final trialEndDate = trialStartDate.add(const Duration(days: 14));
    
    return now.isBefore(trialEndDate);
  }

  Future<int> getTrialDaysRemaining() async {
    final trialStartDate = await getTrialStartDate();
    if (trialStartDate == null) {
      return 14; // Trial hasn't started yet
    }
    
    final now = DateTime.now();
    final trialEndDate = trialStartDate.add(const Duration(days: 14));
    
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
}
