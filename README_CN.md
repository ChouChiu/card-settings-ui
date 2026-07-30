[English](README.md)

# card_settings_ui

一个响应式 Material 3 Flutter 设置界面库，外观参考 Android 16 QPR，并提供
Kazumi 风格的自适应设置布局。

<p>
  <img src="https://raw.githubusercontent.com/ErBWs/card-settings-ui/main/assets/demo.png" alt="card_settings_ui 示例">
</p>

库内不包含平台专用实现，支持 Web、OpenHarmony 等全部 Flutter 目标平台。

## 环境要求

- Dart 3.8 或更高版本
- Flutter 3.32 或更高版本
- 使用 `MaterialApp` 或其他 Material 上层组件

## 安装

```yaml
dependencies:
  card_settings_ui: ^3.0.0
```

```dart
import 'package:card_settings_ui/card_settings_ui.dart';
```

## 设置列表

`SettingsList` 默认让单栏分区撑满可用宽度；需要限制阅读宽度时可显式设置
`maxWidth`。`SettingsSection` 使用 Material 3 split list 样式呈现设置项。

```dart
SettingsList(
  sections: [
    SettingsSection(
      title: const Text('通用'),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.language),
          title: const Text('语言'),
          value: const Text('简体中文'),
          onPressed: (context) {},
        ),
        SettingsTile.switchTile(
          leading: const Icon(Icons.notifications),
          title: const Text('通知'),
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

单选设置通过 `SettingsRadioSection<T>` 统一交给一个 `RadioGroup` 管理：

```dart
SettingsRadioSection<String>(
  title: const Text('画质'),
  groupValue: quality,
  onChanged: (value) => setState(() => quality = value!),
  tiles: const [
    SettingsTile<String>.radioTile(
      title: Text('自动'),
      radioValue: 'auto',
    ),
    SettingsTile<String>.radioTile(
      title: Text('1080p'),
      radioValue: '1080p',
    ),
  ],
)
```

## 自适应分类与详情

`SettingsAdaptiveScaffold` 在紧凑屏幕上显示分类列表；横屏宽度超过 600
逻辑像素时，显示左侧分类栏和右侧详情。详情页面使用
`SettingsDetailScaffold`，即可自动适配两种宿主形式。

```dart
SettingsAdaptiveScaffold(
  title: const Text('设置'),
  groups: [
    SettingsCategoryGroup(
      title: '应用',
      categories: [
        SettingsCategory(
          id: 'appearance',
          label: '外观',
          description: '主题、配色与字体',
          icon: Icons.palette_rounded,
          builder: (_) => SettingsDetailScaffold(
            title: const Text('外观'),
            body: SettingsList(sections: appearanceSections),
          ),
        ),
      ],
    ),
  ],
)
```

紧凑布局使用带独立 HeroController 的内部 Navigator，既保留平台页面转场，
也不会干扰应用自身的 Navigator。

## 动态配色与 OLED

亮色、暗色、动态配色和 OLED 主题下，设置行统一使用
`ColorScheme.surfaceContainerLow`。如果设计需要其他颜色，可以按分区覆盖：

```dart
SettingsSection(
  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
  tiles: const [SettingsTile(title: Text('自定义底色'))],
)
```

## 从 2.x 迁移

- `SettingsList.sections` 与 `SettingsSection.tiles` 改为 `List<Widget>`。
- 删除 `AbstractSettingsSection`、`AbstractSettingsTile`、
  `CustomSettingsSection`、`CustomSettingsTile` 和 `SettingsTileInfo`；
  自定义组件可直接传入。
- 点击开关整行时，`SettingsTile.switchTile.onToggle` 会收到非空的目标值。
- 单选状态从每个 tile 的 `groupValue`/`onChanged` 移到
  `SettingsRadioSection<T>`。
- 最低支持版本调整为 Flutter 3.32。

完整设置项和实时主题切换可参考 [example](example/lib/main.dart)。
