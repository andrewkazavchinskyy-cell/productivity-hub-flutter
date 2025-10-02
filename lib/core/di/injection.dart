import 'package:get_it/get_it.dart';

import '../navigation/app_router.dart';
import '../network/dio_client.dart';
import '../../features/calendar/data/datasources/calendar_local_data_source.dart';
import '../../features/calendar/data/datasources/calendar_remote_data_source.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<AppRouter>(() => AppRouter());
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  getIt.registerLazySingleton<CalendarLocalDataSource>(
    () => CalendarLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(
      remoteDataSource: getIt<CalendarRemoteDataSource>(),
      localDataSource: getIt<CalendarLocalDataSource>(),
    ),
  );

  getIt.registerFactory<CalendarBloc>(
    () => CalendarBloc(calendarRepository: getIt<CalendarRepository>()),
  );
}
