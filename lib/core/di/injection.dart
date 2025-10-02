import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../navigation/app_router.dart';
import '../network/dio_client.dart';
import '../../features/calendar/data/datasources/calendar_local_data_source.dart';
import '../../features/calendar/data/datasources/calendar_remote_data_source.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Core dependencies
  getIt.registerSingleton<AppRouter>(AppRouter());
  getIt.registerSingleton<DioClient>(DioClient());
  
  // Calendar dependencies
  getIt.registerLazySingleton<CalendarLocalDataSource>(
    () => CalendarLocalDataSourceImpl(),
  );
  
  getIt.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(
      dio: getIt<DioClient>().getCalendarDio(''), // TODO: Add access token
    ),
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
  
  // TODO: Add auto-generated dependency injection
  // await getIt.init();
}