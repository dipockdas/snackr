import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

class UpdateFeedItemStatus implements UseCase<FeedItem, UpdateFeedItemStatusParams> {
  final FeedRepository repository;

  UpdateFeedItemStatus(this.repository);

  @override
  Future<Either<Failure, FeedItem>> call(UpdateFeedItemStatusParams params) async {
    return await repository.updateFeedItemStatus(
      params.itemId,
      isRead: params.isRead,
      isStarred: params.isStarred,
    );
  }
}

class UpdateFeedItemStatusParams extends Equatable {
  final int itemId;
  final bool? isRead;
  final bool? isStarred;

  const UpdateFeedItemStatusParams({
    required this.itemId,
    this.isRead,
    this.isStarred,
  });

  @override
  List<Object?> get props => [itemId, isRead, isStarred];
}