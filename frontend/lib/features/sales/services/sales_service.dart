import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sales_models.dart';

class SalesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Sale>> getSales({int limit = 50}) async {
    final response = await _supabase
        .from('sales')
        .select('*, customers(name), customer_vehicles(vehicle_number)')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => Sale.fromJson(json)).toList();
  }

  Future<Sale> getSaleById(String id) async {
    final response = await _supabase
        .from('sales')
        .select('*, customers(name), customer_vehicles(vehicle_number)')
        .eq('id', id)
        .single();
    return Sale.fromJson(response);
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final response = await _supabase
        .from('sale_items')
        .select('*, products(brand, model, size_display)')
        .eq('sale_id', saleId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => SaleItem.fromJson(json)).toList();
  }

  Future<List<CustomerLite>> getActiveCustomers() async {
    final response = await _supabase
        .from('customers')
        .select('id, name, phone, customer_vehicles(id, vehicle_number)')
        .eq('is_active', true)
        .order('name');

    return (response as List).map((json) => CustomerLite.fromJson(json)).toList();
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

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _supabase
        .from('payment_methods')
        .select('*')
        .eq('is_active', true)
        .order('name');

    return (response as List).map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<String> createSale({
    String? customerId,
    String? vehicleId,
    required List<Map<String, dynamic>> items,
    required double discount,
    required double paidAmount,
    String? paymentMethodId,
    String? notes,
  }) async {
    // Calling the atomic create_sale RPC defined in Postgres schema
    final response = await _supabase.rpc('create_sale', params: {
      'p_customer_id': customerId,
      'p_vehicle_id': vehicleId,
      'p_items': items,
      'p_discount': discount,
      'p_paid_amount': paidAmount,
      'p_payment_method_id': paymentMethodId,
      'p_notes': notes,
    });

    return response as String;
  }
}
