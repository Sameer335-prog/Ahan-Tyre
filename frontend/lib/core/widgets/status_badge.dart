import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BadgeType { success, warning, error, info, normal }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case BadgeType.success:
        backgroundColor = AppColors.successBackground;
        textColor = AppColors.success;
        break;
      case BadgeType.warning:
        backgroundColor = AppColors.warningBackground;
        textColor = AppColors.warning;
        break;
      case BadgeType.error:
        backgroundColor = AppColors.errorBackground;
        textColor = AppColors.error;
        break;
      case BadgeType.info:
        backgroundColor = AppColors.infoBackground;
        textColor = AppColors.info;
        break;
      case BadgeType.normal:
      default:
        backgroundColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class TransactionStatus extends StatelessWidget {
  final String status; // 'Paid', 'Partial', 'Pending', 'Returned', 'Reversed'

  const TransactionStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    BadgeType type;
    switch (status.toLowerCase()) {
      case 'paid':
        type = BadgeType.success;
        break;
      case 'partial':
        type = BadgeType.info;
        break;
      case 'pending':
        type = BadgeType.warning;
        break;
      case 'returned':
      case 'reversed':
        type = BadgeType.error;
        break;
      default:
        type = BadgeType.normal;
    }

    return StatusBadge(label: status, type: type);
  }
}

class StockStatus extends StatelessWidget {
  final int quantity;
  final int minThreshold;

  const StockStatus({
    super.key,
    required this.quantity,
    this.minThreshold = 5,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    BadgeType type;

    if (quantity <= 0) {
      label = 'Out of Stock';
      type = BadgeType.error;
    } else if (quantity <= minThreshold) {
      label = 'Low Stock ($quantity)';
      type = BadgeType.warning;
    } else {
      label = 'In Stock ($quantity)';
      type = BadgeType.success;
    }

    return StatusBadge(label: label, type: type);
  }
}
