import 'package:healing_tabs/core/http/http_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeHttpClient records calls', () async {
    final client = FakeHttpClient();
    final response = await client.get(Uri.parse('https://example.com'));
    expect(response.statusCode, 200);
    expect(client.calls.single, contains('GET'));
  });

  test('HttpException carries status', () {
    final error = HttpException('nope', statusCode: 500);
    expect(error.statusCode, 500);
  });
}
