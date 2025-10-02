import 'package:dartz/dartz.dart';

import 'package:productivity_hub/core/errors/failures.dart';
import 'package:productivity_hub/features/email/domain/entities/email.dart';
import 'package:productivity_hub/features/email/domain/repositories/email_repository.dart';

class GetRecentEmails {
  GetRecentEmails(this._repository);

  final EmailRepository _repository;

  Future<Either<Failure, List<Email>>> call({int maxResults = 20}) {
    return _repository.getRecentEmails(maxResults: maxResults);
  }
}
