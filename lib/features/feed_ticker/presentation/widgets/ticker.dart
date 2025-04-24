import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/html_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/multi_window_manager.dart';
import '../../../../core/utils/popup_window.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/feed_item.dart';
import '../providers/feed_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/service_providers.dart';
import 'dialogs/dialog_window_manager.dart';
import 'dialogs/manual_feed_dialog.dart';
import 'ticker_item.dart';

// Global ValueNotifier for the scroll duration (seconds)
final ValueNotifier<int> tickerScrollDurationSeconds = ValueNotifier<int>(200);

class Ticker extends ConsumerStatefulWidget {
  const Ticker({Key? key}) : super(key: key);

  @override
  ConsumerState<Ticker> createState() => _TickerState();
}

class _TickerState extends ConsumerState<Ticker> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _scrollAnimation;
  Timer? _refreshTimer;
  Timer? _scrollResetTimer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info('Initializing Ticker widget');
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: tickerScrollDurationSeconds.value), // Use global value
    );
    
    // Listen to changes in the global scroll duration
    tickerScrollDurationSeconds.addListener(_updateScrollSpeed);
    
    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1000.0, // Will be adjusted based on content width
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear, // Use linear curve for smooth scrolling
    ))
      ..addListener(() {
        if (!_isPaused && _scrollController.hasClients) {
          _scrollController.jumpTo(_scrollAnimation.value);
        }
      });
    
    _animationController.repeat();
    
    // Set up the refresh timer
    _setUpRefreshTimer();
    
    // Initial load of feeds
    Future.microtask(() async {
      AppLogger.info('Fetching initial feed items');
      try {
        // Force refresh feeds
        final feedService = ref.read(feedServiceProvider);
        final items = await feedService.refreshFeeds();
        AppLogger.info('Fetched ${items.length} feed items');
      } catch (e, stackTrace) {
        AppLogger.error('Error fetching initial feed items', e, stackTrace);
      }
    });
  }

  void _setUpRefreshTimer() {
    try {
      final settings = ref.read(settingsNotifierProvider).value;
      if (settings != null) {
        AppLogger.info('Setting up refresh timer for ${settings.refreshIntervalMinutes} minutes');
        _refreshTimer?.cancel();
        
        // Use a shorter interval for testing (1 minute instead of settings.refreshIntervalMinutes)
        _refreshTimer = Timer.periodic(
          const Duration(minutes: 1),
          (_) {
            AppLogger.info('Timer triggered - refreshing feeds');
            // Use FeedService directly for better error handling
            ref.read(feedServiceProvider).refreshFeeds().then((items) {
              AppLogger.info('Refreshed ${items.length} feed items');
            }).catchError((e, stackTrace) {
              AppLogger.error('Error refreshing feeds from timer', e, stackTrace);
            });
          },
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error setting up refresh timer', e, stackTrace);
    }
  }

  void _resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _updateScrollSpeed() {
    // Use the global duration value
    _animationController.duration = Duration(seconds: tickerScrollDurationSeconds.value);
    
    AppLogger.info('Updated scroll animation duration to ${tickerScrollDurationSeconds.value} seconds');
    
    // Need to restart animation with new duration
    if (_animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    // Remove the listener
    tickerScrollDurationSeconds.removeListener(_updateScrollSpeed);
    
    _animationController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    _scrollResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final feedItemsAsync = ref.watch(feedItemsNotifierProvider());

    AppLogger.debug('Building ticker widget - items state: ${feedItemsAsync.valueOrNull?.length ?? 0} items');

    // Check if settings have changed and update the scroll speed
    if (settingsAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollSpeed();
      });
    }

    return settingsAsync.when(
      data: (settings) {
        return feedItemsAsync.when(
          data: (items) {
            // Log what we're displaying
            AppLogger.info('Displaying ${items.length} feed items');
            
            if (items.isEmpty) {
              // If no items, show a placeholder and trigger a refresh
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(feedServiceProvider).refreshFeeds();
              });
              
              return Container(
                height: settings.tickerHeight,
                decoration: BoxDecoration(
                  color: settings.tickerBackgroundColor.withOpacity(settings.opacity),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No feed items available',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show feed dialog via event bus or callback
                          AppLogger.info('Manual feed button pressed');
                          showDialog(
                            context: context,
                            builder: (context) => const ManualFeedDialog(),
                          ).then((_) {
                            ref.invalidate(feedItemsNotifierProvider);
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Feed Manually'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Adjust the animation target based on content
            final contentWidth = items.length * 250.0;
            _scrollAnimation = Tween<double>(
              begin: 0.0,
              end: contentWidth > 0 ? contentWidth : 1000.0, // Ensure we have a valid width
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.linear, // Use linear curve for smooth scrolling
            ));
            
            // Reset animation if needed and enforce slow speed
            _updateScrollSpeed();
            if (!_animationController.isAnimating) {
              _animationController.reset();
              _animationController.forward();
            }
            
            return MouseRegion(
              onEnter: (_) {
                // Pause scrolling when mouse enters
                if (!_isPaused) {
                  setState(() {
                    _isPaused = true;
                    _animationController.stop();
                  });
                }
              },
              onExit: (_) {
                // Resume scrolling when mouse exits
                if (_isPaused) {
                  setState(() {
                    _isPaused = false;
                    _animationController.forward();
                  });
                }
              },
              child: GestureDetector(
                onTap: () {
                  // Toggle pause on tap (for mobile or manual control)
                  setState(() {
                    _isPaused = !_isPaused;
                    if (_isPaused) {
                      _animationController.stop();
                    } else {
                      _animationController.forward();
                    }
                  });
                },
                child: Container(
                  height: settings.tickerHeight,
                  decoration: BoxDecoration(
                    color: settings.tickerBackgroundColor.withOpacity(settings.opacity),
                  ),
                  child: _buildTickerContent(items, settings),
                ),
              ),
            );
          },
          loading: () {
            AppLogger.debug('Feed items loading...');
            return _buildLoadingIndicator();
          },
          error: (error, stack) {
            AppLogger.error('Error loading feed items', error, stack);
            return _buildErrorWidget();
          },
        );
      },
      loading: () {
        AppLogger.debug('Settings loading...');
        return _buildLoadingIndicator();
      },
      error: (error, stack) {
        AppLogger.error('Error loading settings', error, stack);
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildTickerContent(List<FeedItem> items, AppSettings settings) {
    // Horizontal scrolling ticker
    if (settings.scrollDirection == ScrollDirection.leftToRight || 
        settings.scrollDirection == ScrollDirection.rightToLeft) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildTickerItem(items[index], settings.showImagesInTicker);
        },
      );
    } 
    // Vertical scrolling ticker
    else {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildTickerItem(items[index], settings.showImagesInTicker);
        },
      );
    }
  }

  Widget _buildTickerItem(FeedItem item, bool showImages) {
    return TickerItem(
      item: item,
      showImage: showImages,
      onTap: () => _showItemDetail(item),
      onReadToggle: () => _handleReadToggle(item),
      onStarToggle: () => _handleStarToggle(item),
    );
  }

  void _showItemDetail(FeedItem item) {
    // Mark as read
    ref.read(feedItemsNotifierProvider().notifier).markAsRead(item.id!);
    
    // Debug the item contents
    AppLogger.info('Showing item detail: ${item.title}');
    if (item.description != null && item.description!.isNotEmpty) {
      final previewLength = math.min(100, item.description!.length);
      AppLogger.info('Item description: ${item.description!.substring(0, previewLength)}...');
    }
    
    // Convert to map for passing to new window
    final articleData = {
      'title': HtmlUtils.decodeHtml(item.title),
      'description': item.description != null ? HtmlUtils.decodeHtml(item.description!) : null,
      'content': item.content != null ? HtmlUtils.decodeHtml(item.content!) : null,
      'author': item.author,
      'imageUrl': item.imageUrl,
      'link': item.link,
      'isStarred': item.isStarred,
      'itemId': item.id,
    };
    
    // Open in a separate window
    ref.read(multiWindowManagerProvider).openArticleDetail(
      title: HtmlUtils.decodeHtml(item.title), 
      articleData: articleData,
    );
    
    // Removed old popup code
  }

  void _handleReadToggle(FeedItem item) {
    if (item.id != null) {
      ref.read(feedItemsNotifierProvider().notifier).markAsRead(item.id!);
    }
  }

  void _handleStarToggle(FeedItem item) {
    if (item.id != null) {
      ref.read(feedItemsNotifierProvider().notifier).toggleStar(item.id!, item.isStarred);
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Text(
          'Failed to load feed items',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}