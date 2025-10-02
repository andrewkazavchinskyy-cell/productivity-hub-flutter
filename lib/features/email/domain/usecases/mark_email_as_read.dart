import 'package:dartz/dartz.dart';

import 'package:productivity_hub/core/errors/failures.dart';
import 'package:productivity_hub/features/email/domain/repositories/email_repository.dart';

class MarkEmailAsRead {
  MarkEmailAsRead(this._repository);

  final EmailRepository _repository;

  Future<Either<Failure, Unit>> call(String messageId) {
    return _repository.markAsRead(messageId);
  }
}
