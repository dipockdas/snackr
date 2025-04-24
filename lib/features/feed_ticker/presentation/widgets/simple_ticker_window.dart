import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/multi_window_manager.dart';
import '../../../../core/utils/popup_window.dart';
import '../providers/feed_providers.dart';
import '../providers/service_providers.dart';
import 'dialogs/dialog_window_manager.dart';
import 'dialogs/manual_feed_dialog.dart';
import 'dialogs/settings_dialog.dart';
import 'dialogs/starred_items_dialog.dart';
import 'ticker.dart';

/// Provider to show the manual feed dialog in a separate window
final showManualFeedDialogProvider = Provider<Future<void> Function(BuildContext context)>((ref) {
  final dialogManager = ref.watch(dialogWindowManagerProvider);
  
  return (BuildContext context) async {
    await dialogManager.showDialogWindow<void>(
      dialogId: 'add_feed_dialog',
      title: 'Add Feed',
      width: 600,
      height: 400,
      builder: (context) => const ManualFeedDialog(),
    );
    
    // Refresh feed items after dialog closes
    ref.refresh(feedItemsNotifierProvider());
  };
});

/// Provider to show the starred items dialog in a separate window
final showStarredItemsDialogProvider = Provider<Future<void> Function(BuildContext)>((ref) {
  final dialogManager = ref.watch(dialogWindowManagerProvider);
  
  return (BuildContext context) async {
    await dialogManager.showDialogWindow<void>(
      dialogId: 'starred_items_dialog',
      title: 'Starred Items',
      width: 800,
      height: 600,
      builder: (context) => const StarredItemsDialog(),
    );
  };
});

/// A simplified ticker window that doesn't use window_manager
/// to avoid the platform message errors
class SimpleTickerWindow extends ConsumerStatefulWidget {
  const SimpleTickerWindow({Key? key}) : super(key: key);

  @override
  ConsumerState<SimpleTickerWindow> createState() => _SimpleTickerWindowState();
}

class _SimpleTickerWindowState extends ConsumerState<SimpleTickerWindow> {

  @override
  void initState() {
    super.initState();
    AppLogger.info('Initializing SimpleTickerWindow');
    
    // Force refresh feeds on start
    Future.microtask(() async {
      try {
        final feedService = ref.read(feedServiceProvider);
        AppLogger.info('Initial feed refresh from SimpleTickerWindow');
        final items = await feedService.refreshFeeds();
        AppLogger.info('Initial refresh complete, got ${items.length} items');
      } catch (e, stackTrace) {
        AppLogger.error('Error during initial feed refresh', e, stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: Ticker(),
          ),
          
          // Always visible control menu
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
                      onPressed: () => ref.read(multiWindowManagerProvider).openSettings(),
                      tooltip: 'Settings',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => ref.read(multiWindowManagerProvider).openFeedManager(),
                      tooltip: 'Add Feed',
                    ),
                    IconButton(
                      icon: const Icon(Icons.star, color: Colors.amber),
                      onPressed: () => ref.read(multiWindowManagerProvider).openStarredItems(),
                      tooltip: 'Starred Items',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _showExitDialog,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showExitDialog() {
    AppLogger.info('Close button pressed');
    PopupWindow.show(
      context: context,
      title: 'Exit Confirmation',
      builder: (context) => Container(
        width: 400,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Exit Snackr?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to exit?',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                  onPressed: () {
                    // Just close the dialog for now, don't exit
                    Navigator.of(context).pop(); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Close button pressed - app continues running for testing')),
                    );
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}