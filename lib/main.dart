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
  // Initialize services
  await MobileAds.instance.initialize();
  final settingsRepository = SettingsRepository();
  final bool onboardingComplete = await settingsRepository.getOnboardingComplete();
  final bool isDark = await settingsRepository.getThemeIsDark();

  runApp(AuraCleanApp(
    onboardingComplete: onboardingComplete,
    isDark: isDark,
    settingsRepository: settingsRepository,
  ));
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
    final PhotoRepository photoRepository = PhotoRepository();

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
            photoRepository,
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
          );
        },
      ),
    );
  }
}
