import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/measurement/presentation/controllers/measurement_controller.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize offline persistent local cache
  final sharedPreferences = await SharedPreferences.getInstance();

  //Safe Firebase Core & Crashlytics initialization (non-blocking, supports offline/first-run)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    debugPrint('[Firebase] Successfully initialized Firebase & Crashlytics');
  } catch (e) {
    debugPrint(
      '[Firebase] Firebase not initialized or running in offline mode: $e',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const PrideKmphMeterApp(),
    ),
  );
}

class PrideKmphMeterApp extends ConsumerWidget {
  const PrideKmphMeterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final isDark = settings.instrumentTheme == 'OLED_DARK';

    return MaterialApp.router(
      title: 'Pride KMPH Meter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
