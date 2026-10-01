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
import '../new_sale_controller.dart';
import '../models/sales_models.dart';
import '../../products/models/product.dart';

class NewSaleScreen extends StatelessWidget {
  const NewSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewSaleController(),
      child: const _NewSaleContent(),
    );
  }
}

class _NewSaleContent extends StatelessWidget {
  const _NewSaleContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NewSaleController>();

    if (controller.isLoading) {
      return const Scaffold(body: LoadingState(message: 'Loading sale components...'));
    }

    if (controller.errorMessage != null && controller.customers.isEmpty) {
      return Scaffold(body: ErrorState(message: controller.errorMessage!));
    }

    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Sale'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Customer & Products)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerSection(context, controller),
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
                        text: 'View Cart & Checkout (${controller.cart.length})',
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

  // --- Customer Selection ---

  Widget _buildCustomerSection(BuildContext context, NewSaleController controller) {
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
          Text('Customer', style: AppTypography.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<CustomerLite?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Customer',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedCustomer,
                  items: [
                    const DropdownMenuItem<CustomerLite?>(value: null, child: Text('Walk-in Customer')),
                    ...controller.customers.map((c) => DropdownMenuItem<CustomerLite?>(value: c, child: Text('${c.name} (${c.phone ?? 'No Phone'})'))),
                  ],
                  onChanged: (c) => controller.setCustomer(c),
                ),
              ),
              if (controller.selectedCustomer != null && controller.selectedCustomer!.vehicles.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<VehicleLite?>(
                    decoration: const InputDecoration(
                      labelText: 'Vehicle (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedVehicle,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...controller.selectedCustomer!.vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v.vehicleNumber))),
                    ],
                    onChanged: (v) => controller.setVehicle(v),
                  ),
                ),
              ]
            ],
          ),
          if (controller.selectedCustomer != null) ...[
            const SizedBox(height: 16),
            if (controller.isLoadingBalance)
              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Text(
                'Current Outstanding Balance: Rs. ${NumberFormat('#,##0').format(controller.customerOutstanding)}',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: controller.customerOutstanding > 0 ? AppColors.warning : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ],
      ),
    );
  }

  // --- Product Selection ---

  Widget _buildProductSearchSection(BuildContext context, NewSaleController controller) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Tyres', style: AppTypography.textTheme.titleLarge),
              Text('${controller.availableProducts.length} in stock', style: AppTypography.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          // Autocomplete for adding tyres
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
                  labelText: 'Search tyre by brand, model, or size...',
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
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Stock: ${option.currentStock.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Rs. ${NumberFormat('#,##0').format(option.sellingPrice)}'),
                            ],
                          ),
                          onTap: () {
                            onSelected(option);
                            // Clear search field after selection implicitly handled by user
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

  Widget _buildMobileCartList(NewSaleController controller) {
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

  Widget _buildCartItemTile(NewSaleController controller, CartItem item) {
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
                    onPressed: item.quantity < item.product.currentStock ? () => controller.updateQuantity(item.product, item.quantity + 1) : null,
                  ),
                ],
              ),
              MoneyDisplay(amount: item.lineTotal),
            ],
          ),
        ],
      ),
    );
  }

  // --- Desktop Sidebar Checkout ---

  Widget _buildCheckoutSidebar(BuildContext context, NewSaleController controller) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.primary.withOpacity(0.05),
          width: double.infinity,
          child: Text('Sale Summary', style: AppTypography.textTheme.titleLarge),
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

  Widget _buildPaymentSection(BuildContext context, NewSaleController controller) {
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
                  items: controller.paymentMethods.map((m) => DropdownMenuItem<PaymentMethod>(value: m, child: Text(m.name))).toList(),
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
                  Text('Credit Balance', style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.warning)),
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
            text: controller.isSubmitting ? 'Processing...' : 'Confirm Sale (${controller.computedStatus})',
            isLoading: controller.isSubmitting,
            onPressed: () => _handleConfirm(context, controller),
          ),
        ],
      ),
    );
  }

  void _showMobileCheckout(BuildContext context, NewSaleController controller) {
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

  Future<void> _handleConfirm(BuildContext context, NewSaleController controller) async {
    try {
      final saleId = await controller.submitSale();
      if (context.mounted) {
        // Pop mobile bottom sheet if open
        if (!ResponsiveLayout.isDesktop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale successfully completed!')));
        context.go('/sales/$saleId');
      }
    } catch (e) {
      // Error handled by controller state
    }
  }
}
