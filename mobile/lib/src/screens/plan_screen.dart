import 'package:flutter/material.dart';
import '../data/local_store.dart';

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

  void _update() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    widget.store.removeListener(_update);
    _input.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_input.text.trim().isEmpty) return;
    try {
      await widget.store.addGoal(_input.text);
      _input.clear();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save securely. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = widget.store.goals;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('My next steps', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Make room for small, achievable goals. They remain on this device and are stored in encrypted local storage.'),
      const SizedBox(height: 18),
      TextField(
        controller: _input, maxLength: 160,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _add(),
        decoration: InputDecoration(
          labelText: 'One step I want to take',
          hintText: 'e.g. Prepare my CV',
          suffixIcon: IconButton(tooltip: 'Add goal', onPressed: _add, icon: const Icon(Icons.add_circle)),
        ),
      ),
      const SizedBox(height: 8),
      Text('${goals.where((g) => g.isDone).length} of ${goals.length} completed',
        style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (goals.isEmpty) const Card(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('No goals yet. Start with something small and important to you.'),
      )),
      for (final goal in goals)
        Card(child: ListTile(
          leading: Checkbox(
            value: goal.isDone,
            onChanged: (_) async {
              try { await widget.store.toggleGoal(goal.id); }
              catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to update goal.')));
              }
            },
          ),
          title: Text(goal.title, style: TextStyle(
            decoration: goal.isDone ? TextDecoration.lineThrough : null,
          )),
          trailing: IconButton(
            tooltip: 'Delete goal', icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              try { await widget.store.removeGoal(goal.id); }
              catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to delete goal.')));
              }
            },
          ),
          onTap: () async {
            try { await widget.store.toggleGoal(goal.id); }
            catch (_) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to update goal.')));
            }
          },
        )),
    ]);
  }
}
