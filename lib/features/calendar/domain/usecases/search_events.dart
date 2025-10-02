import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/calendar_repository.dart';

class SearchEvents {
  const SearchEvents(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, List<Event>>> call(String query) {
    return repository.searchEvents(query);
  }
}
