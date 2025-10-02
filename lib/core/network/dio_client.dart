import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class DioClient {
  DioClient();

  Dio get calendarDio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.googleCalendarBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    return dio;
  }
}
