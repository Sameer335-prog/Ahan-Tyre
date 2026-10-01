import 'package:flutter/foundation.dart';
import 'models/payments_models.dart';
import 'services/payments_service.dart';

class PaymentsController extends ChangeNotifier {
  final PaymentsService _service = PaymentsService();
  
  List<Payment> _allPayments = [];
  List<Payment> displayedPayments = [];
  
  bool isLoading = true;
  String? errorMessage;
  
  String searchQuery = '';
  String? selectedDirection;

  PaymentsController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allPayments = await _service.getPayments();
      applyFilters();
    } catch (e) {
      errorMessage = 'Unable to load payments. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void setDirectionFilter(String? direction) {
    selectedDirection = direction == 'All' ? null : direction;
    applyFilters();
  }

  void applyFilters() {
    displayedPayments = _allPayments.where((p) {
      if (selectedDirection != null && p.direction != selectedDirection) return false;
      
      if (searchQuery.isNotEmpty) {
        final matchRef = p.paymentNumber.toLowerCase().contains(searchQuery);
        final matchParty = p.partyName.toLowerCase().contains(searchQuery);
        final matchMethod = p.paymentMethodName.toLowerCase().contains(searchQuery);
        if (!matchRef && !matchParty && !matchMethod) return false;
      }
      return true;
    }).toList();
    
    isLoading = false;
    notifyListeners();
  }
}
