import 'package:flutter/material.dart';
import 'package:card_settings_ui/adaptive/settings_detail_scaffold.dart';
import 'package:card_settings_ui/section/settings_section.dart';
import 'package:card_settings_ui/tile/settings_tile.dart';

@immutable
class SettingsCategory {
  const SettingsCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

@immutable
class SettingsCategoryGroup {
  const SettingsCategoryGroup({required this.title, required this.categories});

  final String title;
  final List<SettingsCategory> categories;
}

bool _validGroups(List<SettingsCategoryGroup> groups) {
  if (groups.isEmpty || groups.any((group) => group.categories.isEmpty)) {
    return false;
  }
  final ids = <String>{};
  for (final group in groups) {
    for (final category in group.categories) {
      if (category.id.isEmpty || !ids.add(category.id)) {
        return false;
      }
    }
  }
  return true;
}

/// An adaptive category-and-detail scaffold for settings pages.
///
/// Landscape layouts wider than [breakpoint] show a category rail beside the
/// selected detail. Compact layouts use an internal Navigator so opening a
/// detail retains the platform page transition.
class SettingsAdaptiveScaffold extends StatefulWidget {
  SettingsAdaptiveScaffold({
    required this.title,
    required this.groups,
    this.initialCategoryId,
    this.leading,
    this.actions,
    this.breakpoint = 600,
    this.railWidth = 280,
    this.transitionDuration = const Duration(milliseconds: 250),
    this.detailPadding = const EdgeInsetsDirectional.fromSTEB(8, 0, 12, 0),
    this.onBack,
    super.key,
  }) : assert(breakpoint >= 0),
       assert(railWidth > 0),
       assert(_validGroups(groups));

  final Widget title;
  final List<SettingsCategoryGroup> groups;
  final String? initialCategoryId;
  final Widget? leading;
  final List<Widget>? actions;
  final double breakpoint;
  final double railWidth;
  final Duration transitionDuration;
  final EdgeInsetsGeometry detailPadding;

  /// Called by the category page's leading button.
  ///
  /// When omitted, the parent Navigator is popped.
  final VoidCallback? onBack;

  @override
  State<SettingsAdaptiveScaffold> createState() =>
      _SettingsAdaptiveScaffoldState();
}

class _SettingsAdaptiveScaffoldState extends State<SettingsAdaptiveScaffold> {
  static const _listPageKey = ValueKey<String>('settings-category-list');

  final GlobalKey<NavigatorState> _detailNavigatorKey =
      GlobalKey<NavigatorState>();
  late final HeroController _heroController =
      MaterialApp.createMaterialHeroController();

  SettingsCategory? _selected;
  bool? _previousTwoPane;
  bool _layoutChanged = false;

  Iterable<SettingsCategory> get _categories sync* {
    for (final group in widget.groups) {
      yield* group.categories;
    }
  }

  SettingsCategory get _firstCategory => widget.groups.first.categories.first;

  SettingsCategory? _findCategory(String? id) {
    if (id == null) {
      return null;
    }
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  bool _useTwoPane(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape &&
        MediaQuery.sizeOf(context).width > widget.breakpoint;
  }

  @override
  void initState() {
    super.initState();
    _selected = _findCategory(widget.initialCategoryId);
  }

  @override
  void didUpdateWidget(SettingsAdaptiveScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected != null) {
      _selected = _findCategory(_selected!.id);
    }
    if (_selected == null &&
        oldWidget.initialCategoryId != widget.initialCategoryId) {
      _selected = _findCategory(widget.initialCategoryId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = _useTwoPane(context);
    _layoutChanged = _previousTwoPane != null && _previousTwoPane != next;
    _previousTwoPane = next;

    if (_layoutChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _layoutChanged = false;
      });
    }
  }

  void _select(SettingsCategory category) {
    setState(() => _selected = category);
  }

  void _backToCategories() {
    if (_selected != null) {
      setState(() => _selected = null);
    }
  }

  void _popParent() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final twoPane = _useTwoPane(context);
    final shown = _selected ?? _firstCategory;
    final compactDetail = twoPane ? null : _selected;

    return NavigatorPopHandler(
      onPopWithResult: (_) => _detailNavigatorKey.currentState?.maybePop(),
      child: HeroControllerScope(
        controller: _heroController,
        child: Navigator(
          key: _detailNavigatorKey,
          transitionDelegate: _layoutChanged
              ? const _InstantTransitionDelegate()
              : const DefaultTransitionDelegate<dynamic>(),
          onDidRemovePage: (page) {
            if (page.key != _listPageKey && !_useTwoPane(context)) {
              _backToCategories();
            }
          },
          pages: [
            MaterialPage<void>(
              key: _listPageKey,
              child: _buildCategoryScaffold(context, twoPane, shown),
            ),
            if (compactDetail != null)
              MaterialPage<void>(
                key: ValueKey<String>('settings-detail:${compactDetail.id}'),
                child: SettingsPaneScope(
                  embedded: false,
                  onBack: () => _detailNavigatorKey.currentState?.maybePop(),
                  child: Builder(builder: compactDetail.builder),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScaffold(
    BuildContext context,
    bool twoPane,
    SettingsCategory shown,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        leading:
            widget.leading ??
            IconButton(
              onPressed: _popParent,
              icon: const Icon(Icons.arrow_back),
            ),
        actions: widget.actions,
      ),
      body: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRect(
              child: AnimatedAlign(
                duration: widget.transitionDuration,
                curve: Curves.easeInOutCubic,
                alignment: AlignmentDirectional.centerStart,
                widthFactor: twoPane ? 1 : 0,
                child: SizedBox(
                  width: widget.railWidth,
                  child: _buildRail(context, shown),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: widget.transitionDuration,
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                child: twoPane
                    ? _buildDetailPane(shown)
                    : KeyedSubtree(
                        key: const ValueKey<String>('settings-categories'),
                        child: _buildCompactCategories(context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _withoutScrollbars(Widget child) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: child,
    );
  }

  Widget _buildDetailPane(SettingsCategory shown) {
    return Padding(
      key: ValueKey<String>('settings-pane:${shown.id}'),
      padding: widget.detailPadding,
      child: _withoutScrollbars(
        SettingsPaneScope(
          embedded: true,
          child: Builder(builder: shown.builder),
        ),
      ),
    );
  }

  Widget _buildRail(BuildContext context, SettingsCategory shown) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categories = _categories.toList(growable: false);
    final selectedIndex = categories.indexWhere(
      (category) => category.id == shown.id,
    );

    return _withoutScrollbars(
      NavigationDrawer(
        selectedIndex: selectedIndex,
        tilePadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 12, 0),
        onDestinationSelected: (index) => _select(categories[index]),
        children: [
          for (final group in widget.groups) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 28, 8),
              child: Text(
                group.title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            for (final category in group.categories) ...[
              const SizedBox(height: 2),
              NavigationDrawerDestination(
                icon: Icon(category.icon),
                label: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
            ],
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCompactCategories(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      children: [
        for (final group in widget.groups) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Text(
              group.title,
              style: textTheme.titleSmall?.copyWith(color: colorScheme.primary),
            ),
          ),
          SettingsSplitGroup(
            children: [
              for (final category in group.categories)
                SettingsCategoryTile(
                  icon: category.icon,
                  title: category.label,
                  description: category.description,
                  onTap: () => _select(category),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InstantTransitionDelegate extends TransitionDelegate<dynamic> {
  const _InstantTransitionDelegate();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
    locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
    pageRouteToPagelessRoutes,
  }) {
    final result = <RouteTransitionRecord>[];

    for (final route in newPageRouteHistory) {
      if (route.isWaitingForEnteringDecision) {
        route.markForAdd();
      }
      result.add(route);
    }

    for (final route in locationToExitingPageRoute.values) {
      if (route.isWaitingForExitingDecision) {
        route.markForComplete();
        for (final pageless in pageRouteToPagelessRoutes[route] ?? const []) {
          pageless.markForComplete();
        }
      }
      result.add(route);
    }

    return result;
  }
}
