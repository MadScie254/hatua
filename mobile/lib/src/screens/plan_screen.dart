import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../l10n_helpers.dart';

/// Private goals. Stored only in encrypted on-device storage; never synced or uploaded.
/// Deliberately no streaks, scores or reminders (docs/SAFETY_PRIVACY.md).
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.store});
  final LocalStore store;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_update);
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_update);
    _input.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add() async {
    if (_input.text.trim().isEmpty) return;
    final failed = context.l10n.planSaveFailed;
    try {
      await widget.store.addGoal(_input.text);
      _input.clear();
    } catch (_) {
      _showError(failed);
    }
  }

  Future<void> _guard(Future<void> Function() action, String failureMessage) async {
    try {
      await action();
    } catch (_) {
      _showError(failureMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final goals = widget.store.goals;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Semantics(header: true, child: Text(l10n.planTitle, style: theme.textTheme.headlineSmall)),
      const SizedBox(height: 8),
      Text(l10n.planIntro),
      const SizedBox(height: 18),
      TextField(
        controller: _input,
        maxLength: LocalStore.maxGoalLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _add(),
        decoration: InputDecoration(
          labelText: l10n.planInputLabel,
          hintText: l10n.planInputHint,
          suffixIcon: IconButton(tooltip: l10n.planAdd, onPressed: _add, icon: const Icon(Icons.add_circle)),
        ),
      ),
      const SizedBox(height: 8),
      Text(l10n.planProgress(goals.where((g) => g.isDone).length, goals.length),
          style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      if (goals.isEmpty)
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(l10n.planEmpty))),
      for (final goal in goals)
        Card(
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: goal.isDone,
            onChanged: (_) => _guard(() => widget.store.toggleGoal(goal.id), l10n.planUpdateFailed),
            title: Text(goal.title,
                style: TextStyle(decoration: goal.isDone ? TextDecoration.lineThrough : null)),
            secondary: IconButton(
              tooltip: l10n.planDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _guard(() => widget.store.removeGoal(goal.id), l10n.planDeleteFailed),
            ),
          ),
        ),
    ]);
  }
}
