import 'package:intl/intl.dart';

class Payment {
  final String id;
  final String paymentNumber;
  final String? customerId;
  final String? customerName;
  final String? supplierId;
  final String? supplierName;
  final String? saleId;
  final String? purchaseId;
  final String paymentMethodId;
  final String paymentMethodName;
  final double amount;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;

  Payment({
    required this.id,
    required this.paymentNumber,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    this.saleId,
    this.purchaseId,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.amount,
    required this.paymentDate,
    this.reference,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      paymentNumber: json['payment_number'],
      customerId: json['customer_id'],
      customerName: json['customers']?['name'],
      supplierId: json['supplier_id'],
      supplierName: json['suppliers']?['name'],
      saleId: json['sale_id'],
      purchaseId: json['purchase_id'],
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_methods']?['name'] ?? 'Unknown',
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] ?? json['created_at']),
      reference: json['reference'],
      notes: json['notes'],
    );
  }

  String get type {
    if (customerId != null) return 'Customer Payment';
    if (supplierId != null) return 'Supplier Payment';
    return 'Other Payment';
  }
  
  String get direction {
    if (customerId != null) return 'IN';
    if (supplierId != null) return 'OUT';
    return '-';
  }

  String get partyName {
    return customerName ?? supplierName ?? 'Unknown Party';
  }
}
