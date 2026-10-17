import 'package:flutter/material.dart';

import '../data/catalog_repository.dart';
import '../data/counties.dart';
import '../l10n_helpers.dart';

/// Explains where the listings on screen came from. Renders nothing for fresh network data.
class CatalogStatusBanner extends StatelessWidget {
  const CatalogStatusBanner({
    super.key,
    required this.source,
    required this.fetchedAt,
    required this.cachedMessage,
    required this.onRetry,
  });

  final CatalogSource source;
  final DateTime? fetchedAt;
  final String Function(String when) cachedMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    switch (source) {
      case CatalogSource.network:
        return const SizedBox.shrink();
      case CatalogSource.cache:
        return Card(
          color: scheme.secondaryContainer,
          child: ListTile(
            leading: const Icon(Icons.wifi_off_outlined),
            title: Text(l10n.statusCachedTitle),
            subtitle: Text(cachedMessage(fetchedAt == null ? '' : context.formatDateTime(fetchedAt!))),
            trailing: IconButton(tooltip: l10n.retry, icon: const Icon(Icons.refresh), onPressed: onRetry),
          ),
        );
      case CatalogSource.unavailable:
        return Card(
          color: scheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.cloud_off_outlined, color: scheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.statusUnavailableTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onErrorContainer)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(l10n.statusUnavailableBody, style: TextStyle(color: scheme.onErrorContainer)),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l10n.retry)),
            ]),
          ),
        );
    }
  }
}

/// Manual county choice. HATUA never requests GPS; the choice stays on the device.
class CountyDropdown extends StatelessWidget {
  const CountyDropdown({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonFormField<String?>(
      // Re-create when the shared county changes on another tab.
      key: ValueKey('county-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.filterCounty, prefixIcon: const Icon(Icons.place_outlined)),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(l10n.filterAllCounties)),
        for (final county in kenyanCounties) DropdownMenuItem<String?>(value: county, child: Text(county)),
      ],
      onChanged: onChanged,
    );
  }
}

/// Single-choice chips that scroll sideways on narrow screens or large text.
class ChoiceChipRow extends StatelessWidget {
  const ChoiceChipRow({super.key, required this.options, required this.selected, required this.onSelected});

  /// (value, label) pairs; a null value means "all".
  final List<(String?, String)> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (value, label) in options)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
            ),
        ]),
      );
}

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message),
            if (action != null) ...[const SizedBox(height: 8), action!],
          ]),
        ),
      );
}

/// Opens only http(s) and tel links, never arbitrary schemes from remote data.
bool isSafeExternalLink(Uri uri) => const {'https', 'http', 'tel'}.contains(uri.scheme);

/// `tel:` URI with digits only (plus one leading '+'). Drops spaces and dashes, and anything
/// in remote data that could smuggle dialer codes such as '#', '*' or ',' (pause).
String safeTelUri(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return 'tel:${phone.trimLeft().startsWith('+') ? '+' : ''}$digits';
}
