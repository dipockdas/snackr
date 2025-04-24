import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../ticker.dart';
import 'dialog_window_manager.dart';

/// Provider to expose a method to show the settings dialog using the dialog window manager
final showSettingsDialogProvider = Provider<Future<void> Function(BuildContext)>((ref) {
  final dialogManager = ref.watch(dialogWindowManagerProvider);
  
  return (BuildContext context) async {
    await dialogManager.showDialogWindow<void>(
      dialogId: 'settings_dialog',
      title: 'Settings',
      width: 500,
      height: 400,
      builder: (context) => const SettingsDialog(),
    );
  };
});

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  double _scrollSpeed = 200; // Default scroll duration in seconds

  @override
  void initState() {
    super.initState();
    AppLogger.info('Initializing settings dialog');
    // Get the current value
    _scrollSpeed = tickerScrollDurationSeconds.value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(  // Wrap in SingleChildScrollView to prevent overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Ticker Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Content
            const Text('Scroll Speed:', style: TextStyle(color: Colors.white)),
            Row(
              children: [
                const Text('Fast', style: TextStyle(color: Colors.white70)),
                Expanded(
                  child: Slider(
                    value: _scrollSpeed,
                    min: 50, // Faster (50 seconds)
                    max: 300, // Slower (300 seconds)
                    divisions: 25,
                    onChanged: (value) {
                      setState(() {
                        _scrollSpeed = value;
                      });
                    },
                  ),
                ),
                const Text('Slow', style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Changes will be applied immediately. The speed setting is temporary and will reset to default on app restart.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            // Dialog actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () {
                    // Close the window through window manager
                    ref.read(dialogWindowManagerProvider).closeDialog('settings_dialog');
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Update the global scroll speed
                    tickerScrollDurationSeconds.value = _scrollSpeed.toInt();
                    AppLogger.info('Updated scroll duration to ${_scrollSpeed.toInt()} seconds');
                    // Close the window through window manager
                    ref.read(dialogWindowManagerProvider).closeDialog('settings_dialog');
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}