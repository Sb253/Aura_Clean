import 'package:aura_clean/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _lastDeletionDateKey = 'lastDeletionDate';
  static const String _dailyDeletionCountKey = 'dailyDeletionCount';
  static const String _onboardingCompleteKey = 'onboarding_complete';

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
}
