
class Sale {
  final String id;
  final String invoiceNumber;
  final String? customerId;
  final String? customerName;
  final String? vehicleId;
  final String? vehicleNumber;
  final DateTime saleDate;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String? notes;
  final String status;

  Sale({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    this.vehicleId,
    this.vehicleNumber,
    required this.saleDate,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.notes,
    required this.status,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      customerName: json['customers']?['name'],
      vehicleId: json['vehicle_id'],
      vehicleNumber: json['customer_vehicles']?['vehicle_number'],
      saleDate: DateTime.parse(json['sale_date'] ?? json['created_at']),
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

class SaleItem {
  final String id;
  final String productId;
  final String productName; // Joined from products
  final String productSize; // Joined from products
  final double quantity;
  final double unitPrice;
  final double discount;
  final double lineTotal;

  SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSize,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.lineTotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    final product = json['products'] ?? {};
    final brand = product['brand'] ?? 'Unknown';
    final model = product['model'] ?? '';
    
    return SaleItem(
      id: json['id'],
      productId: json['product_id'],
      productName: '$brand $model'.trim(),
      productSize: product['size_display'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      lineTotal: (json['line_total'] as num).toDouble(),
    );
  }
}

class CustomerLite {
  final String id;
  final String name;
  final String? phone;
  final List<VehicleLite> vehicles;

  CustomerLite({
    required this.id,
    required this.name,
    this.phone,
    this.vehicles = const [],
  });

  factory CustomerLite.fromJson(Map<String, dynamic> json) {
    final vehiclesList = json['customer_vehicles'] as List?;
    return CustomerLite(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      vehicles: vehiclesList?.map((v) => VehicleLite.fromJson(v)).toList() ?? [],
    );
  }
}

class VehicleLite {
  final String id;
  final String vehicleNumber;

  VehicleLite({required this.id, required this.vehicleNumber});

  factory VehicleLite.fromJson(Map<String, dynamic> json) {
    return VehicleLite(
      id: json['id'],
      vehicleNumber: json['vehicle_number'],
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String code;

  PaymentMethod({required this.id, required this.name, required this.code});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}
