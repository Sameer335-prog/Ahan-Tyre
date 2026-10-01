import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/money_display.dart';
import '../../core/widgets/states.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/responsive/responsive_layout.dart';
import 'dashboard_controller.dart';
import 'models/dashboard_summary.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    if (controller.isLoading && controller.summary == null) {
      return const LoadingState(message: 'Loading business overview...');
    }

    if (controller.errorMessage != null && controller.summary == null) {
      return ErrorState(
        message: controller.errorMessage!,
        onRetry: controller.refresh,
      );
    }

    final summary = controller.summary ?? DashboardSummary.empty();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              const SizedBox(height: 32),
              _buildFinancialSummary(context, summary),
              const SizedBox(height: 32),
              
              ResponsiveLayout(
                mobile: Column(
                  children: [
                    _buildTodayActivity(context, summary),
                    const SizedBox(height: 24),
                    _buildInventoryOverview(context, summary),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(context, summary),
                  ],
                ),
                desktop: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildTodayActivity(context, summary)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildInventoryOverview(context, summary)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildRecentTransactions(context, summary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _buildQuickActions(context),
                    ),
                  ],
                ),
              ),
              
              if (ResponsiveLayout.isMobile(context) || ResponsiveLayout.isTablet(context)) ...[
                const SizedBox(height: 24),
                _buildQuickActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardController controller) {
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppTypography.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Good morning. Here\'s your business overview for today.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              today,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (controller.isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: controller.refresh,
            tooltip: 'Refresh Dashboard',
          ),
      ],
    );
  }

  Widget _buildFinancialSummary(BuildContext context, DashboardSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildFinancialCard(
              context,
              title: 'Available Cash',
              amount: summary.availableCash,
              icon: Icons.account_balance_wallet,
              description: 'Current business balance',
              color: AppColors.primary,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth / 4) - 12,
            ),
            _buildFinancialCard(
              context,
              title: 'Receivables',
              amount: summary.receivables,
              icon: Icons.call_received,
              description: 'Owed by customers',
              color: AppColors.warning,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth / 4) - 12,
            ),
            _buildFinancialCard(
              context,
              title: 'Payables',
              amount: summary.payables,
              icon: Icons.call_made,
              description: 'Owed to suppliers',
              color: AppColors.error,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth / 4) - 12,
            ),
            _buildFinancialCard(
              context,
              title: 'Today\'s Sales',
              amount: summary.todaySalesAmount,
              icon: Icons.point_of_sale,
              description: '${summary.todaySalesCount} Transactions',
              color: AppColors.success,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth / 4) - 12,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFinancialCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required String description,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.textTheme.titleMedium),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          MoneyDisplay(amount: amount),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivity(BuildContext context, DashboardSummary summary) {
    return _buildSectionCard(
      title: 'Today\'s Activity',
      child: Column(
        children: [
          _buildActivityRow('Sales', summary.todaySalesAmount, AppColors.success),
          _buildActivityRow('Purchases', summary.todayPurchasesAmount, AppColors.error),
          _buildActivityRow('Payments Received', summary.todayPaymentsReceived, AppColors.success),
          _buildActivityRow('Payments Made', summary.todayPaymentsMade, AppColors.warning),
          _buildActivityRow('Expenses', summary.todayExpenses, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String label, double amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium),
          MoneyDisplay(amount: amount, style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: amountColor,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  Widget _buildInventoryOverview(BuildContext context, DashboardSummary summary) {
    return _buildSectionCard(
      title: 'Inventory',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInventoryStat('Products', summary.totalProducts.toString()),
              _buildInventoryStat('Total Stock', summary.totalStock.toString()),
              _buildInventoryStat('Low Stock', summary.lowStockCount.toString(), isAlert: true),
              _buildInventoryStat('Out of Stock', summary.outOfStockCount.toString(), isError: true),
            ],
          ),
          if (summary.outOfStockCount > 0 || summary.lowStockCount > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            if (summary.outOfStockCount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${summary.outOfStockCount} products currently have no available stock.',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            Text('Low Stock Alerts', style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...summary.lowStockProducts.take(3).map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${p['brand']} ${p['model']} ${p['size_display']}', overflow: TextOverflow.ellipsis)),
                    Row(
                      children: [
                        Text('${p['current_stock']} / ${p['minimum_stock']}'),
                        const SizedBox(width: 8),
                        StockStatus(quantity: (p['current_stock'] as num).toInt()),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            if (summary.lowStockProducts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () => context.go('/inventory'),
                  child: Text('+ ${summary.lowStockProducts.length - 3} more...'),
                ),
              )
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Inventory is healthy. No products require restocking.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.success),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInventoryStat(String label, String value, {bool isAlert = false, bool isError = false}) {
    Color valColor = AppColors.textPrimary;
    if (isAlert) valColor = AppColors.warning;
    if (isError) valColor = AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.textTheme.titleMedium?.copyWith(color: valColor)),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, DashboardSummary summary) {
    return _buildSectionCard(
      title: 'Recent Transactions',
      child: summary.recentTransactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No transactions found.'),
            )
          : Column(
              children: summary.recentTransactions.map((tx) {
                final isPositive = tx['direction'] == 'IN';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isPositive ? AppColors.successBackground : AppColors.errorBackground,
                    child: Icon(
                      isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isPositive ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                  ),
                  title: Text(tx['reference_type']),
                  subtitle: Text(tx['transaction_date']),
                  trailing: MoneyDisplay(
                    amount: (tx['amount'] as num).toDouble(),
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return _buildSectionCard(
      title: 'Quick Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => context.go('/sales'),
            icon: const Icon(Icons.add),
            label: const Text('New Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/purchases'),
            icon: const Icon(Icons.add),
            label: const Text('New Purchase'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/customers'),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Customer'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/payments'),
            icon: const Icon(Icons.payment),
            label: const Text('Record Payment'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/expenses'),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Add Expense'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textTheme.titleLarge),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
