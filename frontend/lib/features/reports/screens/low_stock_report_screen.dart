import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../reports_controller.dart';

class LowStockReportScreen extends StatelessWidget {
  const LowStockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LowStockReportController()..load(),
      child: const _LowStockContent(),
    );
  }
}

class _LowStockContent extends StatelessWidget {
  const _LowStockContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LowStockReportController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Low Stock Report'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: controller.isLoading 
        ? const LoadingState(message: 'Checking stock levels...')
        : controller.errorMessage != null
          ? ErrorState(message: controller.errorMessage!, onRetry: controller.load)
          : controller.items.isEmpty
            ? const EmptyState(title: 'Healthy Stock', message: 'All products are above their minimum stock thresholds.', icon: Icons.thumb_up)
            : _buildReportBody(context, controller.items),
    );
  }

  Widget _buildReportBody(BuildContext context, List<Map<String, dynamic>> data) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Row(
            children: [
              _buildSummaryStat('Items Needing Restock', data.length.toString(), Icons.warning_amber, color: AppColors.error),
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
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Current Stock')),
                  DataColumn(label: Text('Minimum Required')),
                  DataColumn(label: Text('Deficit')),
                  DataColumn(label: Text('Status')),
                ],
                rows: data.map((p) {
                  final status = p['stock_status'] ?? 'UNKNOWN';
                  final current = (p['current_stock'] as num).toInt();
                  final min = (p['minimum_stock'] as num).toInt();
                  final deficit = min - current;
                  
                  return DataRow(
                    cells: [
                      DataCell(Text('${p['brand']} ${p['model']} (${p['size_display']})', style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(current.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error))),
                      DataCell(Text(min.toString())),
                      DataCell(Text(deficit > 0 ? deficit.toString() : '0', style: const TextStyle(color: AppColors.warning))),
                      DataCell(Text(status, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
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
