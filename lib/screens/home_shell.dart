import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../utils/nav_bus.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'goals_screen.dart';

/// Top-level tab shell. Also re-syncs the SMS inbox whenever the app returns
/// to the foreground, so the data is always current when the user looks at it
/// (background SMS delivery is unreliable on aggressive battery-saver devices).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _index = 0;

  static const _tabs = [
    DashboardScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    GoalsScreen(),
    ChatScreen(),
  ];

  /// Index of the Coach tab (last), used by [_openCoach].
  static const _coachIndex = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NavBus.coachRequests.addListener(_openCoach);
  }

  @override
  void dispose() {
    NavBus.coachRequests.removeListener(_openCoach);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _openCoach() {
    if (mounted) setState(() => _index = _coachIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Catch up on any SMS + captured app notifications that arrived while
      // the app was backgrounded (syncInbox drains both sources).
      ref.read(transactionRepositoryProvider).syncInbox();
      // The user may have just toggled notification access in system settings.
      ref.invalidate(notifCaptureEnabledProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Coach',
          ),
        ],
      ),
    );
  }
}
