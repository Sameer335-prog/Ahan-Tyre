import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/money_display.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _service = ProductService();
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _service.getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load product details.';
        _isLoading = false;
      });
    }
  }

  void _handleDeactivate() {
    if (_product == null) return;
    
    final isDeactivating = _product!.isActive;
    final title = isDeactivating ? 'Deactivate Product?' : 'Activate Product?';
    final message = isDeactivating 
        ? 'This product will no longer be available for new business transactions.\n\nExisting transaction history will remain.'
        : 'This product will become available for new business transactions.';

    ConfirmDialog.show(
      context,
      title: title,
      message: message,
      confirmText: isDeactivating ? 'Deactivate' : 'Activate',
      isDestructive: isDeactivating,
      onConfirm: () async {
        setState(() => _isLoading = true);
        await _service.setProductStatus(_product!.id, !isDeactivating);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isDeactivating ? 'Product deactivated.' : 'Product activated.')
        ));
        _loadProduct();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading product details...'));
    if (_errorMessage != null) return Scaffold(body: ErrorState(message: _errorMessage!, onRetry: _loadProduct));
    if (_product == null) return const Scaffold(body: EmptyState(title: 'Not Found', message: 'Product does not exist.'));

    final p = _product!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/inventory')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Product',
            onPressed: () async {
              await context.push('/inventory/${p.id}/edit');
              _loadProduct(); // refresh after edit
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${p.brand} ${p.model}', style: AppTypography.textTheme.displaySmall),
                          const SizedBox(height: 8),
                          Text(p.sizeDisplay, style: AppTypography.textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                          if (!p.isActive)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: TransactionStatus(status: 'Reversed'), // Red pill style
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          StockStatus(quantity: p.currentStock.toInt()),
                          const SizedBox(height: 8),
                          Text('${p.currentStock.toInt()} units available', style: AppTypography.textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildInfoCard('Brand', p.brand),
                    _buildInfoCard('Model', p.model),
                    _buildInfoCard('Category', p.categoryName ?? 'None'),
                    _buildInfoCard('Condition', p.condition ?? 'New'),
                  ],
                ),
                
                const SizedBox(height: 32),
                Text('Financials & Stock Limits', style: AppTypography.textTheme.titleLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildMoneyCard('Purchase Price', p.purchasePrice),
                    _buildMoneyCard('Selling Price', p.sellingPrice),
                    _buildInfoCard('Minimum Stock Alert', '${p.minimumStock.toInt()} units'),
                  ],
                ),
                
                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SecondaryButton(
                      text: 'View Inventory History',
                      onPressed: () => context.push('/inventory/${p.id}/history'),
                      icon: Icons.history,
                    ),
                    if (p.isActive)
                      DangerButton(text: 'Deactivate Product', onPressed: _handleDeactivate)
                    else
                      PrimaryButton(text: 'Activate Product', onPressed: _handleDeactivate),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildMoneyCard(String label, double amount) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          MoneyDisplay(amount: amount),
        ],
      ),
    );
  }
}
