import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../reports_controller.dart';

class PayablesReportScreen extends StatelessWidget {
  const PayablesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PayablesReportController()..load(),
      child: const _PayablesContent(),
    );
  }
}

class _PayablesContent extends StatelessWidget {
  const _PayablesContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PayablesReportController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supplier Payables'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: controller.isLoading 
        ? const LoadingState(message: 'Calculating ledgers...')
        : controller.errorMessage != null
          ? ErrorState(message: controller.errorMessage!, onRetry: controller.load)
          : controller.payables.isEmpty
            ? const EmptyState(title: 'No Payables Found', message: 'All supplier balances are settled.', icon: Icons.sentiment_very_satisfied)
            : _buildReportBody(context, controller.payables),
    );
  }

  Widget _buildReportBody(BuildContext context, List<Map<String, dynamic>> data) {
    double totalPayables = 0;
    for (var p in data) {
      totalPayables += (p['outstanding'] as num).toDouble();
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Row(
            children: [
              _buildSummaryStat('Total Payables', 'Rs. ${totalPayables.toStringAsFixed(0).replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ',')}', Icons.account_balance_wallet, color: AppColors.warning),
              const SizedBox(width: 24),
              _buildSummaryStat('Suppliers to Pay', data.length.toString(), Icons.local_shipping, color: AppColors.error),
            ],
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
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
                  DataColumn(label: Text('Supplier')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Outstanding Payable')),
                ],
                rows: data.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(p['phone'])),
                      DataCell(MoneyDisplay(amount: p['outstanding'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStat(String title, String value, IconData icon, {Color color = AppColors.primary}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(title, style: AppTypography.textTheme.bodyMedium?.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
