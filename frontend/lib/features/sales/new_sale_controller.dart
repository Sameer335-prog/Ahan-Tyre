import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/sales_models.dart';
import 'services/sales_service.dart';
import '../products/models/product.dart';
import '../products/services/product_service.dart';

class CartItem {
  final Product product;
  int quantity;
  double unitPrice;

  CartItem({required this.product, this.quantity = 1, required this.unitPrice});

  double get lineTotal => quantity * unitPrice;
}

class NewSaleController extends ChangeNotifier {
  final SalesService _salesService = SalesService();
  final ProductService _productService = ProductService();

  // Reference Data
  List<CustomerLite> customers = [];
  List<Product> availableProducts = [];
  List<PaymentMethod> paymentMethods = [];
  
  bool isLoading = true;
  String? errorMessage;
  bool isSubmitting = false;

  // Draft Sale State
  CustomerLite? selectedCustomer;
  VehicleLite? selectedVehicle;
  List<CartItem> cart = [];
  double discount = 0;
  double paidAmount = 0;
  PaymentMethod? selectedPaymentMethod;
  
  // Customer Balance Info
  double customerOutstanding = 0;
  bool isLoadingBalance = false;

  NewSaleController() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final results = await Future.wait([
        _salesService.getActiveCustomers(),
        _productService.getProducts(activeOnly: true),
        _salesService.getPaymentMethods(),
      ]);
      
      customers = results[0] as List<CustomerLite>;
      availableProducts = (results[1] as List<Product>).where((p) => p.currentStock > 0).toList();
      paymentMethods = results[2] as List<PaymentMethod>;
      
      if (paymentMethods.isNotEmpty) {
        selectedPaymentMethod = paymentMethods.firstWhere((p) => p.code == 'CASH', orElse: () => paymentMethods.first);
      }
    } catch (e) {
      errorMessage = 'Failed to initialize sale requirements.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setCustomer(CustomerLite? customer) async {
    selectedCustomer = customer;
    selectedVehicle = null;
    customerOutstanding = 0;
    
    if (customer != null) {
      isLoadingBalance = true;
      notifyListeners();
      try {
        customerOutstanding = await _salesService.getCustomerOutstandingBalance(customer.id);
      } catch (_) {}
      isLoadingBalance = false;
    }
    notifyListeners();
  }

  void setVehicle(VehicleLite? vehicle) {
    selectedVehicle = vehicle;
    notifyListeners();
  }

  void addProduct(Product product) {
    if (product.currentStock <= 0) return;
    
    final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (cart[existingIndex].quantity < product.currentStock) {
        cart[existingIndex].quantity++;
      }
    } else {
      cart.add(CartItem(product: product, unitPrice: product.sellingPrice));
    }
    _recalculatePayment();
    notifyListeners();
  }

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity <= 0) {
      cart.removeWhere((item) => item.product.id == product.id);
    } else if (newQuantity <= product.currentStock) {
      final item = cart.firstWhere((item) => item.product.id == product.id);
      item.quantity = newQuantity;
    }
    _recalculatePayment();
    notifyListeners();
  }
  
  void updateUnitPrice(Product product, double newPrice) {
    if (newPrice < 0) return;
    final item = cart.firstWhere((item) => item.product.id == product.id);
    item.unitPrice = newPrice;
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
    // Automatically set paid to total if we hadn't manually edited it, or if it exceeds total
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

  Future<String> submitSale() async {
    if (cart.isEmpty) throw 'Cannot submit empty sale.';
    if (paidAmount > totalAmount) throw 'Paid amount cannot exceed total.';
    if (paidAmount > 0 && selectedPaymentMethod == null) throw 'Payment method is required.';

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final itemsJson = cart.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'discount': 0
      }).toList();

      final saleId = await _salesService.createSale(
        customerId: selectedCustomer?.id,
        vehicleId: selectedVehicle?.id,
        items: itemsJson,
        discount: discount,
        paidAmount: paidAmount,
        paymentMethodId: paidAmount > 0 ? selectedPaymentMethod?.id : null,
      );
      
      return saleId;
    } on PostgrestException catch (e) {
      if (e.message.contains('Insufficient stock')) {
        throw 'Stock changed during checkout. Please review items.';
      }
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Sale could not be completed. Please try again.';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
