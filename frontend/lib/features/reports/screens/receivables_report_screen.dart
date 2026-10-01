import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../reports_controller.dart';

class ReceivablesReportScreen extends StatelessWidget {
  const ReceivablesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReceivablesReportController()..load(),
      child: const _ReceivablesContent(),
    );
  }
}

class _ReceivablesContent extends StatelessWidget {
  const _ReceivablesContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReceivablesReportController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Receivables'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: controller.isLoading 
        ? const LoadingState(message: 'Calculating ledgers...')
        : controller.errorMessage != null
          ? ErrorState(message: controller.errorMessage!, onRetry: controller.load)
          : controller.receivables.isEmpty
            ? const EmptyState(title: 'No Receivables Found', message: 'All customer balances are settled.', icon: Icons.sentiment_very_satisfied)
            : _buildReportBody(context, controller.receivables),
    );
  }

  Widget _buildReportBody(BuildContext context, List<Map<String, dynamic>> data) {
    double totalReceivables = 0;
    for (var r in data) {
      totalReceivables += (r['outstanding'] as num).toDouble();
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Row(
            children: [
              _buildSummaryStat('Total Receivables', 'Rs. ${totalReceivables.toStringAsFixed(0).replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ',')}', Icons.account_balance_wallet, color: AppColors.error),
              const SizedBox(width: 24),
              _buildSummaryStat('Customers in Debt', data.length.toString(), Icons.people, color: AppColors.warning),
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
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Outstanding Balance')),
                ],
                rows: data.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(r['phone'])),
                      DataCell(MoneyDisplay(amount: r['outstanding'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error))),
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
