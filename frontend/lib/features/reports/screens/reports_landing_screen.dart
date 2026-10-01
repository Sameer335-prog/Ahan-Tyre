import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';

class ReportsLandingScreen extends StatelessWidget {
  const ReportsLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports & Documents', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              'Review business activity, financial records and inventory.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Sales & Purchases'),
                _buildGrid(context, [
                  _ReportCard(title: 'Sales Report', description: 'View sales activity and outstanding balances.', icon: Icons.point_of_sale, route: '/reports/sales'),
                ]),
                
                const SizedBox(height: 32),
                _buildSectionTitle('Financial & Accounts'),
                _buildGrid(context, [
                  _ReportCard(title: 'Customer Receivables', description: 'View customers with outstanding balances.', icon: Icons.account_balance_wallet, route: '/reports/receivables'),
                  _ReportCard(title: 'Supplier Payables', description: 'View suppliers with outstanding balances.', icon: Icons.money_off, route: '/reports/payables'),
                ]),
                
                const SizedBox(height: 32),
                _buildSectionTitle('Inventory'),
                _buildGrid(context, [
                  _ReportCard(title: 'Inventory Report', description: 'Current stock and total stock value.', icon: Icons.inventory_2, route: '/reports/inventory'),
                  _ReportCard(title: 'Low Stock Report', description: 'Products at or below minimum stock level.', icon: Icons.warning_amber, route: '/reports/low-stock'),
                ]),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildGrid(BuildContext context, List<_ReportCard> cards) {
    return GridView.extent(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      maxCrossAxisExtent: 400,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: cards,
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
