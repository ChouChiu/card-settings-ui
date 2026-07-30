import 'package:flutter/material.dart';

/// A vertically scrolling, width-constrained list of settings sections.
class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.maxWidth = double.infinity,
    this.physics,
    this.contentPadding,
    super.key,
  }) : assert(maxWidth > 0);

  final List<Widget> sections;
  final bool shrinkWrap;
  final double maxWidth;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: sections.length,
      padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 20),
      itemBuilder: (context, index) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: sections[index],
        ),
      ),
    );
  }
}
