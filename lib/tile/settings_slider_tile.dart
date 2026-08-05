import 'package:flutter/material.dart';

Color _disabledColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);

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
