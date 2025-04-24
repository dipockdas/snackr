import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/network_info.dart';
import '../../data/datasources/feed_local_data_source.dart';
import '../../data/datasources/feed_remote_data_source.dart';
import '../../data/datasources/local_database.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/feed.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/usecases/add_feed.dart';
import '../../domain/usecases/get_all_feed_items.dart';
import '../../domain/usecases/get_all_feeds.dart';
import '../../domain/usecases/refresh_feeds.dart';
import '../../domain/usecases/update_feed_item_status.dart';
import '../../../../core/usecases/usecase.dart';

part 'feed_providers.g.dart';

// Infrastructure providers
final databaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final feedLocalDataSourceProvider = Provider<FeedLocalDataSource>((ref) {
  return FeedLocalDataSourceImpl(database: ref.watch(databaseProvider));
});

final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  return FeedRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    localDataSource: ref.watch(feedLocalDataSourceProvider),
    remoteDataSource: ref.watch(feedRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use case providers
final getAllFeedsUseCaseProvider = Provider<GetAllFeeds>((ref) {
  return GetAllFeeds(ref.watch(feedRepositoryProvider));
});

final getAllFeedItemsUseCaseProvider = Provider<GetAllFeedItems>((ref) {
  return GetAllFeedItems(ref.watch(feedRepositoryProvider));
});

final addFeedUseCaseProvider = Provider<AddFeed>((ref) {
  return AddFeed(ref.watch(feedRepositoryProvider));
});

final updateFeedItemStatusUseCaseProvider = Provider<UpdateFeedItemStatus>((ref) {
  return UpdateFeedItemStatus(ref.watch(feedRepositoryProvider));
});

final refreshFeedsUseCaseProvider = Provider<RefreshFeeds>((ref) {
  return RefreshFeeds(ref.watch(feedRepositoryProvider));
});

// State providers
@riverpod
class FeedsNotifier extends _$FeedsNotifier {
  @override
  Future<List<Feed>> build() async {
    final useCase = ref.watch(getAllFeedsUseCaseProvider);
    final result = await useCase(NoParams());
    
    return result.fold(
      (failure) => [],
      (feeds) => feeds,
    );
  }
  
  Future<void> addFeed(Feed feed) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(addFeedUseCaseProvider);
    final result = await useCase(AddFeedParams(feed: feed));
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (newFeed) async {
        // Refresh the feed list
        final getAllFeeds = ref.read(getAllFeedsUseCaseProvider);
        final feedsResult = await getAllFeeds(NoParams());
        
        state = feedsResult.fold(
          (failure) => AsyncValue.error(failure.message, StackTrace.current),
          (feeds) => AsyncValue.data(feeds),
        );
      },
    );
  }
  
  Future<void> refreshFeeds() async {
    final useCase = ref.read(refreshFeedsUseCaseProvider);
    final result = await useCase(NoParams());
    
    result.fold(
      (failure) => null, // Ignore failures during refresh
      (newItems) async {
        // Refresh the feed list
        final getAllFeeds = ref.read(getAllFeedsUseCaseProvider);
        final feedsResult = await getAllFeeds(NoParams());
        
        state = feedsResult.fold(
          (failure) => AsyncValue.error(failure.message, StackTrace.current),
          (feeds) => AsyncValue.data(feeds),
        );
        
        // Also refresh feed items
        ref.invalidate(feedItemsNotifierProvider);
      },
    );
  }
}

@riverpod
class FeedItemsNotifier extends _$FeedItemsNotifier {
  @override
  Future<List<FeedItem>> build({int limit = 50}) async {
    final useCase = ref.watch(getAllFeedItemsUseCaseProvider);
    final result = await useCase(GetAllFeedItemsParams(limit: limit));
    
    return result.fold(
      (failure) => [],
      (items) => items,
    );
  }
  
  Future<void> markAsRead(int itemId) async {
    final useCase = ref.read(updateFeedItemStatusUseCaseProvider);
    final result = await useCase(
      UpdateFeedItemStatusParams(itemId: itemId, isRead: true),
    );
    
    result.fold(
      (failure) => null,
      (updatedItem) {
        state.whenData((items) {
          final index = items.indexWhere((item) => item.id == itemId);
          if (index != -1) {
            final updatedItems = [...items];
            updatedItems[index] = updatedItem;
            state = AsyncValue.data(updatedItems);
          }
        });
      },
    );
  }
  
  Future<void> toggleStar(int itemId, bool currentStarred) async {
    final useCase = ref.read(updateFeedItemStatusUseCaseProvider);
    final result = await useCase(
      UpdateFeedItemStatusParams(itemId: itemId, isStarred: !currentStarred),
    );
    
    result.fold(
      (failure) => null,
      (updatedItem) {
        state.whenData((items) {
          final index = items.indexWhere((item) => item.id == itemId);
          if (index != -1) {
            final updatedItems = [...items];
            updatedItems[index] = updatedItem;
            state = AsyncValue.data(updatedItems);
          }
        });
      },
    );
  }
}