import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expenses_models.dart';
import '../../sales/models/sales_models.dart'; // For PaymentMethod

class ExpensesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Expense>> getExpenses({int limit = 100}) async {
    final response = await _supabase
        .from('expenses')
        .select('*, expense_categories(name), payment_methods(name)')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> getExpenseById(String id) async {
    final response = await _supabase
        .from('expenses')
        .select('*, expense_categories(name), payment_methods(name)')
        .eq('id', id)
        .single();
    return Expense.fromJson(response);
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final response = await _supabase
        .from('expense_categories')
        .select('*')
        .order('name');
    return (response as List).map((json) => ExpenseCategory.fromJson(json)).toList();
  }
  
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _supabase
        .from('payment_methods')
        .select('*')
        .eq('is_active', true)
        .order('name');
    return (response as List).map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<String> createExpense({
    required String categoryId,
    required double amount,
    required String paymentMethodId,
    String? description,
    String? reference,
  }) async {
    final response = await _supabase.rpc('create_expense', params: {
      'p_category_id': categoryId,
      'p_amount': amount,
      'p_payment_method_id': paymentMethodId,
      'p_description': description,
      'p_reference': reference,
    });
    return response as String;
  }
}
