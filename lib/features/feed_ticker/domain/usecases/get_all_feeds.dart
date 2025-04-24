import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed.dart';
import '../repositories/feed_repository.dart';

class GetAllFeeds implements UseCase<List<Feed>, NoParams> {
  final FeedRepository repository;

  GetAllFeeds(this.repository);

  @override
  Future<Either<Failure, List<Feed>>> call(NoParams params) async {
    return await repository.getAllFeeds();
  }
}