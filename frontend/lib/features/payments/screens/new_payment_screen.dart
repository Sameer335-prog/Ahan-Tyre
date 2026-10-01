import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../new_payment_controller.dart';
import '../../sales/models/sales_models.dart';
import '../../purchases/models/purchases_models.dart';

class NewPaymentScreen extends StatelessWidget {
  const NewPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewPaymentController(),
      child: const _NewPaymentContent(),
    );
  }
}

class _NewPaymentContent extends StatelessWidget {
  const _NewPaymentContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NewPaymentController>();

    if (controller.isLoading) {
      return const Scaffold(body: LoadingState(message: 'Loading payment form...'));
    }

    if (controller.errorMessage != null && (controller.customers.isEmpty && controller.suppliers.isEmpty)) {
      return Scaffold(body: ErrorState(message: controller.errorMessage!));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Payment'),
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
                // Payment Mode Toggle
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.setMode('customer'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.mode == 'customer' ? AppColors.primary : AppColors.background,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                            border: Border.all(color: controller.mode == 'customer' ? AppColors.primary : AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              'Money Received (Customer)',
                              style: TextStyle(
                                color: controller.mode == 'customer' ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.setMode('supplier'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.mode == 'supplier' ? AppColors.primary : AppColors.background,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                            border: Border.all(color: controller.mode == 'supplier' ? AppColors.primary : AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              'Money Paid (Supplier)',
                              style: TextStyle(
                                color: controller.mode == 'supplier' ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Party Selection
                Text(controller.mode == 'customer' ? 'Select Customer' : 'Select Supplier', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (controller.mode == 'customer')
                  DropdownButtonFormField<CustomerLite?>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    value: controller.selectedCustomer,
                    items: controller.customers.map((c) => DropdownMenuItem(value: c, child: Text('${c.name} (${c.phone ?? "No phone"})'))).toList(),
                    onChanged: (c) => controller.setCustomer(c),
                  )
                else
                  DropdownButtonFormField<SupplierLite?>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    value: controller.selectedSupplier,
                    items: controller.suppliers.map((s) => DropdownMenuItem(value: s, child: Text('${s.name} (${s.phone ?? "No phone"})'))).toList(),
                    onChanged: (s) => controller.setSupplier(s),
                  ),
                
                if (controller.isLoadingBalance)
                  const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator())
                else if (controller.selectedCustomer != null || controller.selectedSupplier != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Outstanding Balance', style: AppTypography.textTheme.titleMedium),
                        MoneyDisplay(amount: controller.partyBalance, style: AppTypography.textTheme.titleMedium?.copyWith(color: controller.partyBalance > 0 ? AppColors.warning : AppColors.success)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                
                // Payment Details
                Text('Payment Amount', style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  key: ValueKey('amount_${controller.selectedCustomer?.id}_${controller.selectedSupplier?.id}'),
                  initialValue: controller.amount.toString(),
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
                    hintText: 'e.g. Check #123456',
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
                    hintText: 'Any additional notes...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.updateNotes,
                ),
                const SizedBox(height: 32),

                // Summary
                if (controller.selectedCustomer != null || controller.selectedSupplier != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Balance After Payment'),
                      MoneyDisplay(
                        amount: controller.remainingBalance,
                        style: TextStyle(fontWeight: FontWeight.bold, color: controller.remainingBalance < 0 ? AppColors.error : null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                if (controller.errorMessage != null) ...[
                  Text(controller.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: controller.isSubmitting ? 'Processing...' : 'Confirm Payment',
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

  Future<void> _handleConfirm(BuildContext context, NewPaymentController controller) async {
    try {
      final paymentId = await controller.submitPayment();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successfully recorded!')));
        context.go('/payments/$paymentId');
      }
    } catch (e) {
      // Handled by error state in controller
    }
  }
}
