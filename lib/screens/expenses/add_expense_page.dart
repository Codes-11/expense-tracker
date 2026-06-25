import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'expense';
  String _category = _categories.first;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  static const List<String> _categories = [
    'Food',
    'Groceries',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Rent',
    'Travel',
    'Salary',
    'Investment',
    'Gift',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Description is required';
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    await ref.read(expenseProvider.notifier).addExpense(
          amount: double.parse(_amountController.text.trim()),
          type: _type,
          category: _category,
          description: _descriptionController.text.trim(),
          date: _date,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    final error = ref.read(expenseProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      ref.read(expenseProvider.notifier).clearError();
      return;
    }

    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'expense',
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: 'income',
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() => _type = selection.first);
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _amountController,
                  label: 'Amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.notes_rounded),
                  validator: _validateDescription,
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: Text(_formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Save expense',
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}