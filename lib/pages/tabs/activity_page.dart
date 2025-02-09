import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/models/expense.dart';
import 'package:buddyexpense/models/settlement.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/theme.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = [
      ...app.expenses.map((e) => _Item.expense(e)),
      ...app.settlements.map((s) => _Item.settlement(s)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final filtered = list
        .where((i) => i.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Activity'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.md,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search activity',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(Spacing.md),
          sliver: SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _ActivityTile(item: filtered[index]),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _Item item;
  const _ActivityTile({required this.item});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
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
              color: (item.expense != null ? cs.primary : Colors.green)
                  .withValues(alpha: .12),
            ),
            child: Icon(
              item.expense != null ? Icons.receipt_long : Icons.payments,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.title, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(item.amountLabel, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _Item {
  final ExpenseModel? expense;
  final SettlementModel? settlement;
  final DateTime date;
  final String title;
  final String amountLabel;
  _Item.expense(this.expense)
    : settlement = null,
      date = expense!.createdAt,
      title = expense.description,
      amountLabel = '\$${expense.amount.toStringAsFixed(2)}';
  _Item.settlement(this.settlement)
    : expense = null,
      date = settlement!.createdAt,
      title = 'Settlement: ${settlement.fromUserId} ➜ ${settlement.toUserId}',
      amountLabel = '\$${settlement.amount.toStringAsFixed(2)}';
}
