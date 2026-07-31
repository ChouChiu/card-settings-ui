import 'package:flutter/material.dart';

enum _SettingsTileKind { plain, navigation, toggle, checkbox, radio }

Color _disabledColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);

class SettingsTile<T> extends StatelessWidget {
  const SettingsTile({
    required this.title,
    this.leading,
    this.trailing,
    this.description,
    this.value,
    this.onPressed,
    this.enabled = true,
    super.key,
  }) : _kind = _SettingsTileKind.plain,
       _onSwitchChanged = null,
       _onCheckboxChanged = null,
       initialValue = null,
       radioValue = null,
       tristate = false,
       focusNode = null,
       autofocus = false;

  const SettingsTile.navigation({
    required this.title,
    this.leading,
    this.trailing = const Icon(Icons.chevron_right_rounded),
    this.description,
    this.value,
    this.onPressed,
    this.enabled = true,
    super.key,
  }) : _kind = _SettingsTileKind.navigation,
       _onSwitchChanged = null,
       _onCheckboxChanged = null,
       initialValue = null,
       radioValue = null,
       tristate = false,
       focusNode = null,
       autofocus = false;

  const SettingsTile.switchTile({
    required bool initialValue,
    required ValueChanged<bool> onToggle,
    required this.title,
    this.leading,
    this.description,
    this.enabled = true,
    super.key,
  }) : _kind = _SettingsTileKind.toggle,
       // The shared field is nullable for tri-state checkboxes; switches are not.
       // ignore: prefer_initializing_formals
       initialValue = initialValue,
       _onSwitchChanged = onToggle,
       _onCheckboxChanged = null,
       trailing = null,
       value = null,
       onPressed = null,
       radioValue = null,
       tristate = false,
       focusNode = null,
       autofocus = false;

  const SettingsTile.checkboxTile({
    required this.initialValue,
    required ValueChanged<bool?> onToggle,
    required this.title,
    this.leading,
    this.description,
    this.enabled = true,
    this.tristate = false,
    super.key,
  }) : _kind = _SettingsTileKind.checkbox,
       assert(tristate || initialValue != null),
       _onCheckboxChanged = onToggle,
       _onSwitchChanged = null,
       trailing = null,
       value = null,
       onPressed = null,
       radioValue = null,
       focusNode = null,
       autofocus = false;

  const SettingsTile.radioTile({
    required T radioValue,
    required this.title,
    this.leading,
    this.description,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : _kind = _SettingsTileKind.radio,
       _onSwitchChanged = null,
       _onCheckboxChanged = null,
       trailing = null,
       value = null,
       onPressed = null,
       initialValue = null,
       // The shared field is nullable for non-radio tile constructors.
       // ignore: prefer_initializing_formals
       radioValue = radioValue,
       tristate = false;

  final Widget? leading;
  final Widget? trailing;
  final Widget title;
  final Widget? description;
  final Widget? value;
  final void Function(BuildContext context)? onPressed;
  final bool enabled;
  final bool? initialValue;
  final T? radioValue;
  final bool tristate;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? _onSwitchChanged;
  final ValueChanged<bool?>? _onCheckboxChanged;
  final _SettingsTileKind _kind;

  bool? get _nextCheckboxValue {
    if (!tristate) {
      return !(initialValue ?? false);
    }
    return switch (initialValue) {
      false => true,
      true => null,
      null => false,
    };
  }

  VoidCallback? _tapHandler(BuildContext context) {
    if (!enabled) {
      return null;
    }
    return switch (_kind) {
      _SettingsTileKind.plain || _SettingsTileKind.navigation =>
        onPressed == null ? null : () => onPressed!(context),
      _SettingsTileKind.toggle => () => _onSwitchChanged!(
        !(initialValue ?? false),
      ),
      _SettingsTileKind.checkbox => () => _onCheckboxChanged!(
        _nextCheckboxValue,
      ),
      _SettingsTileKind.radio => () {
        final registry = RadioGroup.maybeOf<T>(context);
        registry?.onChanged(radioValue);
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final disabled = _disabledColor(context);
    final primary = enabled ? colorScheme.onSurface : disabled;
    final secondary = enabled ? colorScheme.onSurfaceVariant : disabled;

    return InkWell(
      onTap: _tapHandler(context),
      child: Row(
        children: [
          if (leading != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: IconTheme.merge(
                data: IconThemeData(color: secondary, size: 24),
                child: leading!,
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: description != null ? 17 : 24,
                horizontal: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: textTheme.bodyLarge?.copyWith(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    child: title,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: textTheme.bodySmall?.copyWith(
                        color: secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      child: description!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: DefaultTextStyle.merge(
                style: textTheme.bodySmall?.copyWith(
                  color: secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                child: value!,
              ),
            ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: IconTheme.merge(
                data: IconThemeData(color: secondary),
                child: trailing!,
              ),
            ),
          if (_kind == _SettingsTileKind.toggle)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: initialValue ?? false,
                  onChanged: enabled ? _onSwitchChanged : null,
                ),
              ),
            ),
          if (_kind == _SettingsTileKind.checkbox)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Checkbox(
                value: initialValue,
                tristate: tristate,
                onChanged: enabled ? _onCheckboxChanged : null,
              ),
            ),
          if (_kind == _SettingsTileKind.radio)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Radio<T>(
                value: radioValue as T,
                enabled: enabled,
                focusNode: focusNode,
                autofocus: autofocus,
              ),
            ),
        ],
      ),
    );
  }
}

/// A row that opens a settings category.
class SettingsCategoryTile extends StatelessWidget {
  const SettingsCategoryTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// A settings row with a value readout and full-width slider.
class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    required this.title,
    required this.value,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.leading,
    this.description,
    this.enabled = true,
    super.key,
  }) : assert(min <= max),
       assert(value >= min && value <= max),
       assert(divisions == null || divisions > 0);

  final Widget title;
  final Widget? leading;
  final Widget? description;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final disabled = _disabledColor(context);
    final foreground = enabled ? colorScheme.onSurface : disabled;
    final secondary = enabled ? colorScheme.onSurfaceVariant : disabled;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: secondary, size: 24),
                  child: leading!,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      style: textTheme.bodyLarge?.copyWith(color: foreground),
                      child: title,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle.merge(
                        style: textTheme.bodySmall?.copyWith(color: secondary),
                        child: description!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? colorScheme.secondaryContainer
                      : disabled.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: enabled
                        ? colorScheme.onSecondaryContainer
                        : disabled,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            showValueIndicator: ShowValueIndicator.never,
            padding: EdgeInsets.zero,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
