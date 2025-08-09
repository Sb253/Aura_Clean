class AppConstants {
  // In-App Purchase Product IDs
  static const String monthlySubscriptionId = 'aura_pro_monthly';
  static const String annualSubscriptionId = 'aura_pro_yearly';
  static const String lifetimeProductId = 'aura_pro_max_lifetime';

  static const List<String> productIds = <String>[
    monthlySubscriptionId,
    annualSubscriptionId,
    lifetimeProductId,
  ];

  // SharedPreferences Keys
  static const String themeIsDarkKey = 'isDark';
}
