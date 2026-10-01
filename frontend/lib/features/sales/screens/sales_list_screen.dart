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

    if (controller.isLoading && controller.displayedSales.isEmpty) {
      return const LoadingState(message: 'Loading sales...');
    }

    if (controller.errorMessage != null && controller.displayedSales.isEmpty) {
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
                        Text('Sales', style: AppTypography.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Manage sales and customer transactions',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      text: '+ New Sale',
                      onPressed: () => context.go('/sales/new'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFiltersRow(context, controller, isDesktop),
              ],
            ),
          ),
          
          Expanded(
            child: controller.displayedSales.isEmpty
                ? const EmptyState(
                    title: 'No sales found',
                    message: 'Your completed sales will appear here.',
                    icon: Icons.receipt_long,
                  )
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

  Widget _buildFiltersRow(BuildContext context, SalesController controller, bool isDesktop) {
    final searchField = SizedBox(
      width: isDesktop ? 300 : double.infinity,
      child: AppSearchField(
        hint: 'Search sales...',
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

  Widget _buildDesktopTable(BuildContext context, List<Sale> sales) {
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
                    child: Text(s.invoiceNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.invoiceNumber, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
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
                        MoneyDisplay(amount: s.totalAmount, style: AppTypography.textTheme.titleMedium),
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
