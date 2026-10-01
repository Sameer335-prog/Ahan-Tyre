import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../new_purchase_controller.dart';
import '../models/purchases_models.dart';
import '../../products/models/product.dart';
import '../../sales/models/sales_models.dart'; // Reuse PaymentMethod

class NewPurchaseScreen extends StatelessWidget {
  const NewPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewPurchaseController(),
      child: const _NewPurchaseContent(),
    );
  }
}

class _NewPurchaseContent extends StatelessWidget {
  const _NewPurchaseContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NewPurchaseController>();

    if (controller.isLoading) {
      return const Scaffold(body: LoadingState(message: 'Loading purchase components...'));
    }

    if (controller.errorMessage != null && controller.suppliers.isEmpty) {
      return Scaffold(body: ErrorState(message: controller.errorMessage!));
    }

    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Purchase'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Supplier & Products)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSupplierSection(context, controller),
                  const SizedBox(height: 32),
                  _buildProductSearchSection(context, controller),
                ],
              ),
            ),
          ),
          
          // Right Column (Cart & Checkout)
          if (isDesktop)
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: _buildCheckoutSidebar(context, controller),
            ),
        ],
      ),
      // Mobile Bottom Sheet for Cart
      bottomNavigationBar: !isDesktop
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTypography.textTheme.titleMedium),
                        MoneyDisplay(amount: controller.totalAmount, style: AppTypography.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'View Cart & Confirm (${controller.cart.length})',
                        onPressed: controller.cart.isEmpty 
                            ? null 
                            : () => _showMobileCheckout(context, controller),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // --- Supplier Selection ---

  Widget _buildSupplierSection(BuildContext context, NewPurchaseController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supplier', style: AppTypography.textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<SupplierLite?>(
            decoration: const InputDecoration(
              labelText: 'Select Supplier',
              border: OutlineInputBorder(),
            ),
            value: controller.selectedSupplier,
            items: [
              ...controller.suppliers.map((s) => DropdownMenuItem(value: s, child: Text('${s.name} (${s.phone ?? 'No Phone'})'))),
            ],
            onChanged: (s) => controller.setSupplier(s),
          ),
          if (controller.selectedSupplier != null) ...[
            const SizedBox(height: 16),
            if (controller.isLoadingBalance)
              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Text(
                'Current Outstanding Payable: Rs. ${NumberFormat('#,##0').format(controller.supplierOutstanding)}',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: controller.supplierOutstanding > 0 ? AppColors.warning : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ],
      ),
    );
  }

  // --- Product Selection ---

  Widget _buildProductSearchSection(BuildContext context, NewPurchaseController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Tyres', style: AppTypography.textTheme.titleLarge),
          const SizedBox(height: 16),
          Autocomplete<Product>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Product>.empty();
              }
              final query = textEditingValue.text.toLowerCase();
              return controller.availableProducts.where((p) {
                return p.brand.toLowerCase().contains(query) || 
                       p.model.toLowerCase().contains(query) || 
                       p.sizeDisplay.toLowerCase().contains(query);
              });
            },
            displayStringForOption: (Product p) => '${p.brand} ${p.model} - ${p.sizeDisplay}',
            onSelected: (Product p) => controller.addProduct(p),
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Search tyre to purchase...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) => onFieldSubmitted(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300, maxWidth: 600),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text('${option.brand} ${option.model}'),
                          subtitle: Text(option.sizeDisplay),
                          trailing: Text('Prev Cost: Rs. ${NumberFormat('#,##0').format(option.purchasePrice)}'),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          if (controller.cart.isNotEmpty && !ResponsiveLayout.isDesktop(context))
            _buildMobileCartList(controller)
        ],
      ),
    );
  }

  Widget _buildMobileCartList(NewPurchaseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cart Items', style: AppTypography.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...controller.cart.map((item) => _buildCartItemTile(controller, item)),
      ],
    );
  }

  // --- Cart Item Row ---

  Widget _buildCartItemTile(NewPurchaseController controller, PurchaseCartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.product.brand} ${item.product.model}', style: AppTypography.textTheme.titleMedium),
                    Text(item.product.sizeDisplay, style: AppTypography.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => controller.updateQuantity(item.product, 0),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: item.quantity > 1 ? () => controller.updateQuantity(item.product, item.quantity - 1) : null,
                  ),
                  Text('${item.quantity}', style: AppTypography.textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => controller.updateQuantity(item.product, item.quantity + 1),
                  ),
                ],
              ),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: item.unitCost.toString(),
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixText: 'Rs. ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final d = double.tryParse(val) ?? 0;
                    controller.updateUnitCost(item.product, d);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Line Total: Rs. ${NumberFormat('#,##0').format(item.lineTotal)}', style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- Desktop Sidebar Checkout ---

  Widget _buildCheckoutSidebar(BuildContext context, NewPurchaseController controller) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.primary.withOpacity(0.05),
          width: double.infinity,
          child: Text('Purchase Summary', style: AppTypography.textTheme.titleLarge),
        ),
        Expanded(
          child: controller.cart.isEmpty
              ? const Center(child: Text('No tyres added yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.cart.length,
                  itemBuilder: (context, index) => _buildCartItemTile(controller, controller.cart[index]),
                ),
        ),
        _buildPaymentSection(context, controller),
      ],
    );
  }

  // --- Payment Section ---

  Widget _buildPaymentSection(BuildContext context, NewPurchaseController controller) {
    if (controller.cart.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow('Subtotal', controller.subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow('Total', controller.totalAmount, isBold: true),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Paid Amount', border: OutlineInputBorder(), prefixText: 'Rs. '),
                  keyboardType: TextInputType.number,
                  initialValue: controller.paidAmount.toString(),
                  onChanged: (val) {
                    final d = double.tryParse(val) ?? 0;
                    controller.updatePaidAmount(d);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PaymentMethod>(
                  decoration: const InputDecoration(labelText: 'Method', border: OutlineInputBorder()),
                  value: controller.selectedPaymentMethod,
                  items: controller.paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: controller.paidAmount > 0 ? (m) => controller.setPaymentMethod(m) : null,
                ),
              ),
            ],
          ),
          
          if (controller.outstandingAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warningBackground, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payable Balance', style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.warning)),
                  MoneyDisplay(amount: controller.outstandingAmount, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.warning)),
                ],
              ),
            ),
          ],
          
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(controller.errorMessage!, style: const TextStyle(color: AppColors.error)),
          ],
          
          const SizedBox(height: 24),
          PrimaryButton(
            text: controller.isSubmitting ? 'Processing...' : 'Confirm Purchase (${controller.computedStatus})',
            isLoading: controller.isSubmitting,
            onPressed: () => _handleConfirm(context, controller),
          ),
        ],
      ),
    );
  }

  void _showMobileCheckout(BuildContext context, NewPurchaseController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('Checkout'),
              automaticallyImplyLeading: false,
              actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildPaymentSection(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    TextStyle? style = AppTypography.textTheme.bodyMedium;
    if (isBold) style = AppTypography.textTheme.titleLarge;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        MoneyDisplay(amount: amount, style: style),
      ],
    );
  }

  Future<void> _handleConfirm(BuildContext context, NewPurchaseController controller) async {
    try {
      final purchaseId = await controller.submitPurchase();
      if (context.mounted) {
        if (!ResponsiveLayout.isDesktop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase successfully completed!')));
        context.go('/purchases/$purchaseId');
      }
    } catch (e) {
      // Handled by controller error state
    }
  }
}
