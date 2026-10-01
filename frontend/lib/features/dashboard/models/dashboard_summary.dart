class DashboardSummary {
  final double availableCash;
  final double receivables;
  final double payables;
  
  final double todaySalesAmount;
  final int todaySalesCount;
  final int todayPaidSales;
  final int todayPartialSales;
  final int todayCreditSales;

  final double todayPurchasesAmount;
  final int todayPurchasesCount;
  
  final double todayPaymentsReceived;
  final double todayPaymentsMade;
  final double todayExpenses;

  final int totalProducts;
  final int totalStock;
  final int lowStockCount;
  final int outOfStockCount;
  final List<Map<String, dynamic>> lowStockProducts;
  
  final List<Map<String, dynamic>> recentTransactions;

  DashboardSummary({
    required this.availableCash,
    required this.receivables,
    required this.payables,
    required this.todaySalesAmount,
    required this.todaySalesCount,
    required this.todayPaidSales,
    required this.todayPartialSales,
    required this.todayCreditSales,
    required this.todayPurchasesAmount,
    required this.todayPurchasesCount,
    required this.todayPaymentsReceived,
    required this.todayPaymentsMade,
    required this.todayExpenses,
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.lowStockProducts,
    required this.recentTransactions,
  });

  factory DashboardSummary.empty() {
    return DashboardSummary(
      availableCash: 0,
      receivables: 0,
      payables: 0,
      todaySalesAmount: 0,
      todaySalesCount: 0,
      todayPaidSales: 0,
      todayPartialSales: 0,
      todayCreditSales: 0,
      todayPurchasesAmount: 0,
      todayPurchasesCount: 0,
      todayPaymentsReceived: 0,
      todayPaymentsMade: 0,
      todayExpenses: 0,
      totalProducts: 0,
      totalStock: 0,
      lowStockCount: 0,
      outOfStockCount: 0,
      lowStockProducts: [],
      recentTransactions: [],
    );
  }
}
