import 'package:dartz/dartz.dart';

import 'package:productivity_hub/core/errors/failures.dart';
import 'package:productivity_hub/features/email/data/datasources/gmail_remote_data_source.dart';
import 'package:productivity_hub/features/email/domain/entities/email.dart';
import 'package:productivity_hub/features/email/domain/repositories/email_repository.dart';

class EmailRepositoryImpl implements EmailRepository {
  EmailRepositoryImpl(this._remoteDataSource);

  final GmailRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Email>>> getRecentEmails({int maxResults = 20}) async {
    try {
      final emails = await _remoteDataSource.fetchRecentEmails(maxResults: maxResults);
      return Right(emails);
    } on GmailAuthException catch (error) {
      return Left(AuthFailure(error.message));
    } on GmailApiException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String messageId) async {
    try {
      await _remoteDataSource.markAsRead(messageId);
      return Right(unit);
    } on GmailAuthException catch (error) {
      return Left(AuthFailure(error.message));
    } on GmailApiException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }
}
