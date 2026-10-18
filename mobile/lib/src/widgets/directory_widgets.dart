import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog_repository.dart';
import '../data/counties.dart';
import '../l10n_helpers.dart';
import '../theme/app_theme.dart';

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


/// Keeps a column readable on tablets and desktop browsers; full width on phones.
class CenteredContent extends StatelessWidget {
  const CenteredContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: child,
        ),
      );
}

/// One fact with a leading icon (place, cost, verification), instead of joined meta strings.
class MetaRow extends StatelessWidget {
  const MetaRow({super.key, required this.icon, required this.text, this.color, this.style});
  final IconData icon;
  final String text;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final muted = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ExcludeSemantics(child: Icon(icon, size: 16, color: muted)),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: style ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted))),
      ]),
    );
  }
}

/// Days from [today] to [deadline], counting calendar days only.
int daysUntil(DateTime deadline, DateTime today) {
  final d = DateTime.utc(deadline.year, deadline.month, deadline.day);
  final t = DateTime.utc(today.year, today.month, today.day);
  return d.difference(t).inDays;
}

/// "Closes in 5 days" in ochre (HATUA's colour for time) when a deadline is near, otherwise
/// the closing date.
class DeadlineBadge extends StatelessWidget {
  const DeadlineBadge({super.key, required this.deadline, required this.today});
  final DateTime deadline;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = daysUntil(deadline, today);
    final soon = days <= 14;
    final colors = HatuaColors.of(context);
    final label = soon ? l10n.deadlineIn(days) : l10n.opportunityCloses(context.formatDate(deadline));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: soon ? colors.time : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ExcludeSemantics(
          child: Icon(Icons.schedule, size: 16, color: soon ? colors.onTime : null),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: soon ? colors.onTime : null)),
        ),
      ]),
    );
  }
}

/// Small tag for a category or kind. Plain text on a tinted shape; not a button.
class TagLabel extends StatelessWidget {
  const TagLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSecondaryContainer)),
    );
  }
}

/// Section heading inside a list (semantic header for screen readers).
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key, this.top = 20});
  final String text;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: top, bottom: 8),
        child: Semantics(header: true, child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
      );
}

Future<void> copyWithMessage(BuildContext context, String text, String message) async {
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: text));
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Opens a map search for a listed place. A search (not coordinates) because listings carry
/// the address as written by the source; the user sees the result before travelling.
String mapsSearchUrl(String name, String location, String county) {
  final place = [name, location, if (county != nationwide) county, 'Kenya'].where((p) => p.isNotEmpty).join(', ');
  return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place)}';
}

/// "Report a problem" with a public listing. Anonymous: only the listing, a reason and an
/// optional note are sent (see CatalogRepository.report).
Future<void> showReportSheet(
  BuildContext context, {
  required CatalogRepository repository,
  required ReportTarget target,
  required String recordId,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final sent = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _ReportSheet(repository: repository, target: target, recordId: recordId),
  );
  if (sent == null) return;
  messenger.showSnackBar(SnackBar(content: Text(sent ? l10n.reportSent : l10n.reportFailed)));
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.repository, required this.target, required this.recordId});
  final CatalogRepository repository;
  final ReportTarget target;
  final String recordId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _note = TextEditingController();
  ReportReason? _reason;
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() => _sending = true);
    final ok = await widget.repository.report(
      target: widget.target,
      recordId: widget.recordId,
      reason: reason,
      note: _note.text,
    );
    if (mounted) Navigator.pop(context, ok);
  }

  String _label(ReportReason reason) {
    final l10n = context.l10n;
    return switch (reason) {
      ReportReason.brokenLink => l10n.reportReasonBrokenLink,
      ReportReason.wrongContact => l10n.reportReasonWrongContact,
      ReportReason.closed => l10n.reportReasonClosed,
      ReportReason.suspectedScam => l10n.reportReasonScam,
      ReportReason.other => l10n.reportReasonOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(header: true, child: Text(l10n.reportTitle, style: theme.textTheme.titleLarge)),
          const SizedBox(height: 8),
          RadioGroup<ReportReason>(
            groupValue: _reason,
            onChanged: (value) => setState(() => _reason = value),
            child: Column(children: [
              for (final reason in ReportReason.values)
                RadioListTile<ReportReason>(contentPadding: EdgeInsets.zero, value: reason, title: Text(_label(reason))),
            ]),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLength: 300,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(labelText: l10n.reportNoteLabel, helperText: l10n.reportNoteHint),
          ),
          const SizedBox(height: 4),
          MetaRow(icon: Icons.lock_outline, text: l10n.reportPrivacy),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _reason == null || _sending ? null : _send,
              child: _sending
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.reportSend),
            ),
          ),
        ]),
      ),
    );
  }
}
