import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../reports_controller.dart';

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryReportController()..load(),
      child: const _InventoryContent(),
    );
  }
}

class _InventoryContent extends StatelessWidget {
  const _InventoryContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryReportController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Report'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: controller.isLoading 
        ? const LoadingState(message: 'Generating inventory snapshot...')
        : controller.errorMessage != null
          ? ErrorState(message: controller.errorMessage!, onRetry: controller.load)
          : controller.inventory.isEmpty
            ? const EmptyState(title: 'No Inventory', message: 'No products found.', icon: Icons.inventory_2)
            : _buildReportBody(context, controller.inventory),
    );
  }

  Widget _buildReportBody(BuildContext context, List<Map<String, dynamic>> data) {
    double totalStockValue = 0;
    int totalUnits = 0;
    int lowStockItems = 0;
    
    for (var p in data) {
      totalStockValue += (p['stock_value'] as num).toDouble();
      totalUnits += (p['current_stock'] as num).toInt();
      if ((p['current_stock'] as num) <= (p['minimum_stock'] as num)) {
        lowStockItems++;
      }
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Row(
            children: [
              _buildSummaryStat('Total Units in Stock', totalUnits.toString(), Icons.inventory),
              const SizedBox(width: 24),
              _buildSummaryStat('Total Stock Value', 'Rs. ${totalStockValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ',')}', Icons.monetization_on, color: AppColors.success),
              const SizedBox(width: 24),
              _buildSummaryStat('Low/Out of Stock Items', lowStockItems.toString(), Icons.warning_amber, color: AppColors.warning),
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
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Avg Cost')),
                  DataColumn(label: Text('Total Value')),
                  DataColumn(label: Text('Status')),
                ],
                rows: data.map((p) {
                  final status = p['stock_status'] ?? 'OK';
                  final isLow = status == 'Low Stock' || status == 'Out of Stock';
                  
                  return DataRow(
                    cells: [
                      DataCell(Text('${p['brand']} ${p['model']} (${p['size_display']})', style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(p['current_stock'].toString())),
                      DataCell(MoneyDisplay(amount: (p['average_cost'] as num).toDouble())),
                      DataCell(MoneyDisplay(amount: (p['stock_value'] as num).toDouble(), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(status, style: TextStyle(color: isLow ? AppColors.error : AppColors.success, fontWeight: FontWeight.bold))),
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
