[中文](README_CN.md)

# card_settings_ui

A responsive Material 3 settings UI for Flutter, inspired by Android 16 QPR
and Kazumi's adaptive settings layout.

<p>
  <img src="https://raw.githubusercontent.com/ErBWs/card-settings-ui/main/assets/demo.png" alt="card_settings_ui demo">
</p>

The package contains no platform-specific implementation and supports every
Flutter target, including Web and OpenHarmony.

## Requirements

- Dart 3.8 or newer
- Flutter 3.32 or newer
- `MaterialApp` or another Material ancestor

## Install

```yaml
dependencies:
  card_settings_ui: ^3.0.0
```

```dart
import 'package:card_settings_ui/card_settings_ui.dart';
```

## Settings lists

`SettingsList` keeps its sections in one column and fills the available width
by default. Set `maxWidth` when a page needs a narrower reading width.
`SettingsSection` renders its rows as a Material 3 split list.

```dart
SettingsList(
  sections: [
    SettingsSection(
      title: const Text('General'),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          value: const Text('English'),
          onPressed: (context) {},
        ),
        SettingsTile.switchTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          initialValue: notifications,
          onToggle: (value) {
            setState(() => notifications = value);
          },
        ),
      ],
    ),
  ],
)
```

Radio tiles are managed by one `RadioGroup` through
`SettingsRadioSection<T>`:

```dart
SettingsRadioSection<String>(
  title: const Text('Quality'),
  groupValue: quality,
  onChanged: (value) => setState(() => quality = value!),
  tiles: const [
    SettingsTile<String>.radioTile(
      title: Text('Automatic'),
      radioValue: 'auto',
    ),
    SettingsTile<String>.radioTile(
      title: Text('1080p'),
      radioValue: '1080p',
    ),
  ],
)
```

## Adaptive category and detail layout

`SettingsAdaptiveScaffold` shows a category list on compact screens and a
category rail beside the selected detail in landscape layouts wider than
600 logical pixels. Detail pages should use `SettingsDetailScaffold` so their
app bars adapt to both hosts.

```dart
SettingsAdaptiveScaffold(
  title: const Text('Settings'),
  groups: [
    SettingsCategoryGroup(
      title: 'App',
      categories: [
        SettingsCategory(
          id: 'appearance',
          label: 'Appearance',
          description: 'Theme, colors and type',
          icon: Icons.palette_rounded,
          builder: (_) => SettingsDetailScaffold(
            title: const Text('Appearance'),
            body: SettingsList(sections: appearanceSections),
          ),
        ),
      ],
    ),
  ],
)
```

The compact layout uses an internal Navigator with its own Hero controller, so
it retains platform transitions without interfering with the application's
Navigator.

## Dynamic color and OLED themes

Rows use `ColorScheme.surfaceContainerLow` in light, dark, dynamic-color and
OLED themes. Override a section only when your design needs a custom surface:

```dart
SettingsSection(
  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
  tiles: const [SettingsTile(title: Text('Custom surface'))],
)
```

## Migrating from 2.x

- `SettingsList.sections` and `SettingsSection.tiles` now accept
  `List<Widget>`.
- `AbstractSettingsSection`, `AbstractSettingsTile`, `CustomSettingsSection`,
  `CustomSettingsTile` and `SettingsTileInfo` were removed. Pass custom widgets
  directly.
- `SettingsTile.switchTile.onToggle` now receives a non-null target value when
  the row is tapped.
- Radio selection moved from each tile's `groupValue`/`onChanged` to
  `SettingsRadioSection<T>`.
- The minimum supported Flutter version is 3.32.

See the [example](example/lib/main.dart) for all tile types and live theme
switching.
