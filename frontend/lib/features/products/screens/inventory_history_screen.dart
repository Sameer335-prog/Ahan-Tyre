import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class InventoryHistoryScreen extends StatefulWidget {
  final String productId;

  const InventoryHistoryScreen({super.key, required this.productId});

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  final _service = ProductService();
  Product? _product;
  List<InventoryMovement> _movements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _service.getProductById(widget.productId),
        _service.getInventoryHistory(widget.productId),
      ]);
      
      setState(() {
        _product = results[0] as Product;
        _movements = results[1] as List<InventoryMovement>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load inventory history.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading inventory history...'));
    if (_errorMessage != null) return Scaffold(body: ErrorState(message: _errorMessage!, onRetry: _loadData));
    if (_product == null) return const Scaffold(body: EmptyState(title: 'Not Found', message: 'Product does not exist.'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory History'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_product!.brand} ${_product!.model}', style: AppTypography.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(_product!.sizeDisplay, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Text('Current Stock: ${_product!.currentStock.toInt()}', style: AppTypography.textTheme.titleMedium),
              ],
            ),
          ),
          
          Expanded(
            child: _movements.isEmpty
                ? const EmptyState(
                    title: 'No inventory movements yet.',
                    message: 'Transactions like purchases or sales will appear here.',
                    icon: Icons.history,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _movements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final m = _movements[index];
                      final isPositive = m.quantity > 0;
                      final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(m.createdAt.toLocal());
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.movementType, style: AppTypography.textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(dateStr, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                if (m.referenceType != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Ref: ${m.referenceType}', style: AppTypography.textTheme.bodySmall),
                                ]
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPositive ? AppColors.successBackground : AppColors.errorBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${isPositive ? '+' : ''}${m.quantity.toInt()}',
                                style: AppTypography.textTheme.titleMedium?.copyWith(
                                  color: isPositive ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
