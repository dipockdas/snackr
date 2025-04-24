import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/logger.dart';
import '../utils/desktop_multi_window_stub.dart';
import '../utils/floating_window_route.dart';
import '../../features/feed_ticker/presentation/providers/feed_providers.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/dialog_window_manager.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/settings_dialog.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/manual_feed_dialog.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/starred_items_dialog.dart';

/// Manages separate OS-level windows for the application
class MultiWindowManager {
  // Track open windows by ID
  final Map<String, int> _openWindows = {};
  
  /// Opens a new window with the given content
  Future<void> openWindow({
    required String windowId,
    required String title,
    required Map<String, dynamic> arguments,
    double width = 800,
    double height = 600,
    bool resizable = true,
    bool center = true,
  }) async {
    try {
      // If window already exists, just return for now (no focus mechanism in this version)
      if (_openWindows.containsKey(windowId)) {
        return;
      }
      
      // Add window type to arguments
      arguments['window_id'] = windowId;
      arguments['window_title'] = title;
      
      // Show window content in a dialog
      AppLogger.info('Creating new window: $windowId (as dialog)');
      
      if (globalNavigatorKey.currentContext != null) {
        Navigator.of(globalNavigatorKey.currentContext!).push(
          FloatingWindowRoute(
            windowId: windowId,
            title: title,
            width: width,
            height: height,
            content: _buildWindowContent(arguments['window_type'] as String?, arguments),
            onClose: () {
              Navigator.of(globalNavigatorKey.currentContext!).pop();
              _openWindows.remove(windowId);
            },
          ),
        );
      } else {
        AppLogger.error('No context available to show dialog for $windowId');
      }
      
      // Track window ID
      _openWindows[windowId] = 99; // Dummy ID for now
      
      // We'll track window closure manually for now
      // Will be implemented with proper API in the future
      
    } catch (e, stack) {
      AppLogger.error('Error opening window', e, stack);
    }
  }
  
  /// Opens an article detail window
  Future<void> openArticleDetail({
    required String title,
    required Map<String, dynamic> articleData,
  }) async {
    await openWindow(
      windowId: 'article_detail_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      arguments: {
        'window_type': 'article_detail',
        'article_data': articleData,
      },
      width: 800,   // Keep width reasonable
      height: 800,  // Much taller to show all content
    );
  }
  
  /// Opens the settings window
  Future<void> openSettings() async {
    await openWindow(
      windowId: 'settings',
      title: 'Settings',
      arguments: {
        'window_type': 'settings',
      },
      width: 600,   // Standard width
      height: 800,  // Much taller to show all settings
    );
  }
  
  /// Opens the feed management window
  Future<void> openFeedManager() async {
    await openWindow(
      windowId: 'feed_manager',
      title: 'Manage Feeds',
      arguments: {
        'window_type': 'feed_manager',
      },
      width: 700,   // Standard width
      height: 800,  // Much taller to show all content and feed options
    );
  }
  
  /// Opens the starred items window
  Future<void> openStarredItems() async {
    await openWindow(
      windowId: 'starred_items',
      title: 'Starred Items',
      arguments: {
        'window_type': 'starred_items',
      },
      width: 800,   // Standard width
      height: 800,  // Much taller to show all starred items
    );
  }
  
  /// Closes a window by its ID
  Future<void> closeWindow(String windowId) async {
    if (_openWindows.containsKey(windowId)) {
      // In the simplified version, we'll just remove from tracking
      _openWindows.remove(windowId);
      AppLogger.info('Removed window from tracking: $windowId');
    } else {
      AppLogger.info('Window $windowId not found or already closed');
    }
  }
  
  /// Closes all windows except the main one
  Future<void> closeAllWindows() async {
    // In the simplified version, we'll just clear tracking
    _openWindows.clear();
    AppLogger.info('Cleared all window tracking');
  }
  
  /// Builds the specific content for a window type
  Widget _buildWindowContent(String? windowType, Map<String, dynamic> arguments) {
    switch (windowType) {
      case 'article_detail':
        return _buildArticleDetailContent(arguments);
      case 'settings':
        return const SettingsDialog(); // Use the actual SettingsDialog
      case 'feed_manager':
        return const ManualFeedDialog(); // Use the actual ManualFeedDialog
      case 'starred_items':
        return const StarredItemsDialog(); // Use the actual StarredItemsDialog
      default:
        return Center(child: Text('Unknown window type: $windowType', style: const TextStyle(color: Colors.white)));
    }
  }
  
  /// Builds the article detail content
  Widget _buildArticleDetailContent(Map<String, dynamic> arguments) {
    final articleData = arguments['article_data'] as Map<String, dynamic>?;
    
    if (articleData == null) {
      return const Center(child: Text('No article data provided', style: TextStyle(color: Colors.white)));
    }
    
    // Extract data
    final title = articleData['title'] as String? ?? 'Untitled';
    final content = articleData['content'] as String?;
    final description = articleData['description'] as String?;
    final author = articleData['author'] as String?;
    final imageUrl = articleData['imageUrl'] as String?;
    final link = articleData['link'] as String?;
    final isStarred = articleData['isStarred'] as bool? ?? false;
    final itemId = articleData['itemId'] as int?;
    
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),  // Increased padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              
              // Author
              if (author != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'By $author',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              
              // Image if available
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const SizedBox(
                        height: 100,
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Content
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content ?? description ?? 'No content available',
                  style: const TextStyle(
                    color: Colors.white, 
                    height: 1.5,
                    fontSize: 18,  // Larger font size for better readability
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Actions row
              Row(
                children: [
                  if (link != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open in Browser'),
                        onPressed: () async {
                          try {
                            final url = Uri.parse(link);
                            await launchUrl(url);
                          } catch (e) {
                            AppLogger.error('Error launching URL: $link', e);
                          }
                        },
                      ),
                    ),
                  
                  if (itemId != null) 
                    Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton.icon(
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: isStarred ? Colors.amber : null,
                          ),
                          label: Text(isStarred ? 'Unstar' : 'Star'),
                          onPressed: () {
                            if (itemId != null) {
                              final notifier = ref.read(feedItemsNotifierProvider().notifier);
                              notifier.toggleStar(itemId, isStarred);
                              
                              // Show confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isStarred ? 'Removed from starred items' : 'Added to starred items'
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider for the MultiWindowManager
final multiWindowManagerProvider = Provider<MultiWindowManager>((ref) {
  return MultiWindowManager();
});