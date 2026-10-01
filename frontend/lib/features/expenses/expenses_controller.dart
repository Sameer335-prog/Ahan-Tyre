import 'package:flutter/foundation.dart';
import 'models/expenses_models.dart';
import 'services/expenses_service.dart';

class ExpensesController extends ChangeNotifier {
  final ExpensesService _service = ExpensesService();
  
  List<Expense> _allExpenses = [];
  List<Expense> displayedExpenses = [];
  
  bool isLoading = true;
  String? errorMessage;
  
  String searchQuery = '';
  String? selectedCategory;
  List<ExpenseCategory> categories = [];

  ExpensesController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getExpenses(),
        _service.getCategories(),
      ]);
      _allExpenses = results[0] as List<Expense>;
      categories = results[1] as List<ExpenseCategory>;
      applyFilters();
    } catch (e) {
      errorMessage = 'Unable to load expenses. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void setCategoryFilter(String? categoryName) {
    selectedCategory = categoryName == 'All Categories' ? null : categoryName;
    applyFilters();
  }

  void applyFilters() {
    displayedExpenses = _allExpenses.where((e) {
      if (selectedCategory != null && e.categoryName != selectedCategory) return false;
      
      if (searchQuery.isNotEmpty) {
        final matchRef = e.expenseNumber.toLowerCase().contains(searchQuery);
        final matchDesc = (e.description ?? '').toLowerCase().contains(searchQuery);
        final matchCat = e.categoryName.toLowerCase().contains(searchQuery);
        if (!matchRef && !matchDesc && !matchCat) return false;
      }
      return true;
    }).toList();
    
    isLoading = false;
    notifyListeners();
  }
}
