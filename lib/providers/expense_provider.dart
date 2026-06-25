import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseState {
  final List<ExpenseModel> expenses;
  final bool isLoading;
  final String? error;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseNotifier(this._repository) : super(const ExpenseState());

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final expenses = await _repository.getExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addExpense({
    required double amount,
    required String type,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final expense = await _repository.addExpense(
        amount: amount,
        type: type,
        category: category,
        description: description,
        date: date,
      );
      state = state.copyWith(
        expenses: [expense, ...state.expenses],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateExpense({
    required String id,
    double? amount,
    String? type,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateExpense(
        id: id,
        amount: amount,
        type: type,
        category: category,
        description: description,
        date: date,
      );
      final updatedList = state.expenses
          .map((e) => e.id == id ? updated : e)
          .toList();
      state = state.copyWith(expenses: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteExpense(id);
      final updatedList = state.expenses.where((e) => e.id != id).toList();
      state = state.copyWith(expenses: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  return ExpenseNotifier(ref.read(expenseRepositoryProvider));
});
