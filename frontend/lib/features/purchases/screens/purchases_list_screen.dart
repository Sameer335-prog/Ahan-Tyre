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

    if (controller.isLoading && controller.displayedPurchases.isEmpty) {
      return const LoadingState(message: 'Loading purchases...');
    }

    if (controller.errorMessage != null && controller.displayedPurchases.isEmpty) {
      return ErrorState(
        message: controller.errorMessage!,
        onRetry: controller.loadData,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Purchases', style: AppTypography.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Track tyre purchases, supplier payments and outstanding balances.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      text: '+ New Purchase',
                      onPressed: () => context.go('/purchases/new'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFiltersRow(context, controller, isDesktop),
              ],
            ),
          ),
          
          Expanded(
            child: controller.displayedPurchases.isEmpty
                ? const EmptyState(
                    title: 'No Purchases Yet',
                    message: 'Purchases from suppliers will appear here once they are recorded.',
                    icon: Icons.local_shipping,
                  )
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

  Widget _buildFiltersRow(BuildContext context, PurchasesController controller, bool isDesktop) {
    final searchField = SizedBox(
      width: isDesktop ? 300 : double.infinity,
      child: AppSearchField(
        hint: 'Search purchases...',
        onChanged: controller.updateSearch,
      ),
    );

    final statusDropdown = SizedBox(
      width: isDesktop ? 150 : double.infinity,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(),
        ),
        value: controller.selectedStatus ?? 'All',
        items: ['All', 'Paid', 'Partial', 'Credit', 'RETURNED', 'REVERSED']
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (val) => controller.setStatusFilter(val),
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          statusDropdown,
        ],
      );
    }

    return Row(
      children: [
        searchField,
        const SizedBox(width: 16),
        statusDropdown,
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Purchase> purchases) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        width: double.infinity,
        child: DataTable(
          headingTextStyle: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
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
                    child: Text(p.purchaseNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.purchaseNumber, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
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
                        MoneyDisplay(amount: p.totalAmount, style: AppTypography.textTheme.titleMedium),
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
