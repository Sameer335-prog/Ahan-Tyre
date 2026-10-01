import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/payments_service.dart';
import '../sales/models/sales_models.dart';
import '../purchases/models/purchases_models.dart';

class NewPaymentController extends ChangeNotifier {
  final PaymentsService _service = PaymentsService();

  // Mode: customer | supplier
  String mode = 'customer';
  
  // Reference Data
  List<CustomerLite> customers = [];
  List<SupplierLite> suppliers = [];
  List<PaymentMethod> paymentMethods = [];
  
  bool isLoading = true;
  String? errorMessage;
  bool isSubmitting = false;

  // Form State
  CustomerLite? selectedCustomer;
  SupplierLite? selectedSupplier;
  double partyBalance = 0;
  bool isLoadingBalance = false;
  
  double amount = 0;
  PaymentMethod? selectedPaymentMethod;
  String reference = '';
  String notes = '';

  NewPaymentController() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final results = await Future.wait([
        _service.getActiveCustomers(),
        _service.getActiveSuppliers(),
        _service.getPaymentMethods(),
      ]);
      
      customers = results[0] as List<CustomerLite>;
      suppliers = results[1] as List<SupplierLite>;
      paymentMethods = results[2] as List<PaymentMethod>;
      
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

  void setMode(String newMode) {
    if (mode == newMode) return;
    mode = newMode;
    selectedCustomer = null;
    selectedSupplier = null;
    partyBalance = 0;
    amount = 0;
    notifyListeners();
  }

  void setCustomer(CustomerLite? customer) async {
    selectedCustomer = customer;
    partyBalance = 0;
    if (customer != null) {
      isLoadingBalance = true;
      notifyListeners();
      try {
        partyBalance = await _service.getCustomerOutstandingBalance(customer.id);
        amount = partyBalance; // Auto-fill
      } catch (_) {}
      isLoadingBalance = false;
    }
    notifyListeners();
  }

  void setSupplier(SupplierLite? supplier) async {
    selectedSupplier = supplier;
    partyBalance = 0;
    if (supplier != null) {
      isLoadingBalance = true;
      notifyListeners();
      try {
        partyBalance = await _service.getSupplierOutstandingBalance(supplier.id);
        amount = partyBalance; // Auto-fill
      } catch (_) {}
      isLoadingBalance = false;
    }
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

  double get remainingBalance => partyBalance - amount;

  Future<String> submitPayment() async {
    if (mode == 'customer' && selectedCustomer == null) throw 'Customer is required.';
    if (mode == 'supplier' && selectedSupplier == null) throw 'Supplier is required.';
    if (amount <= 0) throw 'Amount must be greater than zero.';
    if (selectedPaymentMethod == null) throw 'Payment method is required.';
    
    // We strictly enforce no "advance" payments in this basic workflow unless instructed
    if (amount > partyBalance) {
      throw 'Payment amount cannot exceed the outstanding balance (Advances are not supported in this basic form).';
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      String paymentId;
      if (mode == 'customer') {
        paymentId = await _service.recordCustomerPayment(
          customerId: selectedCustomer!.id,
          amount: amount,
          paymentMethodId: selectedPaymentMethod!.id,
          reference: reference.isEmpty ? null : reference,
          notes: notes.isEmpty ? null : notes,
        );
      } else {
        paymentId = await _service.recordSupplierPayment(
          supplierId: selectedSupplier!.id,
          amount: amount,
          paymentMethodId: selectedPaymentMethod!.id,
          reference: reference.isEmpty ? null : reference,
          notes: notes.isEmpty ? null : notes,
        );
      }
      return paymentId;
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Payment could not be recorded. Please try again.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
