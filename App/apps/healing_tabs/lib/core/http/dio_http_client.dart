import 'package:dio/dio.dart';

import 'http_client.dart';

class DioHttpClient implements HttpClient {
  DioHttpClient({Dio? dio, Duration timeout = const Duration(seconds: 15)})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: timeout,
                receiveTimeout: timeout,
                sendTimeout: timeout,
              ),
            );

  final Dio _dio;

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) {
    return _map(() => _dio.getUri(url, options: Options(headers: headers)));
  }

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _map(
      () => _dio.postUri(
        url,
        data: body,
        options: Options(headers: headers),
      ),
    );
  }

  Future<HttpResponse> _map(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return HttpResponse(
        statusCode: response.statusCode ?? 0,
        body: response.data?.toString() ?? '',
      );
    } on DioException catch (e) {
      throw HttpException(
        e.message ?? 'HTTP request failed',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }
}
