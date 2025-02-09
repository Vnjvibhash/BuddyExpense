import 'package:flutter/material.dart';
import 'package:buddyexpense/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Container(
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
                child: const Icon(Icons.account_circle),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default members',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Edit initial sample members in code for now',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _reset(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset all data'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Text('About', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'BuddyExpense — a modern, delightful way to split expenses with friends. Built with Flutter.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset app?'),
        content: const Text(
          'This will remove all your groups, expenses and settlements.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (ok == true) {
      // Clear SharedPreferences by re-seeding
      // final app = context.read<AppState>();
      // For demo, just show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clear data by reinstalling the app in this demo'),
        ),
      );
    }
  }
}
