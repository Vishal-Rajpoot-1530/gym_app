import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/api/api_exception.dart';
import 'package:gym_app/widgets/live.dart';

void main() {
  testWidgets('service connection failure is recoverable without losing UI', (
    tester,
  ) async {
    var attempts = 0;

    Future<String> load() async {
      attempts++;
      if (attempts == 1) {
        throw const ApiException(
          ApiException.serviceUnavailableMessage,
          networkError: true,
        );
      }
      return 'Dashboard data';
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Live<String>(
            load: load,
            builder: (context, data) => Text(data),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(ApiException.serviceUnavailableMessage), findsOneWidget);
    expect(
      ApiException.serviceUnavailableMessage,
      contains('check your internet connection'),
    );
    expect(
      ApiException.serviceUnavailableMessage,
      contains('contact your service provider'),
    );
    expect(find.text('Connection unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard data'), findsOneWidget);
    expect(find.text(ApiException.serviceUnavailableMessage), findsNothing);
  });
}
