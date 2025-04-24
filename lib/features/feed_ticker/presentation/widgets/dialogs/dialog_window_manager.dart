import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../core/utils/floating_window_route.dart';

// Provider for the dialog window manager
final dialogWindowManagerProvider = Provider<DialogWindowManager>((ref) {
  return DialogWindowManager();
});

/// Manages separate windows for dialogs
class DialogWindowManager {
  // Track currently open dialog windows
  final Map<String, _DialogInfo> _openDialogs = {};
  
  /// Shows a widget in a separate dialog window
  Future<T?> showDialogWindow<T>({
    required String dialogId,
    required String title,
    required WidgetBuilder builder,
    double width = 600,
    double height = 500,
    bool center = true,
    bool resizable = true,
    bool alwaysOnTop = true,
    bool barrierDismissible = true,
  }) async {
    // Prepare a completer to handle the result
    final completer = Completer<T?>();
    
    // If a dialog with this ID is already open, just focus it
    if (_openDialogs.containsKey(dialogId)) {
      return null;
    }
    
    // Store dialog info
    _openDialogs[dialogId] = _DialogInfo(
      id: dialogId,
      completer: completer,
    );
    
    // Use our FloatingWindowRoute for proper display regardless of parent size
    Navigator.of(globalNavigatorKey.currentContext!).push(
      FloatingWindowRoute(
        windowId: dialogId,
        title: title,
        width: width,
        height: height,
        content: Builder(builder: builder),
        onClose: () {
          Navigator.of(globalNavigatorKey.currentContext!).pop();
          final info = _openDialogs.remove(dialogId);
          info?.completer.complete(null);
        },
      ),
    ).then((_) {
      // Remove from open dialogs when closed
      final info = _openDialogs.remove(dialogId);
      info?.completer.complete(null);
    });
    
    return completer.future;
  }
  
  /// Close a specific dialog by ID
  Future<void> closeDialog(String dialogId) async {
    if (_openDialogs.containsKey(dialogId)) {
      Navigator.of(globalNavigatorKey.currentContext!).pop();
      _openDialogs.remove(dialogId);
    }
  }
  
  /// Close all open dialogs
  Future<void> closeAllDialogs() async {
    if (_openDialogs.isEmpty) return;
    
    Navigator.of(globalNavigatorKey.currentContext!).popUntil((route) => route.isFirst);
    _openDialogs.clear();
  }
}

// Global navigator key for accessing context anywhere
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

// Info about an open dialog
class _DialogInfo<T> {
  final String id;
  final Completer<T?> completer;
  
  _DialogInfo({
    required this.id,
    required this.completer,
  });
}