import 'package:dartz/dartz.dart';

import 'package:productivity_hub/core/errors/failures.dart';
import 'package:productivity_hub/features/email/domain/entities/email.dart';

abstract class EmailRepository {
  Future<Either<Failure, List<Email>>> getRecentEmails({int maxResults = 20});
  Future<Either<Failure, Unit>> markAsRead(String messageId);
}
