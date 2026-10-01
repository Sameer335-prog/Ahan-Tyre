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
import '../expenses_controller.dart';
import '../models/expenses_models.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpensesController(),
      child: const _ExpensesListContent(),
    );
  }
}

class _ExpensesListContent extends StatelessWidget {
  const _ExpensesListContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpensesController>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (controller.isLoading && controller.displayedExpenses.isEmpty) {
      return const LoadingState(message: 'Loading expenses...');
    }

    if (controller.errorMessage != null && controller.displayedExpenses.isEmpty) {
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
                        Text('Expenses', style: AppTypography.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Track business expenses and outgoing operating costs.',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      text: '+ Add Expense',
                      onPressed: () => context.go('/expenses/new'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFiltersRow(context, controller, isDesktop),
              ],
            ),
          ),
          
          Expanded(
            child: controller.displayedExpenses.isEmpty
                ? const EmptyState(
                    title: 'No Expenses Yet',
                    message: 'Business expenses will appear here once recorded.',
                    icon: Icons.receipt,
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadData,
                    child: isDesktop 
                        ? _buildDesktopTable(context, controller.displayedExpenses)
                        : _buildMobileList(context, controller.displayedExpenses),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context, ExpensesController controller, bool isDesktop) {
    final searchField = SizedBox(
      width: isDesktop ? 300 : double.infinity,
      child: AppSearchField(
        hint: 'Search expenses...',
        onChanged: controller.updateSearch,
      ),
    );

    final categoryDropdown = SizedBox(
      width: isDesktop ? 200 : double.infinity,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(),
        ),
        value: controller.selectedCategory ?? 'All Categories',
        items: ['All Categories', ...controller.categories.map((c) => c.name)]
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (val) => controller.setCategoryFilter(val),
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          categoryDropdown,
        ],
      );
    }

    return Row(
      children: [
        searchField,
        const SizedBox(width: 16),
        categoryDropdown,
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Expense> expenses) {
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
            DataColumn(label: Text('Expense')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Description')),
          ],
          rows: expenses.map((e) {
            final dateStr = DateFormat('dd MMM, yyyy').format(e.expenseDate.toLocal());
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.go('/expenses/${e.id}'),
                    child: Text(e.expenseNumber, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                ),
                DataCell(Text(dateStr)),
                DataCell(Text(e.categoryName)),
                DataCell(Text(e.paymentMethodName)),
                DataCell(
                  MoneyDisplay(
                    amount: e.amount, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  )
                ),
                DataCell(Text(e.description ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Expense> expenses) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final e = expenses[index];
        final dateStr = DateFormat('dd MMM yyyy').format(e.expenseDate.toLocal());
        
        return InkWell(
          onTap: () => context.go('/expenses/${e.id}'),
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
                    Text(e.expenseNumber, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                    Text(e.categoryName, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(e.description ?? 'No description', style: AppTypography.textTheme.bodyMedium),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MoneyDisplay(
                      amount: e.amount, 
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold
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
