import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/bar_chart_widget.dart';
import '../../widgets/donut_chart_widget.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  String _formatAmount(double value) {
    final formatted = value.abs().toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '${value < 0 ? '-' : ''}₹$formatted';
  }

  String _monthLabel(String key) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final parts = key.split('-');
    if (parts.length != 2) return key;
    final monthIndex = int.tryParse(parts[1]);
    if (monthIndex == null || monthIndex < 1 || monthIndex > 12) return key;
    return '${months[monthIndex - 1]} ${parts[0].substring(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(analyticsSummaryProvider);
    final categoryTotals = ref.watch(categoryTotalsProvider);
    final monthlyTotals = ref.watch(monthlyTotalsProvider);

    // Keep the trend chart readable on small screens — show the most recent months only.
    final monthEntries = monthlyTotals.entries.toList();
    final recentMonths = Map.fromEntries(
      monthEntries.length > 6 ? monthEntries.sublist(monthEntries.length - 6) : monthEntries,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      label: 'Income',
                      value: _formatAmount(summary.totalIncome),
                      color: const Color(0xFF1B9C6E),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: 'Expense',
                      value: _formatAmount(summary.totalExpense),
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: _StatColumn(
                      label: 'Balance',
                      value: _formatAmount(summary.balance),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Monthly spending trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Combined income and expense totals by month',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: BarChartWidget(
                data: recentMonths,
                labelBuilder: _monthLabel,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Category breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Where your money is going across categories',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: DonutChartWidget(data: categoryTotals),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}