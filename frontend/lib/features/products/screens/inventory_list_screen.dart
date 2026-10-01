import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/money_display.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../product_controller.dart';
import '../models/product.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductController(),
      child: const _InventoryListContent(),
    );
  }
}

class _InventoryListContent extends StatelessWidget {
  const _InventoryListContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (controller.isLoading && controller.displayedProducts.isEmpty) {
      return const LoadingState(message: 'Loading inventory...');
    }

    if (controller.errorMessage != null && controller.displayedProducts.isEmpty) {
      return ErrorState(
        message: controller.errorMessage!,
        onRetry: controller.loadData,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header & Summary
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Products / Inventory', style: AppTypography.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Manage tyre products and stock',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      text: '+ Add Product',
                      onPressed: () => context.go('/inventory/new'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSummaryCounters(controller.displayedProducts),
                const SizedBox(height: 24),
                _buildFiltersRow(context, controller, isDesktop),
              ],
            ),
          ),
          
          // List / Table
          Expanded(
            child: controller.displayedProducts.isEmpty
                ? const EmptyState(
                    title: 'No products found',
                    message: 'Try changing your search or filters.',
                    icon: Icons.inventory_2_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadData,
                    child: isDesktop 
                        ? _buildDesktopTable(context, controller.displayedProducts)
                        : _buildMobileList(context, controller.displayedProducts),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCounters(List<Product> products) {
    int totalUnits = 0;
    int lowStock = 0;
    int outOfStock = 0;

    for (var p in products) {
      totalUnits += p.currentStock.toInt();
      if (p.stockStatus == 'Out of Stock') outOfStock++;
      else if (p.stockStatus == 'Low Stock') lowStock++;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCounter('Total Products', products.length.toString()),
        _buildCounter('Total Units', totalUnits.toString()),
        _buildCounter('Low Stock', lowStock.toString(), isAlert: true),
        _buildCounter('Out of Stock', outOfStock.toString(), isError: true),
      ],
    );
  }

  Widget _buildCounter(String label, String value, {bool isAlert = false, bool isError = false}) {
    Color valColor = AppColors.textPrimary;
    if (isAlert) valColor = AppColors.warning;
    if (isError) valColor = AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.textTheme.titleMedium?.copyWith(color: valColor)),
      ],
    );
  }

  Widget _buildFiltersRow(BuildContext context, ProductController controller, bool isDesktop) {
    final searchField = SizedBox(
      width: isDesktop ? 300 : double.infinity,
      child: AppSearchField(
        hint: 'Search tyres...',
        onChanged: controller.updateSearch,
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildBrandDropdown(controller)),
              const SizedBox(width: 8),
              Expanded(child: _buildStockDropdown(controller)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        searchField,
        const SizedBox(width: 16),
        SizedBox(width: 150, child: _buildBrandDropdown(controller)),
        const SizedBox(width: 16),
        SizedBox(width: 150, child: _buildStockDropdown(controller)),
      ],
    );
  }

  Widget _buildBrandDropdown(ProductController controller) {
    final brands = ['All', ...controller.availableBrands];
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(),
      ),
      value: controller.selectedBrand ?? 'All',
      items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
      onChanged: (val) => controller.setFilter(brand: val),
    );
  }

  Widget _buildStockDropdown(ProductController controller) {
    final statuses = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(),
      ),
      value: controller.selectedStockStatus ?? 'All',
      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (val) => controller.setFilter(stockStatus: val),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Product> products) {
    return SingleChildScrollView(
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
            DataColumn(label: Text('Size')),
            DataColumn(label: Text('Brand')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Status')),
          ],
          rows: products.map((p) {
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.go('/inventory/${p.id}'),
                    child: Text('${p.brand} ${p.model}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                ),
                DataCell(Text(p.sizeDisplay)),
                DataCell(Text(p.brand)),
                DataCell(Text(p.currentStock.toInt().toString())),
                DataCell(MoneyDisplay(amount: p.sellingPrice)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!p.isActive) const Padding(padding: EdgeInsets.only(right: 8), child: TransactionStatus(status: 'Reversed')), // Using Reversed style for inactive
                      StockStatus(quantity: p.currentStock.toInt()),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Product> products) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = products[index];
        return InkWell(
          onTap: () => context.go('/inventory/${p.id}'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${p.brand} ${p.model}', style: AppTypography.textTheme.titleMedium),
                    if (!p.isActive) const TransactionStatus(status: 'Reversed'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.sizeDisplay, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock: ${p.currentStock.toInt()}', style: AppTypography.textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        MoneyDisplay(amount: p.sellingPrice),
                      ],
                    ),
                    StockStatus(quantity: p.currentStock.toInt()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
