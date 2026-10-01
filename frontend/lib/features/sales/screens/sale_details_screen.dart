import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/money_display.dart';
import '../models/sales_models.dart';
import '../services/sales_service.dart';

class SaleDetailsScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailsScreen({super.key, required this.saleId});

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen> {
  final _service = SalesService();
  Sale? _sale;
  List<SaleItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sale = await _service.getSaleById(widget.saleId);
      final items = await _service.getSaleItems(widget.saleId);
      
      setState(() {
        _sale = sale;
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load sale details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading sale details...'));
    if (_errorMessage != null) return Scaffold(body: ErrorState(message: _errorMessage!, onRetry: _loadData));
    if (_sale == null) return const Scaffold(body: EmptyState(title: 'Not Found', message: 'Sale does not exist.'));

    final s = _sale!;
    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(s.saleDate.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/sales')),
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
                        Text(s.invoiceNumber, style: AppTypography.textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(dateStr, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    TransactionStatus(status: s.paymentStatus),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Customer Details
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
                            Text('Customer', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(s.customerName ?? 'Walk-in Customer', style: AppTypography.textTheme.titleMedium),
                          ],
                        ),
                      ),
                      if (s.vehicleNumber != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vehicle', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(s.vehicleNumber!, style: AppTypography.textTheme.titleMedium),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Text('Items', style: AppTypography.textTheme.titleLarge),
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
                                  Text('Qty: ${item.quantity.toInt()} × Rs. ${NumberFormat('#,##0').format(item.unitPrice)}'),
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
                        _buildSummaryRow('Subtotal', s.subtotal),
                        if (s.discount > 0) ...[
                          const SizedBox(height: 12),
                          _buildSummaryRow('Discount', -s.discount, isError: true),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildSummaryRow('Total', s.totalAmount, isBold: true),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Paid', s.paidAmount, isSuccess: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildSummaryRow('Outstanding', s.dueAmount, isBold: true, isWarning: s.dueAmount > 0),
                      ],
                    ),
                  ),
                ),
                
                if (s.notes != null && s.notes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('Notes', style: AppTypography.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(s.notes!),
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
