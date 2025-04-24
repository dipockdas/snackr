import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/feed_model.dart';
import '../models/feed_item_model.dart';
import 'local_database.dart';

abstract class FeedLocalDataSource {
  Future<List<FeedModel>> getAllFeeds();
  Future<List<FeedModel>> getFeedsByCategory(String category);
  Future<FeedModel> addFeed(FeedModel feed);
  Future<FeedModel> updateFeed(FeedModel feed);
  Future<bool> deleteFeed(int feedId);
  Future<List<FeedItemModel>> getFeedItems(int feedId, {int limit = 50});
  Future<List<FeedItemModel>> getAllFeedItems({int limit = 50});
  Future<List<FeedItemModel>> getUnreadFeedItems({int limit = 50});
  Future<List<FeedItemModel>> getStarredFeedItems({int limit = 50});
  Future<FeedItemModel> updateFeedItemStatus(int itemId, {bool? isRead, bool? isStarred});
  Future<void> saveFeedItems(List<FeedItemModel> items);
  Future<FeedItemModel?> getFeedItemByGuid(String guid);
}

class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  final LocalDatabase database;

  FeedLocalDataSourceImpl({required this.database});

  @override
  Future<List<FeedModel>> getAllFeeds() async {
    final db = await database.database;
    final feedsData = await db.query('feeds');
    return feedsData.map((e) => FeedModel.fromJson(e)).toList();
  }

  @override
  Future<List<FeedModel>> getFeedsByCategory(String category) async {
    final db = await database.database;
    final feedsData = await db.query(
      'feeds',
      where: 'category = ?',
      whereArgs: [category],
    );
    return feedsData.map((e) => FeedModel.fromJson(e)).toList();
  }

  @override
  Future<FeedModel> addFeed(FeedModel feed) async {
    final db = await database.database;
    final id = await db.insert('feeds', feed.toJson());
    return feed.copyWith(id: id) as FeedModel;
  }

  @override
  Future<FeedModel> updateFeed(FeedModel feed) async {
    final db = await database.database;
    await db.update(
      'feeds',
      feed.toJson(),
      where: 'id = ?',
      whereArgs: [feed.id],
    );
    return feed;
  }

  @override
  Future<bool> deleteFeed(int feedId) async {
    final db = await database.database;
    final count = await db.delete(
      'feeds',
      where: 'id = ?',
      whereArgs: [feedId],
    );
    return count > 0;
  }

  @override
  Future<List<FeedItemModel>> getFeedItems(int feedId, {int limit = 50}) async {
    final db = await database.database;
    final itemsData = await db.query(
      'feed_items',
      where: 'feedId = ?',
      whereArgs: [feedId],
      orderBy: 'publishDate DESC',
      limit: limit,
    );
    return itemsData.map((e) => FeedItemModel.fromJson(e)).toList();
  }

  @override
  Future<List<FeedItemModel>> getAllFeedItems({int limit = 50}) async {
    final db = await database.database;
    final itemsData = await db.query(
      'feed_items',
      orderBy: 'publishDate DESC',
      limit: limit,
    );
    return itemsData.map((e) => FeedItemModel.fromJson(e)).toList();
  }

  @override
  Future<List<FeedItemModel>> getUnreadFeedItems({int limit = 50}) async {
    final db = await database.database;
    final itemsData = await db.query(
      'feed_items',
      where: 'isRead = 0',
      orderBy: 'publishDate DESC',
      limit: limit,
    );
    return itemsData.map((e) => FeedItemModel.fromJson(e)).toList();
  }

  @override
  Future<List<FeedItemModel>> getStarredFeedItems({int limit = 50}) async {
    final db = await database.database;
    final itemsData = await db.query(
      'feed_items',
      where: 'isStarred = 1',
      orderBy: 'publishDate DESC',
      limit: limit,
    );
    return itemsData.map((e) => FeedItemModel.fromJson(e)).toList();
  }

  @override
  Future<FeedItemModel> updateFeedItemStatus(
    int itemId, {
    bool? isRead,
    bool? isStarred,
  }) async {
    final db = await database.database;
    final Map<String, dynamic> updateValues = {};
    
    if (isRead != null) {
      updateValues['isRead'] = isRead ? 1 : 0;
    }
    
    if (isStarred != null) {
      updateValues['isStarred'] = isStarred ? 1 : 0;
    }
    
    await db.update(
      'feed_items',
      updateValues,
      where: 'id = ?',
      whereArgs: [itemId],
    );
    
    final updatedItem = await db.query(
      'feed_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
    
    return FeedItemModel.fromJson(updatedItem.first);
  }

  @override
  Future<void> saveFeedItems(List<FeedItemModel> items) async {
    final db = await database.database;
    final batch = db.batch();
    
    for (final item in items) {
      // Check if the item already exists using guid
      final existing = await getFeedItemByGuid(item.guid);
      
      if (existing != null) {
        // Skip if item already exists
        continue;
      }
      
      batch.insert(
        'feed_items',
        item.toJson(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.ignore,
      );
    }
    
    await batch.commit(noResult: true);
  }

  @override
  Future<FeedItemModel?> getFeedItemByGuid(String guid) async {
    final db = await database.database;
    final results = await db.query(
      'feed_items',
      where: 'guid = ?',
      whereArgs: [guid],
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return FeedItemModel.fromJson(results.first);
  }
}