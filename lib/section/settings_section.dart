import 'package:flutter/material.dart';
import 'package:card_settings_ui/tile/settings_tile_info.dart';

const double _defaultOuterRadius = 20;
const double _defaultInnerRadius = 3;
const double _defaultRowGap = 2;

/// A titled group of settings tiles.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.tiles,
    this.margin,
    this.title,
    this.bottomInfo,
    this.backgroundColor,
    this.outerRadius = _defaultOuterRadius,
    this.innerRadius = _defaultInnerRadius,
    this.tileSpacing = _defaultRowGap,
    super.key,
  });

  final List<Widget> tiles;
  final EdgeInsetsGeometry? margin;
  final Widget? title;
  final Widget? bottomInfo;

  /// Overrides the Material 3 container color used by each row.
  ///
  /// When omitted, [ColorScheme.surfaceContainerLow] is used in every
  /// brightness mode. This keeps cards visible with dynamic color and OLED
  /// themes.
  final Color? backgroundColor;
  final double outerRadius;
  final double innerRadius;
  final double tileSpacing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: margin ?? const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle.merge(
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                child: title!,
              ),
            ),
          SettingsSplitGroup(
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            spacing: tileSpacing,
            backgroundColor: backgroundColor,
            children: tiles,
          ),
          if (bottomInfo != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle.merge(
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                child: bottomInfo!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Lays rows out as a Material 3 split list.
///
/// The first and last rows receive large outer corners, while interior corners
/// remain small.
class SettingsSplitGroup extends StatelessWidget {
  const SettingsSplitGroup({
    required this.children,
    this.outerRadius = _defaultOuterRadius,
    this.innerRadius = _defaultInnerRadius,
    this.spacing = _defaultRowGap,
    this.backgroundColor,
    super.key,
  }) : assert(outerRadius >= 0),
       assert(innerRadius >= 0),
       assert(spacing >= 0);

  final List<Widget> children;
  final double outerRadius;
  final double innerRadius;
  final double spacing;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) SizedBox(height: spacing),
          _SplitRow(
            first: index == 0,
            last: index == children.length - 1,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            backgroundColor: backgroundColor,
            child: SettingsTileInfo(
              isTopTile: index == 0,
              isBottomTile: index == children.length - 1,
              // Row gaps come from [spacing]; tiles must not add their own.
              needDivider: false,
              child: children[index],
            ),
          ),
        ],
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.first,
    required this.last,
    required this.outerRadius,
    required this.innerRadius,
    required this.backgroundColor,
    required this.child,
  });

  final bool first;
  final bool last;
  final double outerRadius;
  final double innerRadius;
  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = first ? outerRadius : innerRadius;
    final bottom = last ? outerRadius : innerRadius;

    return Material(
      color:
          backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(top),
          bottom: Radius.circular(bottom),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
