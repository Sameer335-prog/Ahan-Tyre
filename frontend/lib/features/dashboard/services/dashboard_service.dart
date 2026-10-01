import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardSummary> fetchDashboardSummary() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Execute independent requests in parallel for maximum performance
    final results = await Future.wait([
      _supabase.from('financial_transactions').select('direction, amount, transaction_date, reference_type'),
      _supabase.from('customer_ledger').select('debit, credit'),
      _supabase.from('supplier_ledger').select('debit, credit'),
      _supabase.from('sales').select('total_amount, status').eq('sale_date', today),
      _supabase.from('purchases').select('total_amount').eq('purchase_date', today),
      _supabase.from('vw_inventory_status').select('product_id, brand, model, size_display, current_stock, minimum_stock, stock_status'),
      _supabase.from('financial_transactions')
          .select('id, transaction_date, reference_type, reference_id, direction, amount, payment_method_id')
          .order('created_at', ascending: false)
          .limit(10),
      _supabase.from('expenses').select('amount').eq('expense_date', today),
    ]);

    final allFinancials = results[0] as List<dynamic>;
    final customerLedger = results[1] as List<dynamic>;
    final supplierLedger = results[2] as List<dynamic>;
    final todaySales = results[3] as List<dynamic>;
    final todayPurchases = results[4] as List<dynamic>;
    final inventory = results[5] as List<dynamic>;
    final recentTrans = results[6] as List<dynamic>;
    final todayExpenses = results[7] as List<dynamic>;

    // 1. Available Cash
    double cash = 0;
    double todayPayIn = 0;
    double todayPayOut = 0;
    for (var t in allFinancials) {
      final amount = (t['amount'] as num).toDouble();
      if (t['direction'] == 'IN') cash += amount;
      if (t['direction'] == 'OUT') cash -= amount;
      
      if (t['transaction_date'] == today) {
        if (t['direction'] == 'IN') todayPayIn += amount;
        if (t['direction'] == 'OUT') todayPayOut += amount;
      }
    }

    // 2. Receivables (Customer Debit - Credit)
    double receivables = 0;
    for (var l in customerLedger) {
      receivables += (l['debit'] as num).toDouble() - (l['credit'] as num).toDouble();
    }

    // 3. Payables (Supplier Credit - Debit)
    double payables = 0;
    for (var l in supplierLedger) {
      payables += (l['credit'] as num).toDouble() - (l['debit'] as num).toDouble();
    }

    // 4. Sales Summary
    double salesTotal = 0;
    int paid = 0;
    int partial = 0;
    int credit = 0;
    for (var s in todaySales) {
      salesTotal += (s['total_amount'] as num).toDouble();
      if (s['status'] == 'COMPLETED') paid++; // Assuming COMPLETED implies paid for now
      else if (s['status'] == 'PENDING') credit++;
      // Partial tracking would require checking paid_amount in a real scenario
    }

    // 5. Purchases Summary
    double purchasesTotal = 0;
    for (var p in todayPurchases) {
      purchasesTotal += (p['total_amount'] as num).toDouble();
    }
    
    // 6. Expenses Summary
    double expensesTotal = 0;
    for (var e in todayExpenses) {
      expensesTotal += (e['amount'] as num).toDouble();
    }

    // 7. Inventory Summary
    int totalProducts = inventory.length;
    int totalStock = 0;
    int lowStock = 0;
    int outOfStock = 0;
    List<Map<String, dynamic>> lowProducts = [];

    for (var i in inventory) {
      final qty = (i['current_stock'] as num?)?.toInt() ?? 0;
      totalStock += qty;
      
      if (i['stock_status'] == 'Out of Stock') {
        outOfStock++;
        lowProducts.add(i);
      } else if (i['stock_status'] == 'Low Stock') {
        lowStock++;
        lowProducts.add(i);
      }
    }

    return DashboardSummary(
      availableCash: cash,
      receivables: receivables,
      payables: payables,
      todaySalesAmount: salesTotal,
      todaySalesCount: todaySales.length,
      todayPaidSales: paid,
      todayPartialSales: partial,
      todayCreditSales: credit,
      todayPurchasesAmount: purchasesTotal,
      todayPurchasesCount: todayPurchases.length,
      todayPaymentsReceived: todayPayIn,
      todayPaymentsMade: todayPayOut,
      todayExpenses: expensesTotal,
      totalProducts: totalProducts,
      totalStock: totalStock,
      lowStockCount: lowStock,
      outOfStockCount: outOfStock,
      lowStockProducts: lowProducts,
      recentTransactions: recentTrans.cast<Map<String, dynamic>>(),
    );
  }
}
