import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

class RefreshFeeds implements UseCase<List<FeedItem>, NoParams> {
  final FeedRepository repository;

  RefreshFeeds(this.repository);

  @override
  Future<Either<Failure, List<FeedItem>>> call(NoParams params) async {
    return await repository.refreshFeeds();
  }
}