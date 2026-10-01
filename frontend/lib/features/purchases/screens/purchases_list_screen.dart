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
import '../purchases_controller.dart';
import '../models/purchases_models.dart';

class PurchasesListScreen extends StatelessWidget {
  const PurchasesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchasesController(),
      child: const _PurchasesListContent(),
    );
  }
}

class _PurchasesListContent extends StatelessWidget {
  const _PurchasesListContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchasesController>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    double totalDue = 0;
    int count = controller.displayedPurchases.length;
    for (var p in controller.displayedPurchases) {
      totalDue += p.dueAmount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchases', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '$count records · Rs. ${NumberFormat.compact().format(totalDue)} total due',
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
        onPressed: () => context.go('/purchases/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Purchase'),
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
                    hintText: 'Search purchases or suppliers...',
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
            child: controller.isLoading && controller.displayedPurchases.isEmpty
                ? const LoadingState(message: 'Loading purchases...')
                : controller.errorMessage != null && controller.displayedPurchases.isEmpty
                    ? ErrorState(message: controller.errorMessage!, onRetry: controller.loadData)
                    : controller.displayedPurchases.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: controller.loadData,
                            child: isDesktop 
                                ? _buildDesktopTable(context, controller.displayedPurchases)
                                : _buildMobileList(context, controller.displayedPurchases),
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
              child: const Icon(Icons.local_shipping, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Purchases Yet',
              style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Purchases from suppliers will appear here.',
              style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/purchases/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Purchase'),
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

  Widget _buildDesktopTable(BuildContext context, List<Purchase> purchases) {
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
            DataColumn(label: Text('Purchase')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Paid')),
            DataColumn(label: Text('Due')),
            DataColumn(label: Text('Status')),
          ],
          rows: purchases.map((p) {
            final dateStr = DateFormat('dd MMM, yyyy').format(p.purchaseDate.toLocal());
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.go('/purchases/${p.id}'),
                    child: Text(p.purchaseNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                DataCell(Text(dateStr)),
                DataCell(Text(p.supplierName)),
                DataCell(MoneyDisplay(amount: p.totalAmount)),
                DataCell(MoneyDisplay(amount: p.paidAmount)),
                DataCell(MoneyDisplay(amount: p.dueAmount, style: TextStyle(color: p.dueAmount > 0 ? AppColors.warning : null))),
                DataCell(TransactionStatus(status: p.paymentStatus)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Purchase> purchases) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = purchases[index];
        final dateStr = DateFormat('dd MMM yyyy').format(p.purchaseDate.toLocal());
        
        return InkWell(
          onTap: () => context.go('/purchases/${p.id}'),
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
                    Text(p.purchaseNumber, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    TransactionStatus(status: p.paymentStatus),
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.supplierName, style: AppTypography.textTheme.bodyMedium),
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
                        MoneyDisplay(amount: p.totalAmount, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (p.dueAmount > 0)
                          Text('Due: Rs. ${NumberFormat('#,##0').format(p.dueAmount)}', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.warning)),
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
