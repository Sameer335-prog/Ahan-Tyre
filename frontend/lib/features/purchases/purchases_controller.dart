import 'package:flutter/foundation.dart';
import 'models/purchases_models.dart';
import 'services/purchases_service.dart';

class PurchasesController extends ChangeNotifier {
  final PurchasesService _service = PurchasesService();
  
  List<Purchase> _allPurchases = [];
  List<Purchase> displayedPurchases = [];
  
  bool isLoading = true;
  String? errorMessage;
  
  String searchQuery = '';
  String? selectedStatus;

  PurchasesController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allPurchases = await _service.getPurchases();
      applyFilters();
    } catch (e) {
      errorMessage = 'Unable to load purchases. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void setStatusFilter(String? status) {
    selectedStatus = status == 'All' ? null : status;
    applyFilters();
  }

  void applyFilters() {
    displayedPurchases = _allPurchases.where((p) {
      if (selectedStatus != null && p.paymentStatus != selectedStatus) return false;
      
      if (searchQuery.isNotEmpty) {
        final matchRef = p.purchaseNumber.toLowerCase().contains(searchQuery);
        final matchSup = p.supplierName.toLowerCase().contains(searchQuery);
        if (!matchRef && !matchSup) return false;
      }
      return true;
    }).toList();
    
    isLoading = false;
    notifyListeners();
  }
}
