import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:docstep_mobile/main.dart';
import 'package:docstep_mobile/providers/auth_provider.dart';
import 'package:docstep_mobile/providers/data_provider.dart';

void setupMockChannels() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase Core MethodChannel
  const MethodChannel coreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(coreChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return <String, dynamic>{
        'name': '[DEFAULT]',
        'options': <String, String>{
          'apiKey': 'test',
          'appId': 'test',
          'messagingSenderId': 'test',
          'projectId': 'test',
        },
        'pluginConstants': <String, dynamic>{},
      };
    }
    if (methodCall.method == 'Firebase#initializeApp') {
      return <String, dynamic>{
        'name': methodCall.arguments['appName'],
        'options': methodCall.arguments['options'],
        'pluginConstants': <String, dynamic>{},
      };
    }
    return null;
  });

  // Mock Firebase Auth MethodChannel
  const MethodChannel authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(authChannel, (MethodCall methodCall) async {
    return null;
  });

  // Mock Cloud Firestore MethodChannel
  const MethodChannel firestoreChannel = MethodChannel('plugins.flutter.io/cloud_firestore');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firestoreChannel, (MethodCall methodCall) async {
    return null;
  });
}

void main() {
  setupMockChannels();

  testWidgets('Splash screen loads app title and subtitle', (WidgetTester tester) async {
    // Build our app under MultiProvider and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => DataProvider()),
        ],
        child: const DocStepApp(),
      ),
    );

    // Verify that our app name and tagline are shown on the splash screen.
    expect(find.text('DocStep'), findsOneWidget);
    expect(find.text('Medical Community & Career Portal'), findsOneWidget);

    // Verify that the loading indicator is present.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the splash screen's 2.5s timer and animations to complete and settle the navigation
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
