// This is a stub implementation for desktop_multi_window
// to use when the actual package doesn't work correctly

import 'dart:convert';
import 'package:flutter/material.dart';

/// Stub implementation of DesktopMultiWindow that doesn't depend on the actual package
class DesktopMultiWindow {
  /// Creates a stub window that doesn't actually create an OS window
  static Future<WindowController> createWindow(String args) async {
    print('STUB: Creating window with args: $args');
    return WindowController(99); // Dummy window ID
  }

  /// Gets the current window ID (always returns 0 for main window)
  static int getCurrentWindowId() {
    return 0;
  }

  /// Close a window (no-op in stub)
  static Future<void> close(int windowId) async {
    print('STUB: Closing window $windowId');
  }

  /// Set window closed callback (no-op in stub)
  static void setWindowClosedCallback(Function(int windowId) callback) {
    print('STUB: Setting window closed callback');
  }
}

/// Stub controller for windows
class WindowController {
  final int windowId;

  WindowController(this.windowId);

  /// Set the window title (no-op in stub)
  Future<void> setTitle(String title) async {
    print('STUB: Setting window $windowId title to: $title');
  }

  /// Set the window frame (no-op in stub)
  Future<void> setFrame(Rect frame) async {
    print('STUB: Setting window $windowId frame to: $frame');
  }

  /// Center the window (no-op in stub)
  Future<void> center() async {
    print('STUB: Centering window $windowId');
  }

  /// Show the window (no-op in stub)
  Future<void> show() async {
    print('STUB: Showing window $windowId');
  }
}