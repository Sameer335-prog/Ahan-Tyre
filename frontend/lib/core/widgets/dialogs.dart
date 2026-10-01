import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTypography.textTheme.headlineSmall),
      content: Text(
        message,
        style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (isDestructive)
          DangerButton(
            text: confirmText,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          )
        else
          PrimaryButton(
            text: confirmText,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static void show(BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
      ),
    );
  }
}
