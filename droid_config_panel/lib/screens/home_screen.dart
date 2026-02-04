import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/config_provider.dart';
import 'package:droid_config_panel/providers/states.dart';
import 'package:droid_config_panel/screens/create_screen.dart';
import 'package:droid_config_panel/screens/edit_screen.dart';
import 'package:droid_config_panel/widgets/config_list_item.dart';
import 'package:droid_config_panel/widgets/delete_confirmation_dialog.dart';
import 'package:droid_config_panel/widgets/empty_state.dart';
import 'package:droid_config_panel/widgets/error_display.dart';
import 'package:droid_config_panel/widgets/loading_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ConfigurationType?> _tabs = [null, ...ConfigurationType.values];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(configurationStateProvider.notifier).loadConfigurations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(configurationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Droid Config Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((type) {
            if (type == null) {
              return const Tab(text: 'All');
            }
            return Tab(text: type.displayName);
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(configurationStateProvider.notifier).loadConfigurations();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((type) {
          return _buildConfigList(state, type);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New'),
      ),
    );
  }

  Widget _buildConfigList(ConfigurationState state, ConfigurationType? filterType) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Loading configurations...');
    }

    if (state.error != null) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(configurationStateProvider.notifier).loadConfigurations();
        },
      );
    }

    final configurations = filterType == null
        ? state.configurations
        : state.configurations.where((c) => c.type == filterType).toList();

    if (configurations.isEmpty) {
      return EmptyState(
        title: filterType == null
            ? 'No configurations found'
            : 'No ${filterType.displayName} configurations',
        message: 'Click "Create New" to add your first configuration.',
        icon: Icons.folder_open,
        action: FilledButton.icon(
          onPressed: () => _showCreateDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Create New'),
        ),
      );
    }

    final grouped = _groupByType(configurations);

    if (filterType != null) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: configurations.length,
        itemBuilder: (context, index) {
          return ConfigListItem(
            configuration: configurations[index],
            onTap: () => _showConfigDetails(configurations[index]),
            onEdit: () => _showEditDialog(configurations[index]),
            onDelete: () => _showDeleteDialog(configurations[index]),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                entry.key.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map((config) => ConfigListItem(
              configuration: config,
              onTap: () => _showConfigDetails(config),
              onEdit: () => _showEditDialog(config),
              onDelete: () => _showDeleteDialog(config),
            )),
          ],
        );
      }).toList(),
    );
  }

  Map<ConfigurationType, List<Configuration>> _groupByType(List<Configuration> configs) {
    final grouped = <ConfigurationType, List<Configuration>>{};
    for (final config in configs) {
      grouped.putIfAbsent(config.type, () => []).add(config);
    }
    return grouped;
  }

  void _showConfigDetails(Configuration config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(config.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', config.type.displayName),
              _buildDetailRow('Location', config.location.displayName),
              _buildDetailRow('Status', config.status.displayName),
              if (config.description.isNotEmpty)
                _buildDetailRow('Description', config.description),
              const SizedBox(height: 16),
              const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  config.content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateScreen()),
    );
    if (result == true) {
      ref.read(configurationStateProvider.notifier).loadConfigurations();
    }
  }

  void _showEditDialog(Configuration config) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditScreen(configuration: config)),
    );
    if (result == true) {
      ref.read(configurationStateProvider.notifier).loadConfigurations();
    }
  }

  void _showDeleteDialog(Configuration config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(configuration: config),
    );

    if (confirmed == true) {
      try {
        await ref.read(configurationStateProvider.notifier).deleteConfiguration(config.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuration deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting configuration: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
