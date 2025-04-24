import 'package:flutter/material.dart';

/// Custom route that creates a floating window positioned at the center of the screen
/// This breaks out of parent constraints and can be larger than the ticker window
class FloatingWindowRoute extends PopupRoute {
  final String windowId;
  final String title;
  final double width;
  final double height;
  final Widget content;
  final VoidCallback onClose;
  
  FloatingWindowRoute({
    required this.windowId,
    required this.title,
    required this.width,
    required this.height,
    required this.content,
    required this.onClose,
  });
  
  @override
  Color? get barrierColor => Colors.black54;
  
  @override
  bool get barrierDismissible => true;
  
  @override
  String? get barrierLabel => 'Dismiss';
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
  
  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    
    // Ensure the window is large enough to show content
    // At minimum, use 60% of screen width/height
    final adjustedWidth = width.clamp(screenSize.width * 0.6, screenSize.width * 0.9);
    final adjustedHeight = height.clamp(screenSize.height * 0.7, screenSize.height * 0.9);
    
    // Calculate the position to center the window
    final left = (screenSize.width - adjustedWidth) / 2;
    final top = (screenSize.height - adjustedHeight) / 2;
    
    return FadeTransition(
      opacity: animation,
      child: Stack(
        children: [
          // The actual floating window
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: adjustedWidth,
                height: adjustedHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: content,
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
}