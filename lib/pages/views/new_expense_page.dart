import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/models/expense.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/theme.dart';

class NewExpensePage extends StatefulWidget {
  final String groupId;
  const NewExpensePage({super.key, required this.groupId});

  @override
  State<NewExpensePage> createState() => _NewExpensePageState();
}

class _NewExpensePageState extends State<NewExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  String? _payerId;
  bool _splitEqually = true;
  final Map<String, double> _customShares = {};

  @override
  void dispose() {
    _desc.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final group = app.groups.firstWhere((g) => g.id == widget.groupId);
    _payerId ??= group.memberUserIds.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Dinner at Luigi\'s',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                validator: (v) => (double.tryParse(v ?? '') == null)
                    ? 'Enter a valid amount'
                    : null,
              ),
              const SizedBox(height: Spacing.md),
              DropdownButtonFormField<String>(
                value: _payerId,
                decoration: const InputDecoration(labelText: 'Paid by'),
                items: group.memberUserIds.map((id) {
                  final u = app.userById(id);
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(u?.name ?? id),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _payerId = v),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Split equally',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Switch(
                    value: _splitEqually,
                    onChanged: (v) => setState(() => _splitEqually = v),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              _splitEqually
                  ? _EqualSplitPreview(
                      totalController: _amount,
                      memberIds: group.memberUserIds,
                    )
                  : _CustomSplit(
                      totalController: _amount,
                      memberIds: group.memberUserIds,
                      onChanged: (map) => _customShares
                        ..clear()
                        ..addAll(map),
                    ),
              const SizedBox(height: Spacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _save(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Save expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppState>();
    final desc = _desc.text.trim();
    final amount = double.parse(_amount.text);
    final id = 'e_${DateTime.now().millisecondsSinceEpoch}';
    final group = app.groups.firstWhere((g) => g.id == widget.groupId);

    Map<String, double> shares;
    if (_splitEqually) {
      final per = (amount / group.memberUserIds.length);
      shares = {
        for (final id in group.memberUserIds)
          id: double.parse(per.toStringAsFixed(2)),
      };
    } else {
      final sum = _customShares.values.fold<double>(0, (s, v) => s + v);
      if ((sum - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shares must sum to total amount')),
        );
        return;
      }
      shares = _customShares;
    }

    final expense = ExpenseModel(
      id: id,
      groupId: widget.groupId,
      paidByUserId: _payerId!,
      description: desc,
      amount: amount,
      createdAt: DateTime.now(),
      shares: shares,
    );
    app.addExpense(expense);
    Navigator.pop(context);
  }
}

class _EqualSplitPreview extends StatelessWidget {
  final TextEditingController totalController;
  final List<String> memberIds;
  const _EqualSplitPreview({
    required this.totalController,
    required this.memberIds,
  });

  @override
  Widget build(BuildContext context) {
    final total = double.tryParse(totalController.text) ?? 0;
    final per = memberIds.isEmpty ? 0 : total / memberIds.length;
    final app = context.read<AppState>();

    return Column(
      children: memberIds.map((id) {
        final u = app.userById(id);
        return ListTile(
          leading: CircleAvatar(child: Text(u?.avatarEmoji ?? '🙂')),
          title: Text(u?.name ?? id),
          trailing: Text('\$${per.toStringAsFixed(2)}'),
        );
      }).toList(),
    );
  }
}

class _CustomSplit extends StatefulWidget {
  final TextEditingController totalController;
  final List<String> memberIds;
  final ValueChanged<Map<String, double>> onChanged;
  const _CustomSplit({
    required this.totalController,
    required this.memberIds,
    required this.onChanged,
  });

  @override
  State<_CustomSplit> createState() => _CustomSplitState();
}

class _CustomSplitState extends State<_CustomSplit> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final id in widget.memberIds) {
      _controllers[id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Column(
      children: widget.memberIds.map((id) {
        final u = app.userById(id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              CircleAvatar(child: Text(u?.avatarEmoji ?? '🙂')),
              const SizedBox(width: 12),
              Expanded(
                child: Text(u?.name ?? id, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _controllers[id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '\$',
                    hintText: '0.00',
                  ),
                  onChanged: (_) {
                    final map = <String, double>{};
                    for (final entry in _controllers.entries) {
                      final v = double.tryParse(entry.value.text) ?? 0;
                      map[entry.key] = v;
                    }
                    widget.onChanged(map);
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
