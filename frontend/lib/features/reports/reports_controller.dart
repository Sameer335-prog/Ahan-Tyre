import 'package:flutter/foundation.dart';
import 'services/reports_service.dart';
import 'models/report_models.dart';

class ReportsController extends ChangeNotifier {
  final ReportsService _service = ReportsService();
  
  bool isLoading = false;
  String? errorMessage;
  
  ReportFilter filter = ReportFilter(
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime.now(),
  );

  void setDateRange(DateTime? start, DateTime? end) {
    filter.startDate = start;
    filter.endDate = end;
    notifyListeners();
  }
}

class SalesReportController extends ChangeNotifier {
  final ReportsService _service = ReportsService();
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? summary;
  
  Future<void> load(ReportFilter filter) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      summary = await _service.getSalesSummary(filter.startDate, filter.endDate);
    } catch (e) {
      errorMessage = 'Unable to load sales report.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class ReceivablesReportController extends ChangeNotifier {
  final ReportsService _service = ReportsService();
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> receivables = [];
  
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      receivables = await _service.getCustomerReceivables();
    } catch (e) {
      errorMessage = 'Unable to load receivables.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class PayablesReportController extends ChangeNotifier {
  final ReportsService _service = ReportsService();
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> payables = [];
  
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      payables = await _service.getSupplierPayables();
    } catch (e) {
      errorMessage = 'Unable to load payables.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class InventoryReportController extends ChangeNotifier {
  final ReportsService _service = ReportsService();
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> inventory = [];
  
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      inventory = await _service.getInventoryReport();
    } catch (e) {
      errorMessage = 'Unable to load inventory report.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class LowStockReportController extends ChangeNotifier {
  final ReportsService _service = ReportsService();
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> items = [];
  
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      items = await _service.getLowStockReport();
    } catch (e) {
      errorMessage = 'Unable to load low stock report.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
