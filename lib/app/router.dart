import 'package:aura_clean/models/photo_asset.dart';
import 'package:aura_clean/screens/dashboard_screen.dart';
import 'package:aura_clean/screens/onboarding_screen.dart';
import 'package:aura_clean/screens/paywall_screen.dart';
import 'package:aura_clean/screens/permissions_screen.dart';
import 'package:aura_clean/screens/review_screen.dart';
import 'package:aura_clean/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String onboardingRoute = '/';
  static const String permissionsRoute = '/permissions';
  static const String dashboardRoute = '/dashboard';
  static const String settingsRoute = '/settings';
  static const String reviewRoute = '/review';
  static const String paywallRoute = '/paywall';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case permissionsRoute:
        return MaterialPageRoute(builder: (_) => const PermissionsScreen());
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case paywallRoute:
        return MaterialPageRoute(builder: (_) => const PaywallScreen());
      case reviewRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(
            photosToReview: args['photos'] as List<PhotoAsset>,
            categoryTitle: args['title'] as String,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
