import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../reports_controller.dart';
import '../models/report_models.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalesReportController(),
      child: const _SalesReportContent(),
    );
  }
}

class _SalesReportContent extends StatefulWidget {
  const _SalesReportContent();

  @override
  State<_SalesReportContent> createState() => _SalesReportContentState();
}

class _SalesReportContentState extends State<_SalesReportContent> {
  ReportFilter _filter = ReportFilter(
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesReportController>().load(_filter);
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _filter.startDate ?? DateTime.now(), end: _filter.endDate ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _filter.startDate = picked.start;
        _filter.endDate = picked.end;
      });
      if (context.mounted) {
        context.read<SalesReportController>().load(_filter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesReportController>();

    final dateStr = '${DateFormat('dd MMM yyyy').format(_filter.startDate!)} - ${DateFormat('dd MMM yyyy').format(_filter.endDate!)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Report'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          TextButton.icon(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
            label: Text(dateStr, style: const TextStyle(color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: controller.isLoading 
        ? const LoadingState(message: 'Generating report...')
        : controller.errorMessage != null
          ? ErrorState(message: controller.errorMessage!, onRetry: () => controller.load(_filter))
          : controller.summary == null || controller.summary!['data'].isEmpty
            ? const EmptyState(title: 'No Sales Found', message: 'No sales match the selected date range.', icon: Icons.receipt)
            : _buildReportBody(context, controller.summary!),
    );
  }

  Widget _buildReportBody(BuildContext context, Map<String, dynamic> summary) {
    final data = summary['data'] as List;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Row(
            children: [
              _buildSummaryStat('Total Sales', summary['count'].toString(), Icons.receipt),
              const SizedBox(width: 24),
              _buildSummaryStat('Total Revenue', 'Rs. ${NumberFormat('#,##0').format(summary['total'])}', Icons.monetization_on, color: AppColors.success),
              const SizedBox(width: 24),
              _buildSummaryStat('Total Paid', 'Rs. ${NumberFormat('#,##0').format(summary['paid'])}', Icons.check_circle, color: AppColors.primary),
              const SizedBox(width: 24),
              _buildSummaryStat('Outstanding', 'Rs. ${NumberFormat('#,##0').format(summary['outstanding'])}', Icons.warning_amber, color: AppColors.warning),
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
                  DataColumn(label: Text('Sale')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Paid')),
                  DataColumn(label: Text('Status')),
                ],
                rows: data.map((s) {
                  final saleDate = DateTime.parse(s['sale_date'] ?? s['created_at']);
                  final total = (s['total_amount'] as num).toDouble();
                  final paid = (s['paid_amount'] as num).toDouble();
                  // Derive status from amounts — no payment_status column in DB
                  final String status;
                  if (paid >= total) {
                    status = 'Paid';
                  } else if (paid > 0) {
                    status = 'Partial';
                  } else {
                    status = 'Credit';
                  }
                  
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () => context.go('/sales/${s['id']}'),
                          // FIX: DB column is invoice_number, not sale_number
                          child: Text(s['invoice_number'] ?? 'Unknown', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      DataCell(Text(DateFormat('dd MMM, yyyy').format(saleDate.toLocal()))),
                      DataCell(MoneyDisplay(amount: total, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(MoneyDisplay(amount: paid, style: const TextStyle(color: AppColors.success))),
                      DataCell(Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold))),
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
  
  Color _getStatusColor(String status) {
    if (status == 'PAID') return AppColors.success;
    if (status == 'UNPAID') return AppColors.error;
    return AppColors.warning;
  }
}
