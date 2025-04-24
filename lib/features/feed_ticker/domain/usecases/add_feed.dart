import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed.dart';
import '../repositories/feed_repository.dart';

class AddFeed implements UseCase<Feed, AddFeedParams> {
  final FeedRepository repository;

  AddFeed(this.repository);

  @override
  Future<Either<Failure, Feed>> call(AddFeedParams params) async {
    return await repository.addFeed(params.feed);
  }
}

class AddFeedParams extends Equatable {
  final Feed feed;

  const AddFeedParams({required this.feed});

  @override
  List<Object> get props => [feed];
}