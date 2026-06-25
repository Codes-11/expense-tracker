import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import 'expense_provider.dart';

class AnalyticsSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });
}

class AnalyticsNotifier {
  final List<ExpenseModel> expenses;

  const AnalyticsNotifier(this.expenses);

  double get totalIncome => expenses
      .where((e) => e.type.toLowerCase() == 'income')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => expenses
      .where((e) => e.type.toLowerCase() == 'expense')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalIncome - totalExpense;

  AnalyticsSummary get summary => AnalyticsSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
      );

  Map<String, double> categoryTotals() {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  Map<String, double> monthlyTotals() {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      totals[key] = (totals[key] ?? 0.0) + expense.amount;
    }
    return Map.fromEntries(
      totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

final analyticsProvider = Provider<AnalyticsNotifier>((ref) {
  final expenses = ref.watch(expenseProvider).expenses;
  return AnalyticsNotifier(expenses);
});

final analyticsSummaryProvider = Provider<AnalyticsSummary>((ref) {
  return ref.watch(analyticsProvider).summary;
});

final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  return ref.watch(analyticsProvider).categoryTotals();
});

final monthlyTotalsProvider = Provider<Map<String, double>>((ref) {
  return ref.watch(analyticsProvider).monthlyTotals();
});
