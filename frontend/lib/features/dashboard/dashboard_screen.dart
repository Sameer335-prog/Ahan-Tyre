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
import '../auth/auth_controller.dart';

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
    final summary = controller.summary ?? DashboardSummary.empty();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterPill('This Month', isSelected: true),
                      _buildFilterPill('This Week'),
                      _buildFilterPill('Today'),
                      _buildFilterPill('All Time'),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isLoading && controller.summary == null)
                      const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                    else if (controller.errorMessage != null && controller.summary == null)
                      ErrorState(message: controller.errorMessage!, onRetry: controller.refresh)
                    else ...[
                      // 5 Financial Cards
                      Row(
                        children: [
                          Expanded(child: _buildFinancialCard(title: 'Total Sales', amount: summary.todaySalesAmount, icon: Icons.trending_up, color: AppColors.success, subtitle: 'Revenue')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFinancialCard(title: 'Net Profit', amount: 0, icon: Icons.savings, color: AppColors.primary, subtitle: 'Net profit')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildFinancialCard(title: 'Receivables', amount: summary.receivables, icon: Icons.request_quote, color: AppColors.warning, subtitle: 'Customer credit')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFinancialCard(title: 'Payables', amount: summary.payables, icon: Icons.payments, color: AppColors.error, subtitle: 'Vendor dues')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFinancialCard(
                              title: 'Inventory Value',
                              amount: summary.totalStock.toDouble() * 1000, // Mock value
                              icon: Icons.inventory,
                              color: AppColors.primary,
                              subtitle: 'Current tyre stock worth'
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()), // Empty space to match image layout
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      Text('Quick Actions', style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      
                      // Quick Actions Grid (6 items)
                      GridView.count(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.2,
                        children: [
                          _buildQuickActionBtn(context, 'New Sale', Icons.point_of_sale, '/sales', AppColors.primaryLight),
                          _buildQuickActionBtn(context, 'Add Tyre', Icons.add_circle, '/inventory', AppColors.primaryLight),
                          _buildQuickActionBtn(context, 'Purchases', Icons.shopping_cart, '/purchases', AppColors.warning),
                          _buildQuickActionBtn(context, 'Payments', Icons.payments, '/payments', AppColors.success),
                          _buildQuickActionBtn(context, 'Reports', Icons.bar_chart, '/reports', AppColors.primaryLight),
                          _buildQuickActionBtn(context, 'Accounts', Icons.account_balance, '/customers', AppColors.secondary),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      Text('Sales Revenue Trend', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Daily revenue for the selected period', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('No records found')),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tyre-Shop ERP', style: AppTypography.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              InkWell(
                onTap: () => context.read<AuthController>().signOut(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Log Out', style: AppTypography.textTheme.labelMedium?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome, Admin User',
            style: AppTypography.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text('Live API', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          MoneyDisplay(
            amount: amount,
            style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, String label, IconData icon, String route, Color color) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
