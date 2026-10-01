import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/expenses_service.dart';
import 'models/expenses_models.dart';
import '../sales/models/sales_models.dart'; // PaymentMethod

class NewExpenseController extends ChangeNotifier {
  final ExpensesService _service = ExpensesService();

  List<ExpenseCategory> categories = [];
  List<PaymentMethod> paymentMethods = [];
  
  bool isLoading = true;
  String? errorMessage;
  bool isSubmitting = false;

  ExpenseCategory? selectedCategory;
  double amount = 0;
  PaymentMethod? selectedPaymentMethod;
  String reference = '';
  String notes = '';

  NewExpenseController() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final results = await Future.wait([
        _service.getCategories(),
        _service.getPaymentMethods(),
      ]);
      
      categories = results[0] as List<ExpenseCategory>;
      paymentMethods = results[1] as List<PaymentMethod>;
      
      if (paymentMethods.isNotEmpty) {
        selectedPaymentMethod = paymentMethods.firstWhere((p) => p.code == 'CASH', orElse: () => paymentMethods.first);
      }
    } catch (e) {
      errorMessage = 'Failed to load requirements.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(ExpenseCategory? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void updateAmount(double newAmount) {
    amount = newAmount;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod? method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }
  
  void updateReference(String text) => reference = text;
  void updateNotes(String text) => notes = text;

  Future<String> submitExpense() async {
    if (selectedCategory == null) throw 'Category is required.';
    if (amount <= 0) throw 'Amount must be greater than zero.';
    if (selectedPaymentMethod == null) throw 'Payment method is required.';

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final expenseId = await _service.createExpense(
        categoryId: selectedCategory!.id,
        amount: amount,
        paymentMethodId: selectedPaymentMethod!.id,
        reference: reference.isEmpty ? null : reference,
        description: notes.isEmpty ? null : notes,
      );
      return expenseId;
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Expense could not be recorded. Please try again.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
