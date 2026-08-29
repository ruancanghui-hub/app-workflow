class HttpException implements Exception {
  HttpException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'HttpException($statusCode): $message';
}

class HttpResponse {
  HttpResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

abstract class HttpClient {
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers});
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  });
}

class FakeHttpClient implements HttpClient {
  FakeHttpClient({
    this.getHandler,
    this.postHandler,
  });

  final Future<HttpResponse> Function(Uri url, Map<String, String>? headers)?
      getHandler;
  final Future<HttpResponse> Function(
    Uri url,
    Map<String, String>? headers,
    Object? body,
  )? postHandler;

  final calls = <String>[];

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) async {
    calls.add('GET $url');
    if (getHandler != null) return getHandler!(url, headers);
    return HttpResponse(statusCode: 200, body: '{}');
  }

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    calls.add('POST $url');
    if (postHandler != null) return postHandler!(url, headers, body);
    return HttpResponse(statusCode: 200, body: '{}');
  }
}
