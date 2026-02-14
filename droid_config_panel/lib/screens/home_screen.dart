import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/config_provider.dart';
import 'package:droid_config_panel/providers/filter_provider.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/providers/states.dart';
import 'package:droid_config_panel/screens/create_screen.dart';
import 'package:droid_config_panel/screens/edit_screen.dart';
import 'package:droid_config_panel/theme/app_theme.dart';
import 'package:droid_config_panel/widgets/app_background.dart';
import 'package:droid_config_panel/widgets/config_list_item.dart';
import 'package:droid_config_panel/widgets/delete_confirmation_dialog.dart';
import 'package:droid_config_panel/widgets/empty_state.dart';
import 'package:droid_config_panel/widgets/entrance_transition.dart';
import 'package:droid_config_panel/widgets/error_display.dart';
import 'package:droid_config_panel/widgets/filter_chips.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';
import 'package:droid_config_panel/widgets/loading_indicator.dart';
import 'package:droid_config_panel/widgets/search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String? _lastInteractedConfigId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(debugLabel: 'home-search-field');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(configurationStateProvider.notifier).loadConfigurations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configurationStateProvider);
    final filterState = ref.watch(filterStateProvider);
    final searchService = ref.watch(searchServiceProvider);
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (_searchController.text != filterState.searchQuery) {
      _searchController.value = TextEditingValue(
        text: filterState.searchQuery,
        selection: TextSelection.collapsed(
          offset: filterState.searchQuery.length,
        ),
      );
    }

    final filteredConfigurations = searchService.searchAndFilter(
      configurations: configState.configurations,
      query: filterState.searchQuery,
      type: filterState.typeFilter,
      location: filterState.locationFilter,
      status: filterState.statusFilter,
    );

    final validCount = configState.configurations
        .where((config) => config.status == ValidationStatus.valid)
        .length;
    final invalidCount = configState.configurations
        .where((config) => config.status == ValidationStatus.invalid)
        .length;
    final unknownCount = configState.configurations
        .where((config) => config.status == ValidationStatus.unknown)
        .length;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
            _showCreateDialog,
        const SingleActivator(LogicalKeyboardKey.keyR, meta: true): _refresh,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): () {
          _searchFocusNode.requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.delete, meta: true): () {
          _handleKeyboardDelete(filteredConfigurations);
        },
        const SingleActivator(LogicalKeyboardKey.backspace, meta: true): () {
          _handleKeyboardDelete(filteredConfigurations);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            titleSpacing: 14,
            title: const _WindowTitle(),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh (⌘R)',
                onPressed: _refresh,
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('New'),
              ),
              const SizedBox(width: 14),
            ],
          ),
          body: AppBackground(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 1040;
                    final listFrame = EntranceTransition(
                      delay: const Duration(milliseconds: 90),
                      child: _ResultFrame(
                        totalCount: configState.configurations.length,
                        shownCount: filteredConfigurations.length,
                        hasFilters: filterState.hasActiveFilters,
                        validCount: validCount,
                        invalidCount: invalidCount,
                        unknownCount: unknownCount,
                        child: AnimatedSwitcher(
                          duration: disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: KeyedSubtree(
                            key: ValueKey(
                              _contentSignature(
                                configState: configState,
                                filterState: filterState,
                                configurations: filteredConfigurations,
                              ),
                            ),
                            child: _buildContent(
                              configState: configState,
                              filterState: filterState,
                              configurations: filteredConfigurations,
                            ),
                          ),
                        ),
                      ),
                    );

                    final topSections = _buildTopSections(
                      filterState: filterState,
                    );

                    if (compact) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...topSections,
                            const SizedBox(height: 10),
                            SizedBox(
                              height: (constraints.maxHeight * 0.76).clamp(
                                400.0,
                                720.0,
                              ),
                              child: listFrame,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...topSections,
                        const SizedBox(height: 10),
                        Expanded(child: listFrame),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required ConfigurationState configState,
    required FilterState filterState,
    required List<Configuration> configurations,
  }) {
    if (configState.isLoading) {
      return const LoadingIndicator(message: 'Loading configurations...');
    }

    if (configState.error != null) {
      return ErrorDisplay(message: configState.error!, onRetry: _refresh);
    }

    if (configurations.isEmpty) {
      final hasFilters = filterState.hasActiveFilters;
      return EmptyState(
        title: hasFilters ? 'No matching results' : 'No configurations found',
        message: hasFilters
            ? 'Try changing search keywords or clear one of the filters.'
            : 'Create your first Droid/Skill/Hook/MCP configuration.',
        icon: hasFilters
            ? Icons.search_off_rounded
            : Icons.dashboard_customize_outlined,
        action: hasFilters
            ? OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Clear Filters'),
              )
            : FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New'),
              ),
      );
    }

    if (filterState.typeFilter != null) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
        itemCount: configurations.length,
        itemBuilder: (context, index) {
          final config = configurations[index];
          return ConfigListItem(
            key: ValueKey(config.id),
            configuration: config,
            onTap: () {
              _markInteracted(config);
              _showConfigDetails(config);
            },
            onEdit: () {
              _markInteracted(config);
              _showEditDialog(config);
            },
            onDelete: () {
              _markInteracted(config);
              _showDeleteDialog(config);
            },
          );
        },
      );
    }

    final grouped = _groupByType(configurations);
    final orderedTypes = ConfigurationType.values.where(grouped.containsKey);

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 12),
      children: [
        for (final type in orderedTypes) ...[
          _TypeSectionHeader(type: type, count: grouped[type]!.length),
          for (final config in grouped[type]!)
            ConfigListItem(
              key: ValueKey(config.id),
              configuration: config,
              onTap: () {
                _markInteracted(config);
                _showConfigDetails(config);
              },
              onEdit: () {
                _markInteracted(config);
                _showEditDialog(config);
              },
              onDelete: () {
                _markInteracted(config);
                _showDeleteDialog(config);
              },
            ),
        ],
      ],
    );
  }

  Map<ConfigurationType, List<Configuration>> _groupByType(
    List<Configuration> configs,
  ) {
    final grouped = <ConfigurationType, List<Configuration>>{};
    for (final config in configs) {
      grouped.putIfAbsent(config.type, () => []).add(config);
    }
    return grouped;
  }

  List<Widget> _buildTopSections({required FilterState filterState}) {
    return [
      EntranceTransition(
        delay: const Duration(milliseconds: 20),
        child: SearchBarWidget(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            ref.read(filterStateProvider.notifier).setSearchQuery(value);
          },
          onClear: () {
            ref.read(filterStateProvider.notifier).setSearchQuery('');
          },
        ),
      ),
      const SizedBox(height: 8),
      EntranceTransition(
        delay: const Duration(milliseconds: 45),
        child: FilterChips(
          selectedType: filterState.typeFilter,
          selectedLocation: filterState.locationFilter,
          selectedStatus: filterState.statusFilter,
          onTypeChanged: (value) {
            ref.read(filterStateProvider.notifier).setTypeFilter(value);
          },
          onLocationChanged: (value) {
            ref.read(filterStateProvider.notifier).setLocationFilter(value);
          },
          onStatusChanged: (value) {
            ref.read(filterStateProvider.notifier).setStatusFilter(value);
          },
          onClearAll: _clearFilters,
        ),
      ),
    ];
  }

  String _contentSignature({
    required ConfigurationState configState,
    required FilterState filterState,
    required List<Configuration> configurations,
  }) {
    if (configState.isLoading) {
      return 'loading';
    }
    if (configState.error != null) {
      return 'error:${configState.error}';
    }
    if (configurations.isEmpty) {
      return 'empty:${filterState.hasActiveFilters}';
    }
    return [
      filterState.searchQuery,
      filterState.typeFilter?.name ?? 'all',
      filterState.locationFilter?.name ?? 'all',
      filterState.statusFilter?.name ?? 'all',
      configurations.length,
    ].join('|');
  }

  void _refresh() {
    ref.read(configurationStateProvider.notifier).loadConfigurations();
  }

  void _markInteracted(Configuration config) {
    _lastInteractedConfigId = config.id;
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(filterStateProvider.notifier).clearAll();
  }

  Future<void> _showCreateDialog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateScreen()),
    );
    if (result == true && mounted) {
      _refresh();
    }
  }

  Future<void> _showEditDialog(Configuration config) async {
    _markInteracted(config);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(configuration: config),
      ),
    );
    if (result == true && mounted) {
      _refresh();
    }
  }

  Future<void> _showDeleteDialog(Configuration config) async {
    _markInteracted(config);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(configuration: config),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(configurationStateProvider.notifier)
          .deleteConfiguration(config.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configuration deleted')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }

  void _showConfigDetails(Configuration config) {
    _markInteracted(config);
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(config.name)),
              Chip(label: Text(config.type.displayName)),
            ],
          ),
          content: SizedBox(
            width: 760,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'Type', value: config.type.displayName),
                  _DetailRow(
                    label: 'Location',
                    value: config.location.displayName,
                  ),
                  _DetailRow(label: 'Status', value: config.status.displayName),
                  if (config.description.isNotEmpty)
                    _DetailRow(label: 'Description', value: config.description),
                  _DetailRow(label: 'Path', value: config.filePath),
                  const SizedBox(height: 12),
                  Text(
                    'Content',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassSurface(
                    borderRadius: 14,
                    blur: 8,
                    showInnerGlow: false,
                    tintColor: theme.colorScheme.surfaceContainer.withValues(
                      alpha: isDark ? 0.7 : 0.96,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      config.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _showEditDialog(config);
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _handleKeyboardDelete(List<Configuration> filteredConfigurations) {
    Configuration? target;
    final lastId = _lastInteractedConfigId;

    if (lastId != null) {
      for (final config in filteredConfigurations) {
        if (config.id == lastId) {
          target = config;
          break;
        }
      }
    }

    target ??= filteredConfigurations.length == 1
        ? filteredConfigurations.first
        : null;

    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open a configuration first, or narrow to one item, then press ⌘Delete.',
          ),
        ),
      );
      return;
    }

    _showDeleteDialog(target);
  }
}

class _WindowTitle extends StatelessWidget {
  const _WindowTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.developer_board_rounded,
            color: theme.colorScheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Droid Config Panel',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ResultFrame extends StatelessWidget {
  final int totalCount;
  final int shownCount;
  final bool hasFilters;
  final int validCount;
  final int invalidCount;
  final int unknownCount;
  final Widget child;

  const _ResultFrame({
    required this.totalCount,
    required this.shownCount,
    required this.hasFilters,
    required this.validCount,
    required this.invalidCount,
    required this.unknownCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassSurface(
      borderRadius: 20,
      blur: 22,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Configurations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _HeaderPill(
                  text: '$shownCount / $totalCount',
                  color: theme.colorScheme.primary,
                ),
                _HeaderPill(text: 'Valid $validCount', color: AppTheme.success),
                if (invalidCount > 0)
                  _HeaderPill(
                    text: 'Invalid $invalidCount',
                    color: theme.colorScheme.error,
                  ),
                if (unknownCount > 0)
                  _HeaderPill(
                    text: 'Unknown $unknownCount',
                    color: theme.colorScheme.outline,
                  ),
                if (hasFilters)
                  Text(
                    'Filtered',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String text;
  final Color color;

  const _HeaderPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TypeSectionHeader extends StatelessWidget {
  final ConfigurationType type;
  final int count;

  const _TypeSectionHeader({required this.type, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final icon = switch (type) {
      ConfigurationType.droid => Icons.smart_toy_outlined,
      ConfigurationType.skill => Icons.psychology_alt_outlined,
      ConfigurationType.hook => Icons.bolt_outlined,
      ConfigurationType.mcpServer => Icons.hub_outlined,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            type.displayName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '($count)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              '$label:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
