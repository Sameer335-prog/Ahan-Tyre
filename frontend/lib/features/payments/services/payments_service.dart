import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payments_models.dart';
import '../../sales/models/sales_models.dart'; // For CustomerLite and PaymentMethod
import '../../purchases/models/purchases_models.dart'; // For SupplierLite

class PaymentsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Payment>> getPayments({int limit = 100}) async {
    final response = await _supabase
        .from('payments')
        .select('*, customers(name), suppliers(name), payment_methods(name)')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => Payment.fromJson(json)).toList();
  }

  Future<Payment> getPaymentById(String id) async {
    final response = await _supabase
        .from('payments')
        .select('*, customers(name), suppliers(name), payment_methods(name)')
        .eq('id', id)
        .single();
    return Payment.fromJson(response);
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _supabase
        .from('payment_methods')
        .select('*')
        .eq('is_active', true)
        .order('name');
    return (response as List).map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<List<CustomerLite>> getActiveCustomers() async {
    final response = await _supabase
        .from('customers')
        .select('id, name, phone, customer_vehicles(id, vehicle_number)')
        .eq('is_active', true)
        .order('name');
    return (response as List).map((json) => CustomerLite.fromJson(json)).toList();
  }
  
  Future<List<SupplierLite>> getActiveSuppliers() async {
    final response = await _supabase
        .from('suppliers')
        .select('id, name, phone')
        .eq('is_active', true)
        .order('name');
    return (response as List).map((json) => SupplierLite.fromJson(json)).toList();
  }

  Future<double> getCustomerOutstandingBalance(String customerId) async {
    final response = await _supabase
        .from('customer_ledger')
        .select('debit, credit')
        .eq('customer_id', customerId);
        
    double totalDebit = 0;
    double totalCredit = 0;
    for (var row in response as List) {
      totalDebit += (row['debit'] as num?)?.toDouble() ?? 0;
      totalCredit += (row['credit'] as num?)?.toDouble() ?? 0;
    }
    return totalDebit - totalCredit;
  }
  
  Future<double> getSupplierOutstandingBalance(String supplierId) async {
    final response = await _supabase
        .from('supplier_ledger')
        .select('debit, credit')
        .eq('supplier_id', supplierId);
        
    double totalCredit = 0;
    double totalDebit = 0;
    for (var row in response as List) {
      totalCredit += (row['credit'] as num?)?.toDouble() ?? 0;
      totalDebit += (row['debit'] as num?)?.toDouble() ?? 0;
    }
    return totalCredit - totalDebit;
  }

  Future<String> recordCustomerPayment({
    required String customerId,
    required double amount,
    required String paymentMethodId,
    String? reference,
    String? notes,
  }) async {
    final response = await _supabase.rpc('record_customer_payment', params: {
      'p_customer_id': customerId,
      'p_amount': amount,
      'p_payment_method_id': paymentMethodId,
      'p_reference': reference,
      'p_notes': notes,
    });
    return response as String;
  }
  
  Future<String> recordSupplierPayment({
    required String supplierId,
    required double amount,
    required String paymentMethodId,
    String? reference,
    String? notes,
  }) async {
    final response = await _supabase.rpc('record_supplier_payment', params: {
      'p_supplier_id': supplierId,
      'p_amount': amount,
      'p_payment_method_id': paymentMethodId,
      'p_reference': reference,
      'p_notes': notes,
    });
    return response as String;
  }
}
