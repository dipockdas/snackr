import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/utils/logger.dart';
import 'features/feed_ticker/presentation/pages/ticker_page.dart';
import 'features/feed_ticker/presentation/providers/service_providers.dart';
import 'features/feed_ticker/presentation/widgets/dialogs/dialog_window_manager.dart';

// Global error handler for uncaught errors
void _handleError(Object error, StackTrace stackTrace) {
  AppLogger.error('Uncaught exception', error, stackTrace);
}

Future<void> main(List<String> args) async {
  // Set up error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter error: ${details.exception}', details.exception, details.stack);
  };
  
  // Initialize AppLogger first
  AppLogger();
  AppLogger.info('Starting Snackr application');
  
  // Handle uncaught errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.info('Flutter initialized');
    
    // We're only supporting the main window for now
    
    try {
      // Initialize window manager for main window
      AppLogger.info('Initializing window manager');
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        size: Size(800, 150), // Taller to ensure enough space for ticker items
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        AppLogger.info('Showing window');
        await windowManager.show();
        await windowManager.focus();
      });

      AppLogger.info('Launching application');
      runApp(
        const ProviderScope(
          child: SnackrApp(),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error during app initialization', e, stackTrace);
      rethrow;
    }
  }, _handleError);
}

class SnackrApp extends ConsumerWidget {
  const SnackrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the initialization provider
    final initialization = ref.watch(initializationProvider);
    
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: 'Snackr',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: initialization.when(
        data: (_) {
          AppLogger.info('App initialization complete, showing ticker page');
          return const TickerPage();
        },
        loading: () {
          AppLogger.info('App still initializing, showing splash screen');
          return Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Snackr',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading feeds...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, stack) {
          AppLogger.error('App initialization failed', error, stack);
          return Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Initialization Failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Force retry initialization
                      ref.invalidate(initializationProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}