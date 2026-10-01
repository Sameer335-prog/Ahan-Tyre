import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/money_display.dart';
import '../models/purchases_models.dart';
import '../services/purchases_service.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  final String purchaseId;

  const PurchaseDetailsScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  final _service = PurchasesService();
  Purchase? _purchase;
  List<PurchaseItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _supplierOutstanding = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final purchase = await _service.getPurchaseById(widget.purchaseId);
      final items = await _service.getPurchaseItems(widget.purchaseId);
      final outstanding = await _service.getSupplierOutstandingBalance(purchase.supplierId);
      
      setState(() {
        _purchase = purchase;
        _items = items;
        _supplierOutstanding = outstanding;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load purchase details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading purchase details...'));
    if (_errorMessage != null) return Scaffold(body: ErrorState(message: _errorMessage!, onRetry: _loadData));
    if (_purchase == null) return const Scaffold(body: EmptyState(title: 'Not Found', message: 'Purchase does not exist.'));

    final p = _purchase!;
    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(p.purchaseDate.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase #${p.purchaseNumber}'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/purchases')),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.purchaseNumber, style: AppTypography.textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(dateStr, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    TransactionStatus(status: p.paymentStatus),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Supplier Details
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Supplier', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(p.supplierName, style: AppTypography.textTheme.titleMedium),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Supplier Outstanding Balance', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Rs. ${NumberFormat('#,##0').format(_supplierOutstanding)}', style: AppTypography.textTheme.titleMedium?.copyWith(color: _supplierOutstanding > 0 ? AppColors.warning : AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Text('Purchased Items', style: AppTypography.textTheme.titleLarge),
                const SizedBox(height: 16),
                
                // Items List
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: AppTypography.textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(item.productSize, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('Qty: ${item.quantity.toInt()} × Rs. ${NumberFormat('#,##0').format(item.unitCost)}'),
                                ],
                              ),
                            ),
                            MoneyDisplay(amount: item.lineTotal, style: AppTypography.textTheme.titleMedium),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Summary
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', p.subtotal),
                        if (p.discount > 0) ...[
                          const SizedBox(height: 12),
                          _buildSummaryRow('Discount', -p.discount, isError: true),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildSummaryRow('Total', p.totalAmount, isBold: true),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Paid', p.paidAmount, isSuccess: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildSummaryRow('Outstanding', p.dueAmount, isBold: true, isWarning: p.dueAmount > 0),
                      ],
                    ),
                  ),
                ),
                
                if (p.notes != null && p.notes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('Notes', style: AppTypography.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(p.notes!),
                ],
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, bool isError = false, bool isSuccess = false, bool isWarning = false}) {
    Color? color = AppColors.textPrimary;
    if (isError) color = AppColors.error;
    if (isSuccess) color = AppColors.success;
    if (isWarning) color = AppColors.warning;

    TextStyle? style = AppTypography.textTheme.bodyMedium?.copyWith(color: color);
    if (isBold) {
      style = AppTypography.textTheme.titleMedium?.copyWith(color: color);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        MoneyDisplay(amount: amount, style: style),
      ],
    );
  }
}
