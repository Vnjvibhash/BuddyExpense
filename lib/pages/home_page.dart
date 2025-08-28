import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buddyexpense/state/app_state.dart';
import 'package:buddyexpense/pages/tabs/dashboard_page.dart';
import 'package:buddyexpense/pages/tabs/groups_page.dart';
import 'package:buddyexpense/pages/tabs/activity_page.dart';
import 'package:buddyexpense/pages/tabs/settings_page.dart';
import 'package:buddyexpense/widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _index = 0;
  late final List<Widget> _tabs;
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _tabs = [
      DashboardPage(onOpenGroups: () => _onNavChanged(1)),
      const GroupsPage(),
      const ActivityPage(),
      const SettingsPage(),
    ];
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load initial data from provider
      context.read<AppState>().load();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onNavChanged(int newIndex) {
    if (newIndex != _index) {
      setState(() => _index = newIndex);
      _fadeController
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Consumer<AppState>(
            builder: (context, state, _) {
              if (!state.loaded) {
                return const _LaunchingSplash();
              }
              return FadeTransition(opacity: _fade, child: _tabs[_index]);
            },
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          index: _index,
          items: const [
            Icon(Icons.dashboard),
            Icon(Icons.people),
            Icon(Icons.receipt_long),
            Icon(Icons.settings),
          ],
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          buttonBackgroundColor: Theme.of(context).colorScheme.primary,
          onTap: _onNavChanged,
        ),
      ),
    );
  }
}

class _LaunchingSplash extends StatelessWidget {
  const _LaunchingSplash();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withOpacity(0.12),
            ),
            child: Icon(Icons.auto_graph, color: cs.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'BuddyExpense',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 160,
            child: LinearProgressIndicator(minHeight: 6),
          ),
        ],
      ),
    );
  }
}
