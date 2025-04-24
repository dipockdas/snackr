import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/feed.dart';
import '../entities/feed_item.dart';

/// Interface for feed repository
abstract class FeedRepository {
  /// Get all feeds
  Future<Either<Failure, List<Feed>>> getAllFeeds();

  /// Get feeds by category
  Future<Either<Failure, List<Feed>>> getFeedsByCategory(String category);

  /// Add a new feed
  Future<Either<Failure, Feed>> addFeed(Feed feed);

  /// Update an existing feed
  Future<Either<Failure, Feed>> updateFeed(Feed feed);

  /// Delete a feed
  Future<Either<Failure, bool>> deleteFeed(int feedId);

  /// Get feed items by feed ID
  Future<Either<Failure, List<FeedItem>>> getFeedItems(int feedId, {int limit = 50});

  /// Get all feed items across all feeds
  Future<Either<Failure, List<FeedItem>>> getAllFeedItems({int limit = 50});

  /// Get unread feed items
  Future<Either<Failure, List<FeedItem>>> getUnreadFeedItems({int limit = 50});

  /// Get starred feed items
  Future<Either<Failure, List<FeedItem>>> getStarredFeedItems({int limit = 50});

  /// Update feed item status (read, starred)
  Future<Either<Failure, FeedItem>> updateFeedItemStatus(
      int itemId, {bool? isRead, bool? isStarred});

  /// Refresh feeds and get new items
  Future<Either<Failure, List<FeedItem>>> refreshFeeds();

  /// Refresh a specific feed and get new items
  Future<Either<Failure, List<FeedItem>>> refreshFeed(int feedId);

  /// Import feeds from OPML
  Future<Either<Failure, List<Feed>>> importOpml(String opmlContent);

  /// Export feeds to OPML
  Future<Either<Failure, String>> exportOpml();
}