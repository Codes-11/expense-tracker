import '../models/expense_model.dart';
import '../core/services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _service;

  ExpenseRepository({ExpenseService? service})
      : _service = service ?? ExpenseService();

  Future<ExpenseModel> addExpense({
    required double amount,
    required String type,
    required String category,
    required String description,
    required DateTime date,
  }) {
    return _service.createExpense(
      amount: amount,
      type: type,
      category: category,
      description: description,
      date: date,
    );
  }

  Future<List<ExpenseModel>> getExpenses() {
    return _service.getExpenses();
  }

  Future<ExpenseModel> updateExpense({
    required String id,
    double? amount,
    String? type,
    String? category,
    String? description,
    DateTime? date,
  }) {
    return _service.updateExpense(
      id: id,
      amount: amount,
      type: type,
      category: category,
      description: description,
      date: date,
    );
  }

  Future<void> deleteExpense(String id) {
    return _service.deleteExpense(id);
  }
}
