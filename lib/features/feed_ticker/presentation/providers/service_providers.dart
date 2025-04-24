import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/feed_service.dart';
import '../../domain/entities/feed.dart';
import 'feed_providers.dart';

final feedServiceProvider = Provider<FeedService>((ref) {
  final service = FeedService(
    repository: ref.watch(feedRepositoryProvider),
    database: ref.watch(databaseProvider),
  );
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

final initializationProvider = FutureProvider<bool>((ref) async {
  final feedService = ref.watch(feedServiceProvider);
  await feedService.initialize();
  
  final feeds = await feedService.getAllFeeds();
  
  // If no feeds, add InfoQ feed
  if (feeds.isEmpty) {
    // Add the feed directly through the service to bypass model differences
    await feedService.addFeed(
      Feed(
        url: 'https://feed.infoq.com/InfoQ/',
        title: 'InfoQ',
        description: 'Software Development News',
      ),
    );
  }
  
  return true;
});