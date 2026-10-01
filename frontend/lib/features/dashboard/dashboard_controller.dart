import 'package:flutter/foundation.dart';
import 'models/dashboard_summary.dart';
import 'services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  final DashboardService _service = DashboardService();
  
  DashboardSummary? summary;
  bool isLoading = true;
  String? errorMessage;

  DashboardController() {
    refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      summary = await _service.fetchDashboardSummary();
    } catch (e) {
      errorMessage = 'Unable to load dashboard. We couldn\'t retrieve your latest business information.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
