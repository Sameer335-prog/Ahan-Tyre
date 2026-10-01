import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../payments_controller.dart';
import '../models/payments_models.dart';

class PaymentsListScreen extends StatelessWidget {
  const PaymentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentsController(),
      child: const _PaymentsListContent(),
    );
  }
}

class _PaymentsListContent extends StatelessWidget {
  const _PaymentsListContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (controller.isLoading && controller.displayedPayments.isEmpty) {
      return const LoadingState(message: 'Loading payments...');
    }

    if (controller.errorMessage != null && controller.displayedPayments.isEmpty) {
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
                        Text('Payments', style: AppTypography.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Track money received from customers and money paid to suppliers.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      text: '+ Record Payment',
                      onPressed: () => context.go('/payments/new'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFiltersRow(context, controller, isDesktop),
              ],
            ),
          ),
          
          Expanded(
            child: controller.displayedPayments.isEmpty
                ? const EmptyState(
                    title: 'No Payments Yet',
                    message: 'Customer and supplier payments will appear here.',
                    icon: Icons.payments,
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadData,
                    child: isDesktop 
                        ? _buildDesktopTable(context, controller.displayedPayments)
                        : _buildMobileList(context, controller.displayedPayments),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context, PaymentsController controller, bool isDesktop) {
    final searchField = SizedBox(
      width: isDesktop ? 300 : double.infinity,
      child: AppSearchField(
        hint: 'Search payments...',
        onChanged: controller.updateSearch,
      ),
    );

    final directionDropdown = SizedBox(
      width: isDesktop ? 180 : double.infinity,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(),
        ),
        value: controller.selectedDirection ?? 'All',
        items: ['All', 'IN', 'OUT']
            .map((s) => DropdownMenuItem(value: s, child: Text(s == 'IN' ? 'Money Received' : s == 'OUT' ? 'Money Paid' : s)))
            .toList(),
        onChanged: (val) => controller.setDirectionFilter(val),
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          directionDropdown,
        ],
      );
    }

    return Row(
      children: [
        searchField,
        const SizedBox(width: 16),
        directionDropdown,
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Payment> payments) {
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
            DataColumn(label: Text('Payment')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Party')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Amount')),
          ],
          rows: payments.map((p) {
            final dateStr = DateFormat('dd MMM, yyyy').format(p.paymentDate.toLocal());
            final isReceived = p.direction == 'IN';
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.go('/payments/${p.id}'),
                    child: Text(p.paymentNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                ),
                DataCell(Text(dateStr)),
                DataCell(Text(p.type)),
                DataCell(Text(p.partyName)),
                DataCell(Text(p.paymentMethodName)),
                DataCell(
                  MoneyDisplay(
                    amount: p.amount, 
                    style: TextStyle(
                      color: isReceived ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold
                    )
                  )
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Payment> payments) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = payments[index];
        final dateStr = DateFormat('dd MMM yyyy').format(p.paymentDate.toLocal());
        final isReceived = p.direction == 'IN';
        
        return InkWell(
          onTap: () => context.go('/payments/${p.id}'),
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
                    Text(p.paymentNumber, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                    Text(p.type, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.partyName, style: AppTypography.textTheme.bodyMedium),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MoneyDisplay(
                      amount: p.amount, 
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: isReceived ? AppColors.success : AppColors.error
                      )
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
