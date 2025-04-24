import 'dart:async';
import 'dart:io';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/feed.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/local_database.dart';

class FeedService {
  final FeedRepository _repository;
  final LocalDatabase _database;
  Timer? _refreshTimer;
  
  FeedService({
    required FeedRepository repository,
    required LocalDatabase database,
  }) : _repository = repository,
       _database = database;

  Future<void> initialize() async {
    AppLogger.info("Initializing FeedService");
    try {
      await _ensureDatabaseInitialized();
      
      // Check if we have feeds, if not, add a default one
      final feeds = await getAllFeeds();
      AppLogger.info("Found ${feeds.length} feeds in database");
      
      if (feeds.isEmpty) {
        AppLogger.info("No feeds found, adding InfoQ feed");
        await _addDefaultFeed();
      }
    } catch (e, stackTrace) {
      AppLogger.error("Error initializing FeedService", e, stackTrace);
      rethrow;
    }
  }
  
  Future<void> _ensureDatabaseInitialized() async {
    try {
      // Access database to initialize it
      await _database.database;
      AppLogger.info("Database initialized successfully");
    } catch (e, stackTrace) {
      AppLogger.error("Failed to initialize database", e, stackTrace);
      rethrow;
    }
  }
  
  Future<void> _addDefaultFeed() async {
    try {
      AppLogger.info("Adding default InfoQ feed");
      final feed = Feed(
        url: 'https://feed.infoq.com/InfoQ/',
        title: 'InfoQ',
        description: 'Software Development News',
      );
      
      try {
        final result = await addFeed(feed);
        if (result != null) {
          AppLogger.info("Default feed added successfully with ID: ${result.id}");
          return; // Success, no need to try fallback
        } else {
          AppLogger.warning("Default feed could not be added");
        }
      } catch (e, stackTrace) {
        AppLogger.error("Error adding primary feed", e, stackTrace);
        // Continue to fallback
      }
      
      // Try fallback feeds if InfoQ fails
      AppLogger.info("Trying fallback feed (NYT)");
      final fallbackFeed = Feed(
        url: 'https://rss.nytimes.com/services/xml/rss/nyt/Technology.xml',
        title: 'NY Times Technology',
        description: 'Technology News',
      );
      
      try {
        final result = await addFeed(fallbackFeed);
        if (result != null) {
          AppLogger.info("Fallback feed added successfully with ID: ${result.id}");
          return;
        }
      } catch (e, stackTrace) {
        AppLogger.error("Error adding fallback feed (NYT)", e, stackTrace);
      }
      
      // Try another fallback
      AppLogger.info("Trying second fallback feed (CNN)");
      final secondFallbackFeed = Feed(
        url: 'http://rss.cnn.com/rss/edition_technology.rss',
        title: 'CNN Technology',
        description: 'CNN Technology News',
      );
      
      try {
        final result = await addFeed(secondFallbackFeed);
        if (result != null) {
          AppLogger.info("Second fallback feed added successfully with ID: ${result.id}");
        } else {
          AppLogger.warning("All feed attempts failed");
        }
      } catch (e, stackTrace) {
        AppLogger.error("Error adding second fallback feed", e, stackTrace);
      }
    } catch (e, stackTrace) {
      AppLogger.error("Error in default feed initialization", e, stackTrace);
    }
  }
  
  void startRefreshTimer(int intervalMinutes) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => refreshFeeds(),
    );
  }
  
  Future<List<FeedItem>> refreshFeeds() async {
    try {
      AppLogger.info("Refreshing feeds");
      final result = await _repository.refreshFeeds();
      return result.fold(
        (failure) {
          AppLogger.error("Failed to refresh feeds: ${failure.message}");
          return [];
        },
        (items) {
          AppLogger.info("Fetched ${items.length} feed items");
          return items;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error("Error refreshing feeds", e, stackTrace);
      return [];
    }
  }
  
  Future<List<Feed>> getAllFeeds() async {
    try {
      AppLogger.info("Getting all feeds");
      final result = await _repository.getAllFeeds();
      return result.fold(
        (failure) {
          AppLogger.error("Failed to get feeds: ${failure.message}");
          return [];
        },
        (feeds) {
          AppLogger.info("Found ${feeds.length} feeds");
          return feeds;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error("Error getting feeds", e, stackTrace);
      return [];
    }
  }
  
  Future<Feed?> addFeed(Feed feed) async {
    try {
      AppLogger.info("Adding feed: ${feed.url}");
      final result = await _repository.addFeed(feed);
      return result.fold(
        (failure) {
          AppLogger.error("Failed to add feed: ${failure.message}");
          return null;
        },
        (newFeed) {
          AppLogger.info("Feed added with ID: ${newFeed.id}");
          return newFeed;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error("Error adding feed", e, stackTrace);
      return null;
    }
  }
  
  Future<bool> deleteFeed(int feedId) async {
    final result = await _repository.deleteFeed(feedId);
    return result.fold(
      (failure) => false,
      (success) => success,
    );
  }
  
  void dispose() {
    _refreshTimer?.cancel();
  }
}