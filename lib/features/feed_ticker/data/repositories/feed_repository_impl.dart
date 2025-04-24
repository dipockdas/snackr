import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/feed.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_data_source.dart';
import '../datasources/feed_remote_data_source.dart';
import '../models/feed_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedLocalDataSource localDataSource;
  final FeedRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FeedRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Feed>>> getAllFeeds() async {
    try {
      final feeds = await localDataSource.getAllFeeds();
      return Right(feeds);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Feed>>> getFeedsByCategory(String category) async {
    try {
      final feeds = await localDataSource.getFeedsByCategory(category);
      return Right(feeds);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Feed>> addFeed(Feed feed) async {
    try {
      final isConnected = await networkInfo.isConnected;
      
      if (!isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
      
      // Ensure feed is a FeedModel
      final feedToAdd = feed is FeedModel ? feed as FeedModel : FeedModel.fromFeed(feed);
      
      // Fetch feed metadata to ensure URL is valid and get title, etc.
      final feedMetadata = await remoteDataSource.fetchFeedMetadata(feedToAdd.url);
      
      // Update the feed with metadata from remote
      final feedModel = FeedModel(
        url: feedToAdd.url,
        title: feedMetadata.title,
        description: feedMetadata.description,
        imageUrl: feedMetadata.imageUrl,
        website: feedMetadata.website,
        isActive: feedToAdd.isActive,
        updateFrequencyMinutes: feedToAdd.updateFrequencyMinutes,
        category: feedToAdd.category,
      );
      
      // Save to local database
      final savedFeed = await localDataSource.addFeed(feedModel);
      
      // Fetch and save initial items
      final items = await remoteDataSource.fetchFeedItems(
        feedToAdd.url, 
        savedFeed.id!,
      );
      
      await localDataSource.saveFeedItems(items);
      
      return Right(savedFeed);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ParseException catch (e) {
      return Left(ParseFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Feed>> updateFeed(Feed feed) async {
    try {
      final feedModel = FeedModel.fromFeed(feed);
      final updatedFeed = await localDataSource.updateFeed(feedModel);
      return Right(updatedFeed);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFeed(int feedId) async {
    try {
      final result = await localDataSource.deleteFeed(feedId);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<FeedItem>>> getFeedItems(int feedId, {int limit = 50}) async {
    try {
      final items = await localDataSource.getFeedItems(feedId, limit: limit);
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<FeedItem>>> getAllFeedItems({int limit = 50}) async {
    try {
      final items = await localDataSource.getAllFeedItems(limit: limit);
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<FeedItem>>> getUnreadFeedItems({int limit = 50}) async {
    try {
      final items = await localDataSource.getUnreadFeedItems(limit: limit);
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<FeedItem>>> getStarredFeedItems({int limit = 50}) async {
    try {
      final items = await localDataSource.getStarredFeedItems(limit: limit);
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, FeedItem>> updateFeedItemStatus(
    int itemId, {
    bool? isRead,
    bool? isStarred,
  }) async {
    try {
      final updatedItem = await localDataSource.updateFeedItemStatus(
        itemId,
        isRead: isRead,
        isStarred: isStarred,
      );
      return Right(updatedItem);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<FeedItem>>> refreshFeeds() async {
    try {
      final isConnected = await networkInfo.isConnected;
      
      if (!isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
      
      final feeds = await localDataSource.getAllFeeds();
      final allNewItems = <FeedItem>[];
      
      for (final feed in feeds) {
        if (feed.isActive && feed.id != null) {
          try {
            final newItems = await remoteDataSource.fetchFeedItems(
              feed.url,
              feed.id!,
            );
            await localDataSource.saveFeedItems(newItems);
            allNewItems.addAll(newItems);
            
            // Update feed's lastUpdated
            await localDataSource.updateFeed(
              feed.copyWith(lastUpdated: DateTime.now()) as FeedModel,
            );
          } catch (e) {
            // Continue with next feed even if one fails
            continue;
          }
        }
      }
      
      return Right(allNewItems);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeedItem>>> refreshFeed(int feedId) async {
    try {
      final isConnected = await networkInfo.isConnected;
      
      if (!isConnected) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
      
      final feeds = await localDataSource.getAllFeeds();
      final feed = feeds.firstWhere((f) => f.id == feedId);
      
      final newItems = await remoteDataSource.fetchFeedItems(
        feed.url,
        feed.id!,
      );
      
      await localDataSource.saveFeedItems(newItems);
      
      // Update feed's lastUpdated
      await localDataSource.updateFeed(
        feed.copyWith(lastUpdated: DateTime.now()) as FeedModel,
      );
      
      return Right(newItems);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Feed>>> importOpml(String opmlContent) async {
    // This would normally parse OPML XML and add feeds
    // For simplicity, we're skipping the implementation
    return Left(ServerFailure(message: 'OPML import not implemented'));
  }

  @override
  Future<Either<Failure, String>> exportOpml() async {
    // This would normally generate OPML XML from feeds
    // For simplicity, we're skipping the implementation
    return Left(ServerFailure(message: 'OPML export not implemented'));
  }
}