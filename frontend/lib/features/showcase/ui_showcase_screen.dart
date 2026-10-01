import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import '../../core/widgets/money_display.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/states.dart';
import '../../core/widgets/dialogs.dart';

class UiShowcaseScreen extends StatefulWidget {
  const UiShowcaseScreen({super.key});

  @override
  State<UiShowcaseScreen> createState() => _UiShowcaseScreenState();
}

class _UiShowcaseScreenState extends State<UiShowcaseScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Components Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Typography'),
            Text('Display Large', style: AppTypography.textTheme.displayLarge),
            Text('Headline Medium', style: AppTypography.textTheme.headlineMedium),
            Text('Title Large', style: AppTypography.textTheme.titleLarge),
            Text('Body Medium', style: AppTypography.textTheme.bodyMedium),
            const SizedBox(height: 32),

            _buildSectionHeader('Buttons'),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                PrimaryButton(text: 'Primary Button', onPressed: () {}, icon: Icons.save),
                SecondaryButton(text: 'Secondary Button', onPressed: () {}, icon: Icons.edit),
                DangerButton(text: 'Danger Button', onPressed: () {}),
                PrimaryButton(
                  text: 'Loading Button',
                  onPressed: () {},
                  isLoading: _isLoading,
                ),
                TextButton(
                  onPressed: () {
                    setState(() { _isLoading = !_isLoading; });
                  },
                  child: const Text('Toggle Loading'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Inputs'),
            const AppTextField(label: 'Customer Name', hint: 'Enter customer name'),
            const SizedBox(height: 16),
            const AppSearchField(hint: 'Search products...'),
            const SizedBox(height: 32),

            _buildSectionHeader('Financial Displays'),
            const Wrap(
              spacing: 24,
              children: [
                MoneyDisplay(amount: 125000, label: 'Total Amount'),
                BalanceDisplay(label: 'Receivable', amount: 70000, isPositive: true),
                BalanceDisplay(label: 'Payable', amount: 120000, isPositive: false),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Status Badges'),
            const Wrap(
              spacing: 16,
              children: [
                TransactionStatus(status: 'Paid'),
                TransactionStatus(status: 'Pending'),
                TransactionStatus(status: 'Returned'),
                StockStatus(quantity: 45),
                StockStatus(quantity: 3),
                StockStatus(quantity: 0),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Dialogs & Modals'),
            PrimaryButton(
              text: 'Show Confirm Dialog',
              onPressed: () {
                ConfirmDialog.show(
                  context,
                  title: 'Complete Sale?',
                  message: 'This will update inventory, payment, and customer balance.',
                  confirmText: 'Confirm Sale',
                  onConfirm: () {},
                );
              },
            ),
            const SizedBox(height: 16),
            DangerButton(
              text: 'Show Delete Dialog',
              onPressed: () {
                ConfirmDialog.show(
                  context,
                  title: 'Delete Product?',
                  message: 'This action cannot be undone.',
                  confirmText: 'Delete',
                  isDestructive: true,
                  onConfirm: () {},
                );
              },
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Empty & Error States'),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: EmptyState(
                title: 'No customers yet',
                message: 'Add your first customer to start managing records.',
                actionLabel: 'Add Customer',
                onAction: () {},
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ErrorState(onRetry: () {}),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textTheme.titleLarge?.copyWith(color: AppColors.primary)),
          const Divider(),
        ],
      ),
    );
  }
}
