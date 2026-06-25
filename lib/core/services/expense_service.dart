import '../../models/expense_model.dart';
import 'supabase_service.dart';

class ExpenseService {
  final _client = SupabaseService.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }

  Future<ExpenseModel> createExpense({
    required double amount,
    required String type,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    final data = {
      'user_id': _userId,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from('expenses')
        .insert(data)
        .select()
        .single();

    return ExpenseModel.fromJson(response);
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final response = await _client
        .from('expenses')
        .select()
        .eq('user_id', _userId)
        .order('date', ascending: false);

    return (response as List<dynamic>)
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ExpenseModel> updateExpense({
    required String id,
    double? amount,
    String? type,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    final updates = <String, dynamic>{};
    if (amount != null) updates['amount'] = amount;
    if (type != null) updates['type'] = type;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (date != null) updates['date'] = date.toIso8601String();

    final response = await _client
        .from('expenses')
        .update(updates)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return ExpenseModel.fromJson(response);
  }

  Future<void> deleteExpense(String id) async {
    await _client
        .from('expenses')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
