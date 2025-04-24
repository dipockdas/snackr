import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

class GetAllFeedItems implements UseCase<List<FeedItem>, GetAllFeedItemsParams> {
  final FeedRepository repository;

  GetAllFeedItems(this.repository);

  @override
  Future<Either<Failure, List<FeedItem>>> call(GetAllFeedItemsParams params) async {
    return await repository.getAllFeedItems(limit: params.limit);
  }
}

class GetAllFeedItemsParams extends Equatable {
  final int limit;

  const GetAllFeedItemsParams({this.limit = 50});

  @override
  List<Object> get props => [limit];
}