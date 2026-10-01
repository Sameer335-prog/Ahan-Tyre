import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/money_display.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../sales_controller.dart';
import '../models/sales_models.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesController(),
      child: const _SalesListContent(),
    );
  }
}

class _SalesListContent extends StatelessWidget {
  const _SalesListContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    double totalRevenue = 0;
    int count = controller.displayedSales.length;
    for (var s in controller.displayedSales) {
      totalRevenue += s.totalAmount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales History', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '$count transactions · Rs. ${NumberFormat.compact().format(totalRevenue)} revenue',
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sales/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Sale'),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: AppColors.background,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: controller.updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by invoice number or customer...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterPill('All', isSelected: controller.selectedStatus == null || controller.selectedStatus == 'All', onTap: () => controller.setStatusFilter('All')),
                      _buildFilterPill('Paid', isSelected: controller.selectedStatus == 'Paid', onTap: () => controller.setStatusFilter('Paid')),
                      _buildFilterPill('Partial', isSelected: controller.selectedStatus == 'Partial', onTap: () => controller.setStatusFilter('Partial')),
                      _buildFilterPill('Credit', isSelected: controller.selectedStatus == 'Credit', onTap: () => controller.setStatusFilter('Credit')),
                      _buildFilterPill('Returned', isSelected: controller.selectedStatus == 'RETURNED', onTap: () => controller.setStatusFilter('RETURNED')),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // List / Table or Empty State
          Expanded(
            child: controller.isLoading && controller.displayedSales.isEmpty
                ? const LoadingState(message: 'Loading sales...')
                : controller.errorMessage != null && controller.displayedSales.isEmpty
                    ? ErrorState(message: controller.errorMessage!, onRetry: controller.loadData)
                    : controller.displayedSales.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: controller.loadData,
                            child: isDesktop 
                                ? _buildDesktopTable(context, controller.displayedSales)
                                : _buildMobileList(context, controller.displayedSales),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No sales records found',
              style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new sale or change your filters.',
              style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/sales/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Sale> sales) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        width: double.infinity,
        child: DataTable(
          headingTextStyle: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(label: Text('Reference')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
          ],
          rows: sales.map((s) {
            final dateStr = DateFormat('dd MMM, yyyy').format(s.saleDate.toLocal());
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.go('/sales/${s.id}'),
                    child: Text(s.invoiceNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                DataCell(Text(s.customerName ?? 'Walk-in')),
                DataCell(Text(dateStr)),
                DataCell(MoneyDisplay(amount: s.totalAmount)),
                DataCell(TransactionStatus(status: s.paymentStatus)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Sale> sales) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = sales[index];
        final dateStr = DateFormat('dd MMM yyyy').format(s.saleDate.toLocal());
        
        return InkWell(
          onTap: () => context.go('/sales/${s.id}'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.invoiceNumber, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    TransactionStatus(status: s.paymentStatus),
                  ],
                ),
                const SizedBox(height: 4),
                Text(s.customerName ?? 'Walk-in Customer', style: AppTypography.textTheme.bodyMedium),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MoneyDisplay(amount: s.totalAmount, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (s.dueAmount > 0)
                          Text('Due: Rs. ${NumberFormat('#,##0').format(s.dueAmount)}', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                    Text(dateStr, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
