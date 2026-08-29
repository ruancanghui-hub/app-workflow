import 'package:healing_tabs/core/http/dio_http_client.dart';
import 'package:healing_tabs/core/http/http_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DioHttpClient maps DioException to HttpException', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 503),
              type: DioExceptionType.badResponse,
              message: 'unavailable',
            ),
          );
        },
      ),
    );
    final client = DioHttpClient(dio: dio);
    expect(
      () => client.get(Uri.parse('https://example.com/x')),
      throwsA(
        isA<HttpException>().having((e) => e.statusCode, 'status', 503),
      ),
    );
  });
}
