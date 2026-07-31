import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example opens an adaptive settings detail', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(
      TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues,
    );

    await tester.pumpWidget(const MyApp());
    expect(find.text('Theme & slider').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Theme & slider').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Dynamic color preview'), findsOneWidget);
    expect(find.text('Scaffold background override'), findsOneWidget);

    final sliderTheme = Theme.of(
      tester.element(find.byType(Slider)),
    ).sliderTheme;
    // ignore: deprecated_member_use
    expect(sliderTheme.year2023, isFalse);

    final switchTheme = Theme.of(
      tester.element(find.byType(Switch).first),
    ).switchTheme;
    expect(
      switchTheme.thumbIcon?.resolve({WidgetState.selected})?.icon,
      Icons.check_rounded,
    );
    expect(
      switchTheme.thumbIcon?.resolve(<WidgetState>{})?.icon,
      Icons.close_rounded,
    );

    final progressTheme = Theme.of(
      tester.element(find.byType(Slider)),
    ).progressIndicatorTheme;
    // ignore: deprecated_member_use
    expect(progressTheme.year2023, isFalse);
  });
}
