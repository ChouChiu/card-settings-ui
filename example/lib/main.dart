import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Opts the demo into Flutter's newer Material slider appearance.
const _sliderTheme2024 = SliderThemeData(
  // ignore: deprecated_member_use
  year2023: false,
  showValueIndicator: ShowValueIndicator.onDrag,
);

const _progressIndicatorTheme2024 = ProgressIndicatorThemeData(
  // ignore: deprecated_member_use
  year2023: false,
);

const _switchThumbIcons =
    WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.check_rounded),
      WidgetState.any: Icon(Icons.close_rounded),
    });

const _switchTheme = SwitchThemeData(thumbIcon: _switchThumbIcons);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DemoSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = DemoSettingsController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final seed = controller.dynamicColor
            ? const Color(0xff9ba8ff)
            : Colors.green;
        final lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          sliderTheme: _sliderTheme2024,
          progressIndicatorTheme: _progressIndicatorTheme2024,
          switchTheme: _switchTheme,
        );
        final generatedDarkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
          ),
          sliderTheme: _sliderTheme2024,
          progressIndicatorTheme: _progressIndicatorTheme2024,
          switchTheme: _switchTheme,
        );
        final darkTheme = controller.oled
            ? generatedDarkTheme.copyWith(scaffoldBackgroundColor: Colors.black)
            : generatedDarkTheme;

        return MaterialApp(
          title: 'Card Settings UI',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: DemoSettingsPage(controller: controller),
        );
      },
    );
  }
}

class DemoSettingsController extends ChangeNotifier {
  bool darkMode = false;
  bool dynamicColor = false;
  bool oled = false;
  bool notifications = true;
  bool? analytics = false;
  double textScale = 1;

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }
}

class DemoSettingsPage extends StatelessWidget {
  DemoSettingsPage({required this.controller, super.key});

  final DemoSettingsController controller;

  late final List<SettingsCategoryGroup> groups = [
    SettingsCategoryGroup(
      title: 'App',
      categories: [
        SettingsCategory(
          id: 'appearance',
          label: 'Appearance',
          description: 'Theme, dynamic color and text size',
          icon: Icons.palette_rounded,
          builder: (_) => AppearanceSettingsPage(controller: controller),
        ),
        SettingsCategory(
          id: 'behavior',
          label: 'Behavior',
          description: 'Notifications and privacy',
          icon: Icons.tune_rounded,
          builder: (_) => BehaviorSettingsPage(controller: controller),
        ),
      ],
    ),
    SettingsCategoryGroup(
      title: 'Playback',
      categories: [
        SettingsCategory(
          id: 'quality',
          label: 'Quality',
          description: 'Choose a default stream quality',
          icon: Icons.high_quality_rounded,
          builder: (_) => const QualitySettingsPage(),
        ),
        SettingsCategory(
          id: 'about',
          label: 'About',
          description: 'Package information',
          icon: Icons.info_outline_rounded,
          builder: (_) => const AboutSettingsPage(),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsAdaptiveScaffold(
      title: const Text('Settings'),
      groups: groups,
    );
  }
}

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({required this.controller, super.key});

  final DemoSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SettingsDetailScaffold(
          title: const Text('Appearance'),
          body: SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Theme'),
                tiles: [
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.dark_mode_rounded),
                    title: const Text('Dark mode'),
                    initialValue: controller.darkMode,
                    onToggle: (value) =>
                        controller.update(() => controller.darkMode = value),
                  ),
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.color_lens_rounded),
                    title: const Text('Simulate dynamic color'),
                    description: const Text('Uses a wallpaper-like seed color'),
                    initialValue: controller.dynamicColor,
                    onToggle: (value) => controller.update(
                      () => controller.dynamicColor = value,
                    ),
                  ),
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.contrast_rounded),
                    title: const Text('OLED background'),
                    description: const Text('Uses pure black behind the cards'),
                    initialValue: controller.oled,
                    onToggle: (value) =>
                        controller.update(() => controller.oled = value),
                  ),
                ],
                bottomInfo: const Text(
                  'Cards keep their Material container tone in every palette.',
                ),
              ),
              SettingsSection(
                title: const Text('Reading'),
                tiles: [
                  SettingsSliderTile(
                    leading: const Icon(Icons.text_fields_rounded),
                    title: const Text('Text scale'),
                    value: controller.textScale,
                    valueLabel: '${controller.textScale.toStringAsFixed(1)}×',
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    onChanged: (value) =>
                        controller.update(() => controller.textScale = value),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class BehaviorSettingsPage extends StatelessWidget {
  const BehaviorSettingsPage({required this.controller, super.key});

  final DemoSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SettingsDetailScaffold(
          title: const Text('Behavior'),
          body: SettingsList(
            sections: [
              SettingsSection(
                title: const Text('General'),
                tiles: [
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.notifications_rounded),
                    title: const Text('Notifications'),
                    initialValue: controller.notifications,
                    onToggle: (value) => controller.update(
                      () => controller.notifications = value,
                    ),
                  ),
                  SettingsTile.checkboxTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('Anonymous analytics'),
                    description: const Text('Optional three-state preference'),
                    initialValue: controller.analytics,
                    tristate: true,
                    onToggle: (value) =>
                        controller.update(() => controller.analytics = value),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language_rounded),
                    title: const Text('Language'),
                    value: const Text('English'),
                    onPressed: (_) {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class QualitySettingsPage extends StatefulWidget {
  const QualitySettingsPage({super.key});

  @override
  State<QualitySettingsPage> createState() => _QualitySettingsPageState();
}

class _QualitySettingsPageState extends State<QualitySettingsPage> {
  String quality = 'Auto';

  @override
  Widget build(BuildContext context) {
    return SettingsDetailScaffold(
      title: const Text('Quality'),
      body: SettingsList(
        sections: [
          SettingsRadioSection<String>(
            title: const Text('Default quality'),
            groupValue: quality,
            onChanged: (value) {
              if (value != null) {
                setState(() => quality = value);
              }
            },
            tiles: [
              for (final option in ['Auto', '1080p', '720p'])
                SettingsTile<String>.radioTile(
                  title: Text(option),
                  radioValue: option,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsDetailScaffold(
      title: const Text('About'),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.widgets_rounded),
                title: const Text('card_settings_ui'),
                description: const Text('Adaptive Material 3 settings'),
                value: const Text('3.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
