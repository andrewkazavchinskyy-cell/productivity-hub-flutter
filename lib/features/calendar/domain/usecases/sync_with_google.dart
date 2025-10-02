import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/calendar_repository.dart';

class SyncWithGoogle {
  const SyncWithGoogle(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.syncWithGoogle();
  }
}
