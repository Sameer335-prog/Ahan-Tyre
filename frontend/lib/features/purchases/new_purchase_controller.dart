import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/purchases_models.dart';
import 'services/purchases_service.dart';
import '../products/models/product.dart';
import '../products/services/product_service.dart';
import '../sales/models/sales_models.dart'; // Reuse PaymentMethod

class PurchaseCartItem {
  final Product product;
  int quantity;
  double unitCost;

  PurchaseCartItem({required this.product, this.quantity = 1, required this.unitCost});

  double get lineTotal => quantity * unitCost;
}

class NewPurchaseController extends ChangeNotifier {
  final PurchasesService _purchasesService = PurchasesService();
  final ProductService _productService = ProductService();

  // Reference Data
  List<SupplierLite> suppliers = [];
  List<Product> availableProducts = [];
  List<PaymentMethod> paymentMethods = [];
  
  bool isLoading = true;
  String? errorMessage;
  bool isSubmitting = false;

  // Draft Purchase State
  SupplierLite? selectedSupplier;
  List<PurchaseCartItem> cart = [];
  double discount = 0;
  double paidAmount = 0;
  PaymentMethod? selectedPaymentMethod;
  
  // Supplier Balance Info
  double supplierOutstanding = 0;
  bool isLoadingBalance = false;

  NewPurchaseController() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final results = await Future.wait([
        _purchasesService.getActiveSuppliers(),
        _productService.getProducts(activeOnly: true),
        _purchasesService.getPaymentMethods(),
      ]);
      
      suppliers = results[0] as List<SupplierLite>;
      availableProducts = results[1] as List<Product>;
      paymentMethods = results[2] as List<PaymentMethod>;
      
      if (paymentMethods.isNotEmpty) {
        selectedPaymentMethod = paymentMethods.firstWhere((p) => p.code == 'CASH', orElse: () => paymentMethods.first);
      }
    } catch (e) {
      errorMessage = 'Failed to initialize purchase requirements.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSupplier(SupplierLite? supplier) async {
    selectedSupplier = supplier;
    supplierOutstanding = 0;
    
    if (supplier != null) {
      isLoadingBalance = true;
      notifyListeners();
      try {
        supplierOutstanding = await _purchasesService.getSupplierOutstandingBalance(supplier.id);
      } catch (_) {}
      isLoadingBalance = false;
    }
    notifyListeners();
  }

  void addProduct(Product product) {
    final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      cart[existingIndex].quantity++;
    } else {
      cart.add(PurchaseCartItem(product: product, unitCost: product.purchasePrice));
    }
    _recalculatePayment();
    notifyListeners();
  }

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity <= 0) {
      cart.removeWhere((item) => item.product.id == product.id);
    } else {
      final item = cart.firstWhere((item) => item.product.id == product.id);
      item.quantity = newQuantity;
    }
    _recalculatePayment();
    notifyListeners();
  }
  
  void updateUnitCost(Product product, double newCost) {
    if (newCost < 0) return;
    final item = cart.firstWhere((item) => item.product.id == product.id);
    item.unitCost = newCost;
    _recalculatePayment();
    notifyListeners();
  }

  void updatePaidAmount(double amount) {
    paidAmount = amount;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod? method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void _recalculatePayment() {
    if (paidAmount > totalAmount || cart.isEmpty) {
      paidAmount = totalAmount;
    }
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + item.lineTotal);
  double get totalAmount => subtotal - discount;
  double get outstandingAmount => totalAmount - paidAmount;
  
  String get computedStatus {
    if (paidAmount >= totalAmount && totalAmount > 0) return 'Paid';
    if (paidAmount > 0) return 'Partial';
    return 'Credit';
  }

  Future<String> submitPurchase() async {
    if (selectedSupplier == null) throw 'Supplier is required for purchases.';
    if (cart.isEmpty) throw 'Cannot submit empty purchase.';
    if (paidAmount > totalAmount) throw 'Paid amount cannot exceed total.';
    if (paidAmount > 0 && selectedPaymentMethod == null) throw 'Payment method is required.';

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final itemsJson = cart.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_cost': item.unitCost,
        'discount': 0
      }).toList();

      final purchaseId = await _purchasesService.createPurchase(
        supplierId: selectedSupplier!.id,
        items: itemsJson,
        discount: discount,
        paidAmount: paidAmount,
        paymentMethodId: paidAmount > 0 ? selectedPaymentMethod?.id : null,
      );
      
      return purchaseId;
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Purchase could not be completed. Please try again.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
