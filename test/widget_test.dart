// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_clean/main.dart';
import 'package:aura_clean/repositories/settings_repository.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(AuraCleanApp(
      onboardingComplete: false,
      isDark: false,
      settingsRepository: SettingsRepository(),
    ));

    // Just verify the app was created successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Don't wait for animations to complete to avoid timer issues
    // The splash screen will have its own lifecycle management
  });
}
