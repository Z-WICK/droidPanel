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
    _searchFocusNode = FocusNode(debugLabel: 'search-field');

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

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            _showCreateDialog(),
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
            title: const Text('Droid Config Panel'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh (⌘R)',
                onPressed: _refresh,
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('New (⌘N)'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: AppBackground(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1220),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final useScrollableLayout =
                        constraints.maxWidth < 1020 ||
                        constraints.maxHeight < 980;

                    final content = EntranceTransition(
                      delay: const Duration(milliseconds: 170),
                      child: AnimatedSwitcher(
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 280),
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
                    );

                    final topSections = _buildTopSections(
                      configState: configState,
                      filterState: filterState,
                    );

                    if (useScrollableLayout) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...topSections,
                            SizedBox(
                              height: (constraints.maxHeight * 0.6).clamp(
                                320.0,
                                560.0,
                              ),
                              child: content,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...topSections,
                        Expanded(child: content),
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
            ? 'Try changing search keywords or clearing some filters.'
            : 'Create your first Droid/Skill/Hook/MCP configuration to get started.',
        icon: hasFilters ? Icons.search_off : Icons.folder_open,
        action: hasFilters
            ? OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear Filters'),
              )
            : FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create New'),
              ),
      );
    }

    if (filterState.typeFilter != null) {
      return ListView.builder(
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
      children: [
        for (final type in orderedTypes) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
            child: Text(
              type.displayName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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

  List<Widget> _buildTopSections({
    required ConfigurationState configState,
    required FilterState filterState,
  }) {
    return [
      EntranceTransition(
        delay: const Duration(milliseconds: 20),
        child: _OverviewPanel(
          total: configState.configurations.length,
          valid: configState.configurations
              .where((config) => config.status == ValidationStatus.valid)
              .length,
          invalid: configState.configurations
              .where((config) => config.status == ValidationStatus.invalid)
              .length,
          unknown: configState.configurations
              .where((config) => config.status == ValidationStatus.unknown)
              .length,
        ),
      ),
      const SizedBox(height: 14),
      EntranceTransition(
        delay: const Duration(milliseconds: 70),
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
      const SizedBox(height: 12),
      EntranceTransition(
        delay: const Duration(milliseconds: 120),
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
      const SizedBox(height: 14),
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
      builder: (context) => AlertDialog(
        title: Text(config.name),
        content: SizedBox(
          width: 640,
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
                const SizedBox(height: 14),
                Text(
                  'Content',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                GlassSurface(
                  borderRadius: 12,
                  blur: 10,
                  showInnerGlow: false,
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    config.content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.35,
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
        ],
      ),
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
            'Open a configuration first, or narrow results to one item, then press ⌘Delete.',
          ),
        ),
      );
      return;
    }

    _showDeleteDialog(target);
  }
}

class _OverviewPanel extends StatelessWidget {
  final int total;
  final int valid;
  final int invalid;
  final int unknown;

  const _OverviewPanel({
    required this.total,
    required this.valid,
    required this.invalid,
    required this.unknown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassSurface(
      borderRadius: 26,
      blur: 32,
      padding: const EdgeInsets.all(18),
      tintColor: theme.colorScheme.surface.withValues(
        alpha: isDark ? 0.28 : 0.38,
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration Workspace',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage local and project scopes with validation-aware workflows.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _MetricPill(
            label: 'Total',
            value: total.toString(),
            color: theme.colorScheme.primary,
          ),
          _MetricPill(
            label: 'Valid',
            value: valid.toString(),
            color: const Color(0xFF0EA76B),
          ),
          _MetricPill(
            label: 'Invalid',
            value: invalid.toString(),
            color: theme.colorScheme.error,
          ),
          _MetricPill(
            label: 'Unknown',
            value: unknown.toString(),
            color: theme.colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label $value',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
