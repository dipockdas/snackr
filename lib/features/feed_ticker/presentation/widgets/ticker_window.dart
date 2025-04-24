import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';
import '../providers/feed_providers.dart';
import 'dialogs/add_feed_dialog.dart';
import 'ticker.dart';

class TickerWindow extends ConsumerStatefulWidget {
  const TickerWindow({Key? key}) : super(key: key);

  @override
  ConsumerState<TickerWindow> createState() => _TickerWindowState();
}

class _TickerWindowState extends ConsumerState<TickerWindow> with WindowListener {
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info('Initializing TickerWindow');
    windowManager.addListener(this);
    _initializeWindow();
  }

  Future<void> _initializeWindow() async {
    try {
      AppLogger.info('Setting up window properties');
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
      await windowManager.setTitle('Snackr Feed Ticker');
      
      final settings = await ref.read(settingsNotifierProvider.future);
      AppLogger.info('Retrieved settings, applying to window');
      await _applyWindowSettings(settings);
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing window', e, stackTrace);
    }
  }

  Future<void> _applyWindowSettings(AppSettings settings) async {
    // Set size based on ticker position
    final isHorizontal = settings.tickerPosition == TickerPosition.top || 
                        settings.tickerPosition == TickerPosition.bottom;
    
    if (isHorizontal) {
      await windowManager.setSize(Size(settings.tickerWidth, settings.tickerHeight));
    } else {
      await windowManager.setSize(Size(settings.tickerHeight, settings.tickerWidth));
    }
    
    // Set position on screen
    // Get screen size using screen_retriever
    final screenInfo = await screenRetriever.getPrimaryDisplay();
    final screenWidth = screenInfo.visibleSize?.width ?? 1920.0;  // Default to 1920 if null
    final screenHeight = screenInfo.visibleSize?.height ?? 1080.0;  // Default to 1080 if null
    final windowSize = await windowManager.getSize();
    
    switch (settings.tickerPosition) {
      case TickerPosition.top:
        await windowManager.setPosition(Offset(
          (screenWidth - windowSize.width) / 2,
          0,
        ));
        break;
      case TickerPosition.bottom:
        await windowManager.setPosition(Offset(
          (screenWidth - windowSize.width) / 2,
          screenHeight - windowSize.height,
        ));
        break;
      case TickerPosition.left:
        await windowManager.setPosition(Offset(
          0,
          (screenHeight - windowSize.height) / 2,
        ));
        break;
      case TickerPosition.right:
        await windowManager.setPosition(Offset(
          screenWidth - windowSize.width,
          (screenHeight - windowSize.height) / 2,
        ));
        break;
    }
    
    // Set opacity
    await windowManager.setOpacity(settings.opacity);
    
    // Set always on top
    await windowManager.setAlwaysOnTop(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Show confirmation dialog
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Snackr?'),
        content: const Text('Are you sure you want to close Snackr Ticker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    
    if (shouldClose == true) {
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    
    return settingsAsync.when(
      data: (settings) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const Positioned.fill(
                child: Ticker(),
              ),
              // Control menu that appears on hover
              if (_isMenuVisible)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Card(
                    color: Colors.black.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: _showSettingsDialog,
                            tooltip: 'Settings',
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _showAddFeedDialog,
                            tooltip: 'Add Feed',
                          ),
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.amber),
                            onPressed: _showStarredItemsDialog,
                            tooltip: 'Starred Items',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () async {
                              await windowManager.close();
                            },
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Invisible hover detector for the entire window
              Positioned.fill(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isMenuVisible = true),
                  onExit: (_) => setState(() => _isMenuVisible = false),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Material(
        child: Center(
          child: Text('Failed to load settings'),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    // Show settings dialog - implementation pending
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Settings'),
        content: Text('Settings dialog to be implemented'),
      ),
    );
  }

  void _showAddFeedDialog() {
    AppLogger.info('Showing add feed dialog');
    showDialog(
      context: context,
      builder: (context) => const AddFeedDialog(),
    ).then((_) {
      // Force refresh after dialog closes
      AppLogger.info('Add feed dialog closed, refreshing feed items');
      ref.refresh(feedItemsNotifierProvider());
    });
  }

  void _showStarredItemsDialog() {
    // Show starred items dialog - implementation pending
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Starred Items'),
        content: Text('Starred items dialog to be implemented'),
      ),
    );
  }
}