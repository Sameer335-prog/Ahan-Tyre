import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchases_models.dart';
import '../../sales/models/sales_models.dart'; // Reuse PaymentMethod

class PurchasesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Purchase>> getPurchases({int limit = 50}) async {
    final response = await _supabase
        .from('purchases')
        .select('*, suppliers(name)')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => Purchase.fromJson(json)).toList();
  }

  Future<Purchase> getPurchaseById(String id) async {
    final response = await _supabase
        .from('purchases')
        .select('*, suppliers(name)')
        .eq('id', id)
        .single();
    return Purchase.fromJson(response);
  }

  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId) async {
    final response = await _supabase
        .from('purchase_items')
        .select('*, products(brand, model, size_display)')
        .eq('purchase_id', purchaseId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => PurchaseItem.fromJson(json)).toList();
  }

  Future<List<SupplierLite>> getActiveSuppliers() async {
    final response = await _supabase
        .from('suppliers')
        .select('id, name, phone')
        .eq('is_active', true)
        .order('name');

    return (response as List).map((json) => SupplierLite.fromJson(json)).toList();
  }
  
  Future<double> getSupplierOutstandingBalance(String supplierId) async {
    final response = await _supabase
        .from('supplier_ledger')
        .select('debit, credit')
        .eq('supplier_id', supplierId);
        
    double totalCredit = 0; // What we owe them
    double totalDebit = 0;  // What we paid them
    
    for (var row in response as List) {
      totalCredit += (row['credit'] as num?)?.toDouble() ?? 0;
      totalDebit += (row['debit'] as num?)?.toDouble() ?? 0;
    }
    
    return totalCredit - totalDebit;
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _supabase
        .from('payment_methods')
        .select('*')
        .eq('is_active', true)
        .order('name');

    return (response as List).map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<String> createPurchase({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    required double discount,
    required double paidAmount,
    String? paymentMethodId,
    String? notes,
  }) async {
    final response = await _supabase.rpc('create_purchase', params: {
      'p_supplier_id': supplierId,
      'p_items': items,
      'p_discount': discount,
      'p_paid_amount': paidAmount,
      'p_payment_method_id': paymentMethodId,
      'p_notes': notes,
    });

    return response as String;
  }
}
