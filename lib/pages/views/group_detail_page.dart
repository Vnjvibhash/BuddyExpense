import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/models/expense.dart';
import 'package:buddyexpense/models/settlement.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/theme.dart';
import 'package:buddyexpense/pages/views/new_expense_page.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final group = state.groups.firstWhere((g) => g.id == groupId);
    final expenses = state.expenses.where((e) => e.groupId == groupId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final settlements =
    state.settlements.where((s) => s.groupId == groupId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final balances = state.balancesForGroup(groupId);

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          _BalancesRow(balances: balances),
          const SizedBox(height: Spacing.lg),
          if (expenses.isEmpty && settlements.isEmpty)
            _EmptyGroup()
          else ...[
            if (expenses.isNotEmpty) _SectionHeader(title: 'Expenses'),
            ...expenses.map(
                  (e) => _ExpenseTile(expense: e, users: state.users),
            ),
            if (settlements.isNotEmpty) const SizedBox(height: Spacing.lg),
            if (settlements.isNotEmpty) _SectionHeader(title: 'Settlements'),
            ...settlements.map(
                  (s) => _SettlementTile(settlement: s, users: state.users),
            ),
          ],
          const SizedBox(height: 100), // 👈 extra padding so last item isn’t hidden behind FAB
        ],
      ),
      floatingActionButton: _FabMenu(groupId: groupId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _BalancesRow extends StatelessWidget {
  final Map<String, double> balances;
  const _BalancesRow({required this.balances});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Balances', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...balances.entries.map(
            (e) => _BalanceRow(name: e.key, amount: e.value),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String name; // will map to user later
  final double amount;
  const _BalanceRow({required this.name, required this.amount});
  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final user = state.userById(name);
    final cs = Theme.of(context).colorScheme;
    final color = amount >= 0 ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: .1),
            ),
            child: Center(child: Text(user?.avatarEmoji ?? '🙂')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user?.name ?? name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            "${amount >= 0 ? '' : '-'}\$${amount.abs().toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final List users;
  const _ExpenseTile({required this.expense, required this.users});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final payer = users.firstWhere((u) => u.id == expense.paidByUserId);
    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final ok =
            await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete expense?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
        if (!context.mounted) return false;
        if (ok) context.read<AppState>().deleteExpense(expense.id);
        return ok;
      },
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.onSurface.withValues(alpha: .06)),
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: .12),
              ),
              child: const Icon(Icons.receipt_long),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paid by ${payer.name}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: .7),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  final SettlementModel settlement;
  final List users;
  const _SettlementTile({required this.settlement, required this.users});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final from = users.firstWhere((u) => u.id == settlement.fromUserId);
    final to = users.firstWhere((u) => u.id == settlement.toUserId);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.onSurface.withValues(alpha: .06)),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: .12),
            ),
            child: const Icon(Icons.payments),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${from.name} paid ${to.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            '\$${settlement.amount.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: cs.onSurface.withValues(alpha: .06)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 52,
            color: cs.onSurface.withValues(alpha: .5),
          ),
          const SizedBox(height: 12),
          const Text('No activity yet'),
          const SizedBox(height: 8),
          Text(
            'Start by adding an expense or settling up.',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}

class _FabMenu extends StatefulWidget {
  final String groupId;
  const _FabMenu({required this.groupId});
  @override
  State<_FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<_FabMenu>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_open)
          GestureDetector(
            onTap: _toggle,
            child: Container(color: Colors.black.withValues(alpha: .15)),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_open) ...[
              ScaleTransition(
                scale: _scale,
                child: _SmallFab(
                  label: 'Settle up',
                  icon: Icons.payments,
                  onTap: () => _settleUp(context),
                ),
              ),
              const SizedBox(height: 8),
              ScaleTransition(
                scale: _scale,
                child: _SmallFab(
                  label: 'Add expense',
                  icon: Icons.add,
                  onTap: () => _addExpense(context),
                ),
              ),
              const SizedBox(height: 8),
            ],
            FloatingActionButton.extended(
              onPressed: _toggle,
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              icon: Icon(_open ? Icons.close : Icons.add),
              label: Text(_open ? 'Close' : 'New'),
            ),
          ],
        ),
      ],
    );
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _addExpense(BuildContext context) async {
    _toggle();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewExpensePage(groupId: widget.groupId),
      ),
    );
  }

  void _settleUp(BuildContext context) async {
    _toggle();
    final app = context.read<AppState>();
    final group = app.groups.firstWhere((g) => g.id == widget.groupId);
    final from = group.memberUserIds.first;
    final to = group.memberUserIds.last;
    final id = 's_${DateTime.now().millisecondsSinceEpoch}';
    app.addSettlement(
      SettlementModel(
        id: id,
        groupId: widget.groupId,
        fromUserId: from,
        toUserId: to,
        amount: 10.0,
        createdAt: DateTime.now(),
      ),
    );
  }
}

class _SmallFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SmallFab({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: cs.onPrimaryContainer)),
            ],
          ),
        ),
      ),
    );
  }
}
