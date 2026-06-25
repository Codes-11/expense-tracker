import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';
import 'edit_expense_page.dart';

class ExpenseHistoryPage extends ConsumerStatefulWidget {
  const ExpenseHistoryPage({super.key});

  @override
  ConsumerState<ExpenseHistoryPage> createState() => _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState extends ConsumerState<ExpenseHistoryPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _categoryFilter = 'All';
  DateTimeRange? _dateFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDateRange: _dateFilter,
    );
    if (picked != null) setState(() => _dateFilter = picked);
  }

  List<ExpenseModel> _filter(List<ExpenseModel> expenses) {
    return expenses.where((e) {
      final matchesQuery = _query.isEmpty ||
          e.description.toLowerCase().contains(_query.toLowerCase()) ||
          e.category.toLowerCase().contains(_query.toLowerCase());

      final matchesCategory = _categoryFilter == 'All' ||
          e.category.toLowerCase() == _categoryFilter.toLowerCase();

      final matchesDate = _dateFilter == null ||
          (!e.date.isBefore(_dateFilter!.start) &&
              !e.date.isAfter(_dateFilter!.end.add(const Duration(hours: 23, minutes: 59))));

      return matchesQuery && matchesCategory && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseState = ref.watch(expenseProvider);
    final allExpenses = expenseState.expenses;
    final categories = ['All', ...{for (final e in allExpenses) e.category}];
    final filtered = _filter(allExpenses);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense history')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search expenses',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...categories.map((category) {
                    final selected = _categoryFilter == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => setState(() => _categoryFilter = category),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(
                        Icons.date_range_rounded,
                        size: 16,
                        color: _dateFilter != null ? theme.colorScheme.primary : null,
                      ),
                      label: Text(_dateFilter == null ? 'Date range' : 'Custom range'),
                      onPressed: _pickDateRange,
                    ),
                  ),
                  if (_dateFilter != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        label: const Text('Clear date'),
                        onDeleted: () => setState(() => _dateFilter = null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: expenseState.isLoading && allExpenses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                allExpenses.isEmpty
                                    ? 'No expenses recorded yet'
                                    : 'No expenses match your filters',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final expense = filtered[index];
                            return ExpenseCard(
                              expense: expense,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditExpensePage(expense: expense),
                                ),
                              ),
                              onDelete: () =>
                                  ref.read(expenseProvider.notifier).deleteExpense(expense.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}