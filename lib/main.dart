import 'package:aura_clean/blocs/photo_cleaner_bloc.dart';
import 'package:aura_clean/blocs/purchase_bloc.dart';
import 'package:aura_clean/blocs/theme_bloc.dart';
import 'package:aura_clean/blocs/theme_state.dart';
import 'package:aura_clean/repositories/photo_repository.dart';
import 'package:aura_clean/repositories/settings_repository.dart';
import 'package:aura_clean/screens/dashboard_screen.dart';
import 'package:aura_clean/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handling for initialization
  try {
    // Initialize services with error handling
    await MobileAds.instance.initialize();
    final settingsRepository = SettingsRepository();
    final bool onboardingComplete = await settingsRepository.getOnboardingComplete();
    final bool isDark = await settingsRepository.getThemeIsDark();

    runApp(AuraCleanApp(
      onboardingComplete: onboardingComplete,
      isDark: isDark,
      settingsRepository: settingsRepository,
    ));
  } catch (error) {
    // Fallback app if initialization fails
    runApp(const MaterialApp(
      title: 'Aura Clean',
      home: Scaffold(
        body: Center(
          child: Text('App initialization failed. Please restart.'),
        ),
      ),
    ));
  }
}

class AuraCleanApp extends StatelessWidget {
  final bool onboardingComplete;
  final bool isDark;
  final SettingsRepository settingsRepository;

  const AuraCleanApp({
    super.key,
    required this.onboardingComplete,
    required this.isDark,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PurchaseBloc()),
        BlocProvider(
          create: (context) => ThemeBloc(
            isDark: isDark,
            settingsRepository: settingsRepository,
          ),
        ),
        BlocProvider(
          create: (context) => PhotoCleanerBloc(
            PhotoRepository(),
            context.read<PurchaseBloc>(),
            settingsRepository,
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Aura Clean',
            theme: themeState.themeData,
            home: onboardingComplete
                ? const DashboardScreen()
                : const OnboardingScreen(),
            debugShowCheckedModeBanner: false,
            // Add performance optimizations to prevent crashes
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0), // Prevent text scaling issues
                ),
                child: child!,
              );
            },
            // Disable animations during development to prevent crashes
            showPerformanceOverlay: false,
            // Add error boundary
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Page not found'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
