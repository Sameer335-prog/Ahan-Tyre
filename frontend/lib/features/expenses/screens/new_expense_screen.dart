import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/states.dart';
import '../new_expense_controller.dart';
import '../models/expenses_models.dart';
import '../../sales/models/sales_models.dart';

class NewExpenseScreen extends StatelessWidget {
  const NewExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewExpenseController(),
      child: const _NewExpenseContent(),
    );
  }
}

class _NewExpenseContent extends StatelessWidget {
  const _NewExpenseContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NewExpenseController>();

    if (controller.isLoading) {
      return const Scaffold(body: LoadingState(message: 'Loading expense form...'));
    }

    if (controller.errorMessage != null && controller.categories.isEmpty) {
      return Scaffold(body: ErrorState(message: controller.errorMessage!));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Expense'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expense Category', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<ExpenseCategory?>(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  value: controller.selectedCategory,
                  items: controller.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (c) => controller.setCategory(c),
                ),
                
                const SizedBox(height: 24),
                Text('Expense Amount', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixText: 'Rs. ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: AppTypography.textTheme.headlineMedium,
                  onChanged: (val) => controller.updateAmount(double.tryParse(val) ?? 0),
                ),
                
                const SizedBox(height: 24),
                Text('Payment Method', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<PaymentMethod>(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  value: controller.selectedPaymentMethod,
                  items: controller.paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (m) => controller.setPaymentMethod(m),
                ),

                const SizedBox(height: 24),
                Text('Reference (Optional)', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'e.g. Receipt #, TR-ID',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.updateReference,
                ),

                const SizedBox(height: 24),
                Text('Notes (Optional)', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Any additional details...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.updateNotes,
                ),
                
                const SizedBox(height: 32),
                if (controller.errorMessage != null) ...[
                  Text(controller.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: controller.isSubmitting ? 'Processing...' : 'Record Expense',
                    isLoading: controller.isSubmitting,
                    onPressed: () => _handleConfirm(context, controller),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context, NewExpenseController controller) async {
    try {
      final expenseId = await controller.submitExpense();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense successfully recorded!')));
        context.go('/expenses/$expenseId');
      }
    } catch (e) {
      // Handled by error state in controller
    }
  }
}
