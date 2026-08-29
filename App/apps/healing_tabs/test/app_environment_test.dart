import 'package:healing_tabs/core/env/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeAppEnvironment distinguishes variants', () {
    expect(FakeAppEnvironment(BuildVariant.dev).isDev, isTrue);
    expect(FakeAppEnvironment(BuildVariant.prod).isProd, isTrue);
  });
}
