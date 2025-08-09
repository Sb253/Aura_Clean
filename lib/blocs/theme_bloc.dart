import 'package:aura_clean/app/themes.dart';
import 'package:aura_clean/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura_clean/blocs/theme_event.dart';
import 'package:aura_clean/blocs/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsRepository _settingsRepository;

  ThemeBloc({required bool isDark, required this.settingsRepository})
      : super(ThemeState(themeData: isDark ? AppThemes.darkTheme : AppThemes.lightTheme)) {
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final theme = event.isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
    emit(ThemeState(themeData: theme));
    await _settingsRepository.setThemeIsDark(event.isDark);
  }
}
