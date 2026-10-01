import 'package:intl/intl.dart';

class Purchase {
  final String id;
  final String purchaseNumber;
  final String supplierId;
  final String supplierName;
  final DateTime purchaseDate;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String? notes;
  final String status;

  Purchase({
    required this.id,
    required this.purchaseNumber,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseDate,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.notes,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      purchaseNumber: json['purchase_number'],
      supplierId: json['supplier_id'],
      supplierName: json['suppliers']?['name'] ?? 'Unknown Supplier',
      purchaseDate: DateTime.parse(json['purchase_date'] ?? json['created_at']),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      dueAmount: (json['due_amount'] as num).toDouble(),
      notes: json['notes'],
      status: json['status'] ?? 'COMPLETED',
    );
  }

  String get paymentStatus {
    if (status == 'RETURNED' || status == 'REVERSED') return status;
    if (paidAmount >= totalAmount) return 'Paid';
    if (paidAmount > 0) return 'Partial';
    return 'Credit';
  }
}

class PurchaseItem {
  final String id;
  final String productId;
  final String productName;
  final String productSize;
  final double quantity;
  final double unitCost;
  final double discount;
  final double lineTotal;

  PurchaseItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSize,
    required this.quantity,
    required this.unitCost,
    required this.discount,
    required this.lineTotal,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    final product = json['products'] ?? {};
    final brand = product['brand'] ?? 'Unknown';
    final model = product['model'] ?? '';
    
    return PurchaseItem(
      id: json['id'],
      productId: json['product_id'],
      productName: '$brand $model'.trim(),
      productSize: product['size_display'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unitCost: (json['unit_cost'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      lineTotal: (json['line_total'] as num).toDouble(),
    );
  }
}

class SupplierLite {
  final String id;
  final String name;
  final String? phone;

  SupplierLite({
    required this.id,
    required this.name,
    this.phone,
  });

  factory SupplierLite.fromJson(Map<String, dynamic> json) {
    return SupplierLite(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}
