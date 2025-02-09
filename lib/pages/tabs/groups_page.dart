import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/models/group.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/theme.dart';
import 'package:buddyexpense/pages/views/group_detail_page.dart';
import 'package:buddyexpense/widgets/primary_button.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final groups = state.groups;
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Groups'),
          actions: [
            IconButton(
              onPressed: () => _createGroup(context),
              icon: const Icon(Icons.group_add_outlined),
            ),
          ],
        ),
        if (groups.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups,
                    size: 64,
                    color: cs.onSurface.withValues(alpha: .4),
                  ),
                  const SizedBox(height: 12),
                  const Text('No groups yet'),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    icon: Icons.group_add,
                    label: 'Create group',
                    onPressed: () => _createGroup(context),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.md),
            sliver: SliverList.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final g = groups[index];
                final balances = state.balancesForGroup(g.id);
                final total = balances.values.fold<double>(
                  0,
                  (s, v) => s + v.abs(),
                );
                return _GroupCard(group: g, total: total);
              },
            ),
          ),
      ],
    );
  }

  void _createGroup(BuildContext context) async {
    final state = context.read<AppState>();
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Trip to Bali'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final id = 'g_${DateTime.now().millisecondsSinceEpoch}';
                  state.addGroup(
                    GroupModel(
                      id: id,
                      name: name,
                      memberUserIds: state.users.map((u) => u.id).toList(),
                    ),
                  );
                }
                Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final double total;
  const _GroupCard({required this.group, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GroupDetailPage(groupId: group.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.md),
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: .12),
              ),
              child: const Icon(Icons.group),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.memberUserIds.length} members',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: .7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            _AmountPill(amount: total),
          ],
        ),
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  final double amount;
  const _AmountPill({required this.amount});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        '\$${amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
