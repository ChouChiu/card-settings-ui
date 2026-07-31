import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<SettingsCategoryGroup> _groups() {
  return [
    SettingsCategoryGroup(
      title: 'Group',
      categories: [
        SettingsCategory(
          id: 'a',
          label: 'Category A',
          description: 'First category',
          icon: Icons.looks_one_rounded,
          builder: (_) => const SettingsDetailScaffold(
            title: Text('Detail A'),
            body: Center(child: Text('Body A')),
          ),
        ),
        SettingsCategory(
          id: 'b',
          label: 'Category B',
          description: 'Second category',
          icon: Icons.looks_two_rounded,
          builder: (_) => const SettingsDetailScaffold(
            title: Text('Detail B'),
            body: Center(child: Text('Body B')),
          ),
        ),
      ],
    ),
  ];
}

List<SettingsCategoryGroup> _groupsWithBody(String body) {
  return [
    SettingsCategoryGroup(
      title: 'Group',
      categories: [
        SettingsCategory(
          id: 'a',
          label: 'Category A',
          description: 'First category',
          icon: Icons.looks_one_rounded,
          builder: (_) => Text(body),
        ),
      ],
    ),
  ];
}

Widget _app() {
  return MaterialApp(
    home: SettingsAdaptiveScaffold(
      title: const Text('Settings'),
      groups: _groups(),
    ),
  );
}

Widget _appWithNestedDetail() {
  return MaterialApp(
    home: SettingsAdaptiveScaffold(
      title: const Text('Settings'),
      groups: [
        SettingsCategoryGroup(
          title: 'Group',
          categories: [
            SettingsCategory(
              id: 'a',
              label: 'Category A',
              description: 'First category',
              icon: Icons.looks_one_rounded,
              builder: (_) => SettingsDetailScaffold(
                title: const Text('Detail A'),
                body: Builder(
                  builder: (context) => Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const Scaffold(
                              body: Center(child: Text('Nested detail')),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open nested detail'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('compact layout pushes and pops detail pages', (tester) async {
    _setSize(tester, const Size(400, 800));
    await tester.pumpWidget(_app());

    expect(find.text('Category A').hitTestable(), findsOneWidget);
    expect(find.text('Body A'), findsNothing);

    await tester.tap(find.text('Category A').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Body A'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Category A').hitTestable(), findsOneWidget);
    expect(find.text('Body A'), findsNothing);
  });

  testWidgets('wide landscape shows rail and first detail', (tester) async {
    _setSize(tester, const Size(900, 600));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Category A').hitTestable(), findsOneWidget);
    expect(find.text('Body A'), findsOneWidget);
    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.byType(NavigationDrawerDestination), findsNWidgets(2));
    expect(tester.getSize(find.byType(NavigationDrawer)).width, 360);

    await tester.tap(find.text('Category B').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Body B'), findsOneWidget);
    expect(find.text('Body A'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('breakpoint requires landscape and width greater than 600', (
    tester,
  ) async {
    _setSize(tester, const Size(600, 400));
    await tester.pumpWidget(_app());
    expect(find.text('Body A'), findsNothing);

    _setSize(tester, const Size(601, 400));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Body A'), findsOneWidget);

    _setSize(tester, const Size(601, 900));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Body A'), findsNothing);
  });

  testWidgets('explicit selection survives wide to compact resize', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 600));
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Category B').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Body B'), findsOneWidget);

    _setSize(tester, const Size(400, 800));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Body B'), findsOneWidget);
  });

  testWidgets('implicit wide default returns to category list when compact', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 600));
    await tester.pumpWidget(_app());
    expect(find.text('Body A'), findsOneWidget);

    _setSize(tester, const Size(400, 800));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Body A'), findsNothing);
    expect(find.text('Category A').hitTestable(), findsOneWidget);
  });

  testWidgets('nested navigators own separate HeroControllers', (tester) async {
    _setSize(tester, const Size(900, 600));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Navigator), findsNWidgets(3));
    expect(find.byType(HeroControllerScope), findsWidgets);
  });

  testWidgets('wide nested detail does not cover the navigation rail', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 600));
    await tester.pumpWidget(_appWithNestedDetail());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDrawer), findsOneWidget);
    await tester.tap(find.text('Open nested detail'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    final enteringStart = tester.getCenter(find.text('Nested detail')).dx;
    await tester.pump(const Duration(milliseconds: 150));
    final enteringMiddle = tester.getCenter(find.text('Nested detail')).dx;
    await tester.pumpAndSettle();
    final enteringEnd = tester.getCenter(find.text('Nested detail')).dx;

    expect(find.text('Nested detail'), findsOneWidget);
    expect(enteringStart, greaterThan(enteringMiddle));
    expect(enteringMiddle, greaterThan(enteringEnd));
    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.text('Category A').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Nested detail'), findsNothing);
    expect(find.text('Open nested detail'), findsOneWidget);
    expect(find.byType(NavigationDrawer), findsOneWidget);
  });

  testWidgets('selected category refreshes when groups are replaced', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 600));
    late StateSetter rebuild;
    var groups = _groupsWithBody('Old body');

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return SettingsAdaptiveScaffold(
              title: const Text('Settings'),
              initialCategoryId: 'a',
              groups: groups,
            );
          },
        ),
      ),
    );
    expect(find.text('Old body'), findsOneWidget);

    rebuild(() => groups = _groupsWithBody('New body'));
    await tester.pump();
    expect(find.text('Old body'), findsNothing);
    expect(find.text('New body'), findsOneWidget);
  });
}
