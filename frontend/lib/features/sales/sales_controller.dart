import 'package:flutter/foundation.dart';
import 'models/sales_models.dart';
import 'services/sales_service.dart';

class SalesController extends ChangeNotifier {
  final SalesService _service = SalesService();
  
  List<Sale> _allSales = [];
  List<Sale> displayedSales = [];
  
  bool isLoading = true;
  String? errorMessage;
  
  String searchQuery = '';
  String? selectedStatus;

  SalesController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allSales = await _service.getSales();
      applyFilters();
    } catch (e) {
      errorMessage = 'Unable to load sales. Please try again.';
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
    displayedSales = _allSales.where((s) {
      if (selectedStatus != null && s.paymentStatus != selectedStatus) return false;
      
      if (searchQuery.isNotEmpty) {
        final matchRef = s.invoiceNumber.toLowerCase().contains(searchQuery);
        final matchCust = (s.customerName ?? '').toLowerCase().contains(searchQuery);
        final matchVeh = (s.vehicleNumber ?? '').toLowerCase().contains(searchQuery);
        if (!matchRef && !matchCust && !matchVeh) return false;
      }
      return true;
    }).toList();
    
    isLoading = false;
    notifyListeners();
  }
}
