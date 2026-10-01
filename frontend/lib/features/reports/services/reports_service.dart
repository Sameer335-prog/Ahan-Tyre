import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sales/models/sales_models.dart';
import '../../purchases/models/purchases_models.dart';
import '../../payments/models/payments_models.dart';
import '../../expenses/models/expenses_models.dart';

class ReportsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- Summary Reports ---

  Future<Map<String, dynamic>> getSalesSummary(DateTime? startDate, DateTime? endDate) async {
    var query = _supabase.from('sales').select('id, invoice_number, sale_date, created_at, total_amount, paid_amount, due_amount, customer_id');
    
    if (startDate != null) {
      query = query.gte('sale_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('sale_date', endDate.toIso8601String());
    }
    
    final response = await query;
    final sales = response as List;
    
    double total = 0;
    double paid = 0;
    
    for (var sale in sales) {
      total += (sale['total_amount'] as num).toDouble();
      paid += (sale['paid_amount'] as num).toDouble();
    }
    
    return {
      'count': sales.length,
      'total': total,
      'paid': paid,
      'outstanding': total - paid,
      'data': sales,
    };
  }

  Future<List<Sale>> getSales(DateTime? startDate, DateTime? endDate) async {
    var query = _supabase.from('sales').select('*, customers(name, phone)');
    
    if (startDate != null) {
      query = query.gte('sale_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('sale_date', endDate.toIso8601String());
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Sale.fromJson(json)).toList();
  }

  Future<List<Purchase>> getPurchases(DateTime? startDate, DateTime? endDate) async {
    var query = _supabase.from('purchases').select('*, suppliers(name, phone)');
    
    if (startDate != null) {
      query = query.gte('purchase_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('purchase_date', endDate.toIso8601String());
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Purchase.fromJson(json)).toList();
  }

  Future<List<Payment>> getPayments(DateTime? startDate, DateTime? endDate) async {
    var query = _supabase.from('payments').select('*, customers(name), suppliers(name), payment_methods(name)');
    
    if (startDate != null) {
      query = query.gte('payment_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('payment_date', endDate.toIso8601String());
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Payment.fromJson(json)).toList();
  }

  Future<List<Expense>> getExpenses(DateTime? startDate, DateTime? endDate) async {
    var query = _supabase.from('expenses').select('*, expense_categories(name), payment_methods(name)');
    
    if (startDate != null) {
      query = query.gte('expense_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('expense_date', endDate.toIso8601String());
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getCustomerReceivables() async {
    final response = await _supabase.from('customers').select('id, name, phone, is_active');
    final customers = response as List;
    
    final ledgerResponse = await _supabase.from('customer_ledger').select('customer_id, debit, credit');
    final ledger = ledgerResponse as List;

    List<Map<String, dynamic>> receivables = [];

    for (var customer in customers) {
      if (customer['is_active'] != true) continue;
      
      final customerLedger = ledger.where((l) => l['customer_id'] == customer['id']).toList();
      double totalDebit = 0;
      double totalCredit = 0;
      
      for (var row in customerLedger) {
        totalDebit += (row['debit'] as num?)?.toDouble() ?? 0;
        totalCredit += (row['credit'] as num?)?.toDouble() ?? 0;
      }
      
      final outstanding = totalDebit - totalCredit;
      if (outstanding > 0) {
        receivables.add({
          'id': customer['id'],
          'name': customer['name'],
          'phone': customer['phone'] ?? 'No Phone',
          'total_debit': totalDebit,
          'total_credit': totalCredit,
          'outstanding': outstanding,
        });
      }
    }
    
    receivables.sort((a, b) => b['outstanding'].compareTo(a['outstanding']));
    return receivables;
  }

  Future<List<Map<String, dynamic>>> getSupplierPayables() async {
    final response = await _supabase.from('suppliers').select('id, name, phone, is_active');
    final suppliers = response as List;
    
    final ledgerResponse = await _supabase.from('supplier_ledger').select('supplier_id, debit, credit');
    final ledger = ledgerResponse as List;

    List<Map<String, dynamic>> payables = [];

    for (var supplier in suppliers) {
      if (supplier['is_active'] != true) continue;
      
      final supplierLedger = ledger.where((l) => l['supplier_id'] == supplier['id']).toList();
      double totalDebit = 0;
      double totalCredit = 0;
      
      for (var row in supplierLedger) {
        totalDebit += (row['debit'] as num?)?.toDouble() ?? 0;
        totalCredit += (row['credit'] as num?)?.toDouble() ?? 0;
      }
      
      final outstanding = totalCredit - totalDebit; // Credit is payable for suppliers
      if (outstanding > 0) {
        payables.add({
          'id': supplier['id'],
          'name': supplier['name'],
          'phone': supplier['phone'] ?? 'No Phone',
          'total_debit': totalDebit,
          'total_credit': totalCredit,
          'outstanding': outstanding,
        });
      }
    }
    
    payables.sort((a, b) => b['outstanding'].compareTo(a['outstanding']));
    return payables;
  }

  Future<List<Map<String, dynamic>>> getInventoryReport() async {
    final response = await _supabase.from('vw_inventory_status').select('*').order('brand');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getLowStockReport() async {
    // Use the dedicated backend view which correctly compares columns in SQL
    final response = await _supabase.from('vw_low_stock_report').select('*').order('current_stock');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getCustomerStatement(String customerId) async {
    final response = await _supabase
        .from('customer_ledger')
        .select('*')
        .eq('customer_id', customerId)
        .order('transaction_date')
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSupplierStatement(String supplierId) async {
    final response = await _supabase
        .from('supplier_ledger')
        .select('*')
        .eq('supplier_id', supplierId)
        .order('transaction_date')
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }
}
