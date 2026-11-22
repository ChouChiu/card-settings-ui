import 'package:flutter/material.dart';

class SettingsTileInfo extends InheritedWidget {
  const SettingsTileInfo({
    super.key,
    required this.needDivider,
    required this.isTopTile,
    required this.isBottomTile,
    this.backgroundColor,
    this.outerRadius = 20,
    this.innerRadius = 3,
    required super.child,
  });

  final bool needDivider;
  final bool isTopTile;
  final bool isBottomTile;
  final Color? backgroundColor;
  final double outerRadius;
  final double innerRadius;

  @override
  bool updateShouldNotify(SettingsTileInfo oldWidget) {
    return needDivider != oldWidget.needDivider ||
        isTopTile != oldWidget.isTopTile ||
        isBottomTile != oldWidget.isBottomTile ||
        backgroundColor != oldWidget.backgroundColor ||
        outerRadius != oldWidget.outerRadius ||
        innerRadius != oldWidget.innerRadius;
  }

  static SettingsTileInfo of(BuildContext context) {
    final SettingsTileInfo? result =
        context.dependOnInheritedWidgetOfExactType<SettingsTileInfo>();
    // assert(result != null, 'No IOSSettingsTileAdditionalInfo found in context');
    return result ??
        const SettingsTileInfo(
          needDivider: true,
          isBottomTile: true,
          isTopTile: true,
          child: SizedBox(),
        );
  }
}
