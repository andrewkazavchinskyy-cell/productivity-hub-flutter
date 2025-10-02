import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

import 'package:productivity_hub/core/navigation/app_router.dart';
import 'package:productivity_hub/core/network/gmail_api_provider.dart';
import 'package:productivity_hub/features/email/data/datasources/gmail_remote_data_source.dart';
import 'package:productivity_hub/features/email/data/repositories/email_repository_impl.dart';
import 'package:productivity_hub/features/email/domain/repositories/email_repository.dart';
import 'package:productivity_hub/features/email/domain/usecases/get_recent_emails.dart';
import 'package:productivity_hub/features/email/domain/usecases/mark_email_as_read.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(
      () => GoogleSignIn(
        scopes: const <String>[
          gmail.GmailApi.gmailReadonlyScope,
          gmail.GmailApi.gmailMetadataScope,
          gmail.GmailApi.gmailModifyScope,
          'email',
        ],
      ),
    );
  }

  if (!getIt.isRegistered<GmailApiProvider>()) {
    getIt.registerLazySingleton<GmailApiProvider>(
      () => GmailApiProvider(googleSignIn: getIt<GoogleSignIn>()),
    );
  }

  if (!getIt.isRegistered<GmailRemoteDataSource>()) {
    getIt.registerLazySingleton<GmailRemoteDataSource>(
      () => GmailRemoteDataSourceImpl(getIt<GmailApiProvider>()),
    );
  }

  if (!getIt.isRegistered<EmailRepository>()) {
    getIt.registerLazySingleton<EmailRepository>(
      () => EmailRepositoryImpl(getIt<GmailRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetRecentEmails>()) {
    getIt.registerFactory<GetRecentEmails>(
      () => GetRecentEmails(getIt<EmailRepository>()),
    );
  }

  if (!getIt.isRegistered<MarkEmailAsRead>()) {
    getIt.registerFactory<MarkEmailAsRead>(
      () => MarkEmailAsRead(getIt<EmailRepository>()),
    );
  }

  if (!getIt.isRegistered<AppRouter>()) {
    getIt.registerLazySingleton<AppRouter>(AppRouter.new);
  }
}
