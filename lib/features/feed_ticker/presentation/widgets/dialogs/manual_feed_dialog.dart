import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/feed.dart';
import '../../providers/feed_providers.dart';
import 'dialog_window_manager.dart';

/// A simple dialog for manually adding a feed URL with minimal UI
class ManualFeedDialog extends ConsumerStatefulWidget {
  const ManualFeedDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ManualFeedDialog> createState() => _ManualFeedDialogState();
}

class _ManualFeedDialogState extends ConsumerState<ManualFeedDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Default feed URLs to try
  final List<String> _suggestedFeeds = [
    'https://rss.nytimes.com/services/xml/rss/nyt/Technology.xml',
    'http://rss.cnn.com/rss/edition_technology.rss',
    'https://feeds.bbci.co.uk/news/technology/rss.xml',
    'https://news.google.com/rss',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Feed Manually',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form for manual entry
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter Feed URL:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _urlController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'Feed URL',
                            hintText: 'https://example.com/feed.xml',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: const TextStyle(color: Colors.black54),
                            hintStyle: const TextStyle(color: Colors.black38),
                            errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a URL';
                            }
                            
                            // Simple URL validation
                            if (!value.startsWith('http://') && !value.startsWith('https://')) {
                              return 'URL must start with http:// or https://';
                            }
                            
                            return null;
                          },
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white24),
                  
                  // Suggested feeds
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Or try one of these feeds:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[300],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // List of suggested feeds
                  ...List.generate(_suggestedFeeds.length, (index) {
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.black54,
                      child: ListTile(
                        title: Text(
                          _suggestedFeeds[index],
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        dense: true,
                        onTap: () {
                          _urlController.text = _suggestedFeeds[index];
                        },
                        trailing: ElevatedButton(
                          onPressed: () => _addFeed(_suggestedFeeds[index]),
                          child: const Text('Add'),
                        ),
                      ),
                    );
                  }),
                  
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: _isLoading
                    ? null
                    : () => ref.read(dialogWindowManagerProvider).closeDialog('add_feed_dialog'),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _addFeedFromForm,
                child: const Text('Add Feed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addFeedFromForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    _addFeed(_urlController.text.trim());
  }
  
  Future<void> _addFeed(String url) async {
    AppLogger.info('Adding feed manually: $url');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Create feed object with minimal info (the rest will be fetched)
      final feed = Feed(
        url: url,
        title: 'Loading...', // Will be replaced with actual title
      );
      
      // Add feed using the provider
      await ref.read(feedsNotifierProvider.notifier).addFeed(feed);
      
      if (mounted) {
        ref.read(dialogWindowManagerProvider).closeDialog('add_feed_dialog');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add feed: ${e.toString()}';
      });
      AppLogger.error('Error adding feed manually', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}