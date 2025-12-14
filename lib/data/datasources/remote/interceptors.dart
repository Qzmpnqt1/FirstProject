import 'package:dio/dio.dart';
import 'exceptions.dart';

/// Интерсептор для логирования запросов и ответов
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    print('Query: ${options.queryParameters}');
    if (options.data != null) {
      print('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Message: ${err.message}');
    super.onError(err, handler);
  }
}

/// Интерсептор для обработки ошибок и маппинга в доменные исключения
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException(err.message ?? 'Request timeout');
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 400:
            exception = BadRequestException(err.response?.data?.toString() ?? 'Bad request');
            break;
          case 401:
            exception = UnauthorizedException('Unauthorized');
            break;
          case 500:
          case 502:
          case 503:
            exception = ServerException(
              err.response?.data?.toString() ?? 'Server error',
              statusCode,
            );
            break;
          default:
            exception = NetworkException(
              err.response?.data?.toString() ?? 'Network error',
              statusCode,
            );
        }
        break;

      case DioExceptionType.cancel:
        exception = NetworkException('Request cancelled');
        break;

      case DioExceptionType.connectionError:
        exception = NetworkException('No internet connection');
        break;

      default:
        exception = NetworkException(err.message ?? 'Unknown error');
    }

    handler.reject(err.copyWith(error: exception));
  }
}

