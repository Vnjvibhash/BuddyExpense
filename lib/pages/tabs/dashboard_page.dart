import 'package:buddyexpense/pages/auth/login_screen.dart';
import 'package:buddyexpense/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/theme.dart';
import 'package:buddyexpense/widgets/primary_button.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onOpenGroups;
  const DashboardPage({super.key, required this.onOpenGroups});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;

    final totalOwed = state.groups.fold<double>(0, (sum, g) {
      final b = state.balancesForGroup(g.id);
      // sum of negatives (what you owe)
      final double groupOwe = b.entries
          .where((e) => e.value < 0)
          .fold(0, (s, e) => s + e.value.abs());
      return sum + groupOwe;
    });

    final totalToReceive = state.groups.fold<double>(0, (sum, g) {
      final b = state.balancesForGroup(g.id);
      final double groupGet = b.entries
          .where((e) => e.value > 0)
          .fold(0, (s, e) => s + e.value);
      return sum + groupGet;
    });

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('BuddyExpense'),
          actions: [
            IconButton(
              onPressed: () async {
                await Provider.of<AuthService>(
                  context,
                  listen: false,
                ).signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCards(
                  totalOwed: totalOwed,
                  totalToReceive: totalToReceive,
                ),
                const SizedBox(height: Spacing.lg),
                _SpendingChart(),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        icon: Icons.add,
                        label: 'Add expense',
                        onPressed: () => _showQuickAddMenu(context),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openGroups(context),
                        child: const Text('View groups'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openGroups(BuildContext context) => onOpenGroups();

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: const [
                  _QuickAction(icon: Icons.receipt_long, label: 'Add expense'),
                  _QuickAction(icon: Icons.payments, label: 'Settle up'),
                  _QuickAction(icon: Icons.group_add, label: 'New group'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final double totalOwed;
  final double totalToReceive;
  const _SummaryCards({required this.totalOwed, required this.totalToReceive});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'You owe',
            value: totalOwed,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: _MetricCard(
            title: 'You are owed',
            value: totalToReceive,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, color: color),
              const SizedBox(width: 8),
              Text(
                _formatCurrency(value),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double v) =>
      v == 0 ? '\$0' : '\$${v.toStringAsFixed(2)}';
}

class _SpendingChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 days', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.md),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: cs.onSurface.withValues(alpha: .06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 1.6),
                      FlSpot(2, 2.6),
                      FlSpot(3, 1.2),
                      FlSpot(4, 3.5),
                      FlSpot(5, 2.4),
                      FlSpot(6, 4.1),
                    ],
                    isCurved: true,
                    color: cs.primary,
                    belowBarData: BarAreaData(
                      show: true,
                      color: cs.primary.withValues(alpha: .15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(Radii.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
