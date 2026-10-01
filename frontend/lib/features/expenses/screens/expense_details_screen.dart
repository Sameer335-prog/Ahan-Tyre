import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../models/expenses_models.dart';
import '../services/expenses_service.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailsScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final _service = ExpensesService();
  Expense? _expense;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final expense = await _service.getExpenseById(widget.expenseId);
      setState(() {
        _expense = expense;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load expense details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading expense details...'));
    if (_errorMessage != null) return Scaffold(body: ErrorState(message: _errorMessage!, onRetry: _loadData));
    if (_expense == null) return const Scaffold(body: EmptyState(title: 'Not Found', message: 'Expense does not exist.'));

    final e = _expense!;
    final dateStr = DateFormat('dd MMMM yyyy').format(e.expenseDate.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/expenses')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expense Details', style: AppTypography.textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        e.categoryName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text('Amount', style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      MoneyDisplay(
                        amount: e.amount,
                        style: AppTypography.textTheme.displayMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                _buildDetailRow('Reference Number', e.expenseNumber),
                const SizedBox(height: 16),
                _buildDetailRow('Date', dateStr),
                const SizedBox(height: 16),
                _buildDetailRow('Payment Method', e.paymentMethodName),
                if (e.reference != null && e.reference!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow('External Reference', e.reference!),
                ],
                if (e.description != null && e.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow('Notes/Description', e.description!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: AppTypography.textTheme.titleMedium, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
