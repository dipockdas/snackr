import 'package:flutter/material.dart';

/// A utility class for displaying popups that truly break out of the parent window
class PopupWindow {
  /// Shows a full-screen overlay dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String title = 'Dialog',
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return showDialog<T>(
      context: context, 
      useSafeArea: false,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (_) => LayoutBuilder(
        builder: (context, constraints) {
          // Get available space and adjust dialog size
          final availableHeight = constraints.maxHeight - 40; // Allow for padding
          final availableWidth = constraints.maxWidth - 40;
          
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // This is the actual dialog with size constraints
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: availableWidth,
                      maxHeight: availableHeight,
                    ),
                    child: Builder(builder: builder),
                  ),
                ),
            
            // Close button at top-right
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}