import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class EditExpensePage extends ConsumerStatefulWidget {
  final ExpenseModel expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  ConsumerState<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends ConsumerState<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late String _type;
  late String _category;
  late DateTime _date;
  bool _isSaving = false;
  bool _isDeleting = false;

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
  void initState() {
    super.initState();
    final expense = widget.expense;
    _amountController = TextEditingController(text: expense.amount.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: expense.description);
    _type = expense.type.toLowerCase() == 'income' ? 'income' : 'expense';
    _category = _categories.firstWhere(
      (c) => c.toLowerCase() == expense.category.toLowerCase(),
      orElse: () => _categories.last,
    );
    _date = expense.date;
  }

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

    await ref.read(expenseProvider.notifier).updateExpense(
          id: widget.expense.id,
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    await ref.read(expenseProvider.notifier).deleteExpense(widget.expense.id);

    if (!mounted) return;
    setState(() => _isDeleting = false);

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
      appBar: AppBar(
        title: const Text('Edit expense'),
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _confirmDelete,
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
          ),
        ],
      ),
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
                  label: 'Update expense',
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Delete expense',
                  variant: CustomButtonVariant.outlined,
                  color: theme.colorScheme.error,
                  isLoading: _isDeleting,
                  onPressed: _confirmDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}