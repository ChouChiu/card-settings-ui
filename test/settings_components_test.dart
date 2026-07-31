import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child, ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    darkTheme: theme,
    themeMode: theme?.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('SettingsList fills the available width by default', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 800);
    addTearDown(
      TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues,
    );

    await tester.pumpWidget(
      _app(
        child: const SettingsList(
          sections: [
            SettingsSection(tiles: [SettingsTile(title: Text('Wide item'))]),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byType(SettingsSection)).width, 1400);
  });

  testWidgets('SettingsList constrains sections to maxWidth', (tester) async {
    await tester.pumpWidget(
      _app(
        child: SettingsList(
          maxWidth: 640,
          sections: const [
            SettingsSection(tiles: [SettingsTile(title: Text('Item'))]),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byType(SettingsSection)).width, 640);
  });

  testWidgets('SettingsList supports shrink wrapping', (tester) async {
    await tester.pumpWidget(
      _app(
        child: Column(
          children: [
            SettingsList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              sections: const [
                SettingsSection(tiles: [SettingsTile(title: Text('Item'))]),
              ],
            ),
            const Text('After list'),
          ],
        ),
      ),
    );

    expect(find.text('Item'), findsOneWidget);
    expect(find.text('After list'), findsOneWidget);
  });

  testWidgets('split group keeps its Material 3 corner geometry when pressed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        child: const SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(title: Text('First'), onPressed: _ignoreContext),
                SettingsTile(title: Text('Last')),
              ],
            ),
          ],
        ),
      ),
    );

    List<Material> rowMaterials() {
      return tester
          .widgetList<Material>(
            find.descendant(
              of: find.byType(SettingsSplitGroup),
              matching: find.byType(Material),
            ),
          )
          .where((material) => material.shape is RoundedRectangleBorder)
          .toList();
    }

    BorderRadius rowRadius(Material material) {
      final shape = material.shape! as RoundedRectangleBorder;
      return shape.borderRadius.resolve(TextDirection.ltr);
    }

    expect(rowMaterials(), hasLength(2));
    expect(rowRadius(rowMaterials().first).topLeft.x, 20);
    expect(rowRadius(rowMaterials().first).bottomLeft.x, 3);
    expect(rowRadius(rowMaterials().last).topLeft.x, 3);
    expect(rowRadius(rowMaterials().last).bottomLeft.x, 20);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('First')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(rowRadius(rowMaterials().first).bottomLeft.x, 3);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(rowRadius(rowMaterials().first).bottomLeft.x, 3);
  });

  testWidgets('section uses surfaceContainerLow in every palette', (
    tester,
  ) async {
    const cardColor = Color(0xff25262b);
    final schemes = [
      ColorScheme.fromSeed(seedColor: Colors.green),
      ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      const ColorScheme.dark(
        surface: Color(0xff1b1b1f),
        surfaceContainerLow: cardColor,
        surfaceContainerHigh: Color(0xff1b1b1f),
      ),
    ];

    for (final scheme in schemes) {
      await tester.pumpWidget(
        _app(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            scaffoldBackgroundColor: scheme.brightness == Brightness.dark
                ? Colors.black
                : null,
          ),
          child: SettingsList(
            key: ValueKey(scheme),
            sections: [
              const SettingsSection(
                tiles: [SettingsTile(title: Text('Palette item'))],
              ),
            ],
          ),
        ),
      );

      final row = tester
          .widgetList<Material>(
            find.descendant(
              of: find.byType(SettingsSplitGroup),
              matching: find.byType(Material),
            ),
          )
          .singleWhere((material) => material.shape is RoundedRectangleBorder);
      final effectiveScheme = Theme.of(
        tester.element(find.text('Palette item')),
      ).colorScheme;
      expect(row.color, effectiveScheme.surfaceContainerLow);
      if (effectiveScheme.brightness == Brightness.dark) {
        expect(row.color, isNot(Colors.black));
      }
    }
  });

  testWidgets('section background color can be overridden', (tester) async {
    await tester.pumpWidget(
      _app(
        child: const SettingsList(
          sections: [
            SettingsSection(
              backgroundColor: Colors.orange,
              tiles: [SettingsTile(title: Text('Custom'))],
            ),
          ],
        ),
      ),
    );

    final materials = tester.widgetList<Material>(
      find.descendant(
        of: find.byType(SettingsSplitGroup),
        matching: find.byType(Material),
      ),
    );
    expect(
      materials.any((material) => material.color == Colors.orange),
      isTrue,
    );
  });

  testWidgets('row tap sends the target switch value', (tester) async {
    bool? received;
    await tester.pumpWidget(
      _app(
        child: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.switchTile(
                  title: const Text('Toggle'),
                  initialValue: false,
                  onToggle: (value) => received = value,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Toggle'));
    expect(received, isTrue);
  });

  testWidgets('checkbox row follows the tristate cycle', (tester) async {
    bool? received = true;
    await tester.pumpWidget(
      _app(
        child: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.checkboxTile(
                  title: const Text('Checkbox'),
                  initialValue: true,
                  tristate: true,
                  onToggle: (value) => received = value,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Checkbox'));
    expect(received, isNull);
  });

  testWidgets('navigation tile has a chevron by default', (tester) async {
    await tester.pumpWidget(
      _app(
        child: const SettingsList(
          sections: [
            SettingsSection(
              tiles: [SettingsTile.navigation(title: Text('Next'))],
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('disabled tile cannot be activated', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        child: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: const Text('Disabled'),
                  enabled: false,
                  onPressed: (_) => calls++,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    expect(calls, 0);
  });

  testWidgets('radio section changes selection by tap and keyboard', (
    tester,
  ) async {
    String? selected = 'A';
    late StateSetter rebuild;
    final firstRadioFocus = FocusNode();
    addTearDown(firstRadioFocus.dispose);

    await tester.pumpWidget(
      _app(
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return SettingsList(
              sections: [
                SettingsRadioSection<String>(
                  groupValue: selected,
                  onChanged: (value) {
                    rebuild(() => selected = value);
                  },
                  tiles: [
                    SettingsTile<String>.radioTile(
                      title: const Text('A'),
                      radioValue: 'A',
                      focusNode: firstRadioFocus,
                    ),
                    const SettingsTile<String>.radioTile(
                      title: Text('B'),
                      radioValue: 'B',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, 'B');

    firstRadioFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selected, 'B');
  });

  testWidgets('radio tile allows null only through a nullable value type', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        child: const SettingsRadioSection<String?>(
          groupValue: null,
          onChanged: _ignoreNullableString,
          tiles: [
            SettingsTile<String?>.radioTile(
              title: Text('None'),
              radioValue: null,
            ),
          ],
        ),
      ),
    );

    expect(find.text('None'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreContext(BuildContext context) {}

void _ignoreNullableString(String? value) {}
