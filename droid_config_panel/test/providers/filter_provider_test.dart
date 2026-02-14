import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/filter_provider.dart';

void main() {
  group('FilterNotifier', () {
    test('setTypeFilter supports clearing with null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(filterStateProvider.notifier);
      notifier.setTypeFilter(ConfigurationType.droid);
      expect(
        container.read(filterStateProvider).typeFilter,
        ConfigurationType.droid,
      );

      notifier.setTypeFilter(null);
      expect(container.read(filterStateProvider).typeFilter, isNull);
    });

    test('setLocationFilter toggles when selecting same option twice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(filterStateProvider.notifier);
      notifier.setLocationFilter(ConfigurationLocation.personal);
      expect(
        container.read(filterStateProvider).locationFilter,
        ConfigurationLocation.personal,
      );

      notifier.setLocationFilter(ConfigurationLocation.personal);
      expect(container.read(filterStateProvider).locationFilter, isNull);
    });

    test('setStatusFilter supports clearing with null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(filterStateProvider.notifier);
      notifier.setStatusFilter(ValidationStatus.invalid);
      expect(
        container.read(filterStateProvider).statusFilter,
        ValidationStatus.invalid,
      );

      notifier.setStatusFilter(null);
      expect(container.read(filterStateProvider).statusFilter, isNull);
    });
  });
}
