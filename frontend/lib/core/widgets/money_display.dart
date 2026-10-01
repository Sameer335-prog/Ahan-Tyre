import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MoneyDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String label;

  const MoneyDisplay({
    super.key,
    required this.amount,
    this.style,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 0, // Avoid unnecessary decimal places for business
    ).format(amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 4),
        Text(
          formattedAmount,
          style: style ?? AppTypography.currencyMedium,
        ),
      ],
    );
  }
}

class BalanceDisplay extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;

  const BalanceDisplay({
    super.key,
    required this.label,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.successBackground : AppColors.errorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(amount),
            style: AppTypography.currencyLarge.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
