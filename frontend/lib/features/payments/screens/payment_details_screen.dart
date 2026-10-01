import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/money_display.dart';
import '../models/payments_models.dart';
import '../services/payments_service.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _service = PaymentsService();
  Payment? _payment;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final payment = await _service.getPaymentById(widget.paymentId);
      setState(() {
        _payment = payment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load payment details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading payment details...'));
    if (_errorMessage != null) return Scaffold(body: ErrorState(message: _errorMessage!, onRetry: _loadData));
    if (_payment == null) return const Scaffold(body: EmptyState(title: 'Not Found', message: 'Payment does not exist.'));

    final p = _payment!;
    final dateStr = DateFormat('dd MMMM yyyy').format(p.paymentDate.toLocal());
    final isReceived = p.direction == 'IN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/payments')),
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
                    Text(p.type, style: AppTypography.textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isReceived ? AppColors.successBackground : AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isReceived ? 'Received' : 'Paid',
                        style: TextStyle(
                          color: isReceived ? AppColors.success : AppColors.error,
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
                        amount: p.amount,
                        style: AppTypography.textTheme.displayMedium?.copyWith(
                          color: isReceived ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                _buildDetailRow('Reference Number', p.paymentNumber),
                const SizedBox(height: 16),
                _buildDetailRow('Date', dateStr),
                const SizedBox(height: 16),
                _buildDetailRow(isReceived ? 'Customer' : 'Supplier', p.partyName),
                const SizedBox(height: 16),
                _buildDetailRow('Payment Method', p.paymentMethodName),
                if (p.reference != null && p.reference!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow('External Reference', p.reference!),
                ],
                if (p.notes != null && p.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow('Notes', p.notes!),
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
