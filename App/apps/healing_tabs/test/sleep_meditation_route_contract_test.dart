import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/app/routes/app_pages.dart';
import 'package:healing_tabs/app/routes/app_routes.dart';

void main() {
  test('sleep and meditation V1 routes match the page contract', () {
    expect(AppRoutes.sleepPicker, '/sleep/pick');
    expect(AppRoutes.meditationPractice, '/meditation/practice');
    expect(AppRoutes.meditationSummary, '/meditation/summary');
  });

  test('every new V1 route is registered with GetX', () {
    final routes = AppPages.pages.map((page) => page.name);
    expect(
      routes,
      containsAll([
        AppRoutes.sleepPicker,
        AppRoutes.meditationPractice,
        AppRoutes.meditationSummary,
      ]),
    );
  });
}
