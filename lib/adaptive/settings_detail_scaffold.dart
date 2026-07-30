import 'package:flutter/material.dart';

/// Describes how an adaptive settings page is hosting a detail page.
class SettingsPaneScope extends InheritedWidget {
  const SettingsPaneScope({
    required this.embedded,
    required super.child,
    this.onBack,
    super.key,
  });

  /// Whether the detail is rendered in the right pane of a two-pane layout.
  final bool embedded;

  /// Returns a compact detail page to the category list.
  final VoidCallback? onBack;

  static SettingsPaneScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsPaneScope>();
  }

  @override
  bool updateShouldNotify(SettingsPaneScope oldWidget) {
    return embedded != oldWidget.embedded || onBack != oldWidget.onBack;
  }
}

/// A scaffold that adapts to standalone and embedded settings details.
class SettingsDetailScaffold extends StatelessWidget {
  const SettingsDetailScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    super.key,
  });

  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scope = SettingsPaneScope.maybeOf(context);

    if (scope?.embedded ?? false) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          titleSpacing: leading == null ? 24 : NavigationToolbar.kMiddleSpacing,
          leading: leading,
          title: title,
          titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          actions: actions,
        ),
        body: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
        leading:
            leading ??
            (scope?.onBack == null
                ? null
                : IconButton(
                    onPressed: scope!.onBack,
                    icon: const Icon(Icons.arrow_back),
                  )),
      ),
      body: body,
    );
  }
}
