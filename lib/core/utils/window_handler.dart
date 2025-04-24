import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/desktop_multi_window_stub.dart';
import '../../features/feed_ticker/presentation/providers/feed_providers.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/settings_dialog.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/manual_feed_dialog.dart';
import '../../features/feed_ticker/presentation/widgets/dialogs/starred_items_dialog.dart';
import '../utils/logger.dart';

/// Handles secondary windows created by desktop_multi_window
class WindowHandler {
  /// Process arguments and return the appropriate widget for the window
  static Widget handleWindowWidget(WidgetRef ref, Map<String, dynamic> args) {
    final windowType = args['window_type'] as String?;
    final windowTitle = args['window_title'] as String? ?? 'Snackr';
    // Get current window ID (window ID is 0 for main window)
    
    AppLogger.info('Creating window of type: $windowType');
    
    switch (windowType) {
      case 'article_detail':
        return _buildArticleDetailWindow(ref, args, 0);
      case 'settings':
        return _buildSettingsWindow(0);
      case 'feed_manager':
        return _buildFeedManagerWindow(0);
      case 'starred_items':
        return _buildStarredItemsWindow(0);
      default:
        return Center(
          child: Text('Unknown window type: $windowType'),
        );
    }
  }
  
  /// Builds a window for article details
  static Widget _buildArticleDetailWindow(WidgetRef ref, Map<String, dynamic> args, int windowId) {
    final articleData = args['article_data'] as Map<String, dynamic>?;
    
    if (articleData == null) {
      return const Center(
        child: Text('No article data provided', style: TextStyle(color: Colors.white)),
      );
    }
    
    // Extract data needed for article detail
    final title = articleData['title'] as String? ?? 'Untitled';
    final content = articleData['content'] as String?;
    final description = articleData['description'] as String?;
    final author = articleData['author'] as String?;
    final imageUrl = articleData['imageUrl'] as String?;
    final link = articleData['link'] as String?;
    final isStarred = articleData['isStarred'] as bool? ?? false;
    final itemId = articleData['itemId'] as int?;
    
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(), // Close this window
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Author if available
              if (author != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'By $author',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 16,
                    ),
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
                      height: 300,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content != null && content.isNotEmpty)
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      )
                    else if (description != null && description.isNotEmpty)
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      )
                    else
                      const Text(
                        'No content available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Open in browser button if link is available
                  if (link != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open in Browser'),
                        onPressed: () async {
                          // Launch URL
                          try {
                            final url = Uri.parse(link);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              AppLogger.error('Could not launch $link');
                            }
                          } catch (e, stack) {
                            AppLogger.error('Error launching URL $link', e, stack);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  
                  // Star button
                  if (itemId != null)
                    Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton.icon(
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: isStarred ? Colors.amber : Colors.white,
                          ),
                          label: Text(isStarred ? 'Unstar' : 'Star'),
                          onPressed: () {
                            // Toggle star status
                            final notifier = ref.read(feedItemsNotifierProvider().notifier);
                            if (itemId != null) {
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            backgroundColor: isStarred ? Colors.amber.withOpacity(0.2) : null,
                          ),
                        );
                      }
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Builds a settings window
  static Widget _buildSettingsWindow(int windowId) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(), // Close this window
            ),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: SettingsDialog(),
        ),
      ),
    );
  }
  
  /// Builds a feed manager window
  static Widget _buildFeedManagerWindow(int windowId) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: const Text('Manage Feeds'),
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(), // Close this window
            ),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: ManualFeedDialog(),
        ),
      ),
    );
  }
  
  /// Builds a starred items window
  static Widget _buildStarredItemsWindow(int windowId) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: const Text('Starred Items'),
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(), // Close this window
            ),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: StarredItemsDialog(),
        ),
      ),
    );
  }
}