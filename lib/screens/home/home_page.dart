import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/bottom_navbar.dart';
import '../analytics/analytics_page.dart';
import '../profile/profile_page.dart';
import '../expenses/add_expense_page.dart';
import '../expenses/edit_expense_page.dart';
import '../expenses/expense_history_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expenseProvider.notifier).loadExpenses());
  }

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsPage()));
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseProvider);
    final summary = ref.watch(analyticsSummaryProvider);
    final user = ref.watch(currentUserProvider);
    final recent = expenseState.expenses.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            user?.email?.split('@').first ?? 'there',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(child: BalanceCard(summary: summary)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent expenses',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ExpenseHistoryPage()),
                        ),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
              ),
              if (expenseState.isLoading && recent.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (recent.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No expenses yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final expense = recent[index];
                      return ExpenseCard(
                        expense: expense,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditExpensePage(expense: expense),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddExpensePage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }
}