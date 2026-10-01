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

    int totalUnits = 0;
    int lowStock = 0;
    int outOfStock = 0;

    for (var p in controller.displayedProducts) {
      totalUnits += p.currentStock.toInt();
      if (p.stockStatus == 'Out of Stock') outOfStock++;
      else if (p.stockStatus == 'Low Stock') lowStock++;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tyre Inventory', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '$totalUnits total units in stock',
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/inventory/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Tyre'),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: AppColors.background,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: controller.updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by tyre name, brand, or size...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterPill(
                        'All',
                        count: controller.displayedProducts.length,
                        isSelected: controller.selectedStockStatus == null || controller.selectedStockStatus == 'All',
                        onTap: () => controller.setFilter(stockStatus: 'All'),
                      ),
                      _buildFilterPill(
                        'In Stock',
                        isSelected: controller.selectedStockStatus == 'In Stock',
                        onTap: () => controller.setFilter(stockStatus: 'In Stock'),
                      ),
                      _buildFilterPill(
                        'Low Stock',
                        count: lowStock,
                        isSelected: controller.selectedStockStatus == 'Low Stock',
                        onTap: () => controller.setFilter(stockStatus: 'Low Stock'),
                      ),
                      _buildFilterPill(
                        'Out of Stock',
                        count: outOfStock,
                        isSelected: controller.selectedStockStatus == 'Out of Stock',
                        onTap: () => controller.setFilter(stockStatus: 'Out of Stock'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // List / Table or Empty State
          Expanded(
            child: controller.isLoading && controller.displayedProducts.isEmpty
                ? const LoadingState(message: 'Loading inventory...')
                : controller.errorMessage != null && controller.displayedProducts.isEmpty
                    ? ErrorState(message: controller.errorMessage!, onRetry: controller.loadData)
                    : controller.displayedProducts.isEmpty
                        ? _buildEmptyState(context)
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

  Widget _buildFilterPill(String label, {int? count, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No tyres match your filter',
              style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new tyre or adjust your search term.',
              style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/inventory/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add Tyre'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Product> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        width: double.infinity,
        child: DataTable(
          headingTextStyle: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
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
                    child: Text('${p.brand} ${p.model}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                DataCell(Text(p.sizeDisplay)),
                DataCell(Text(p.brand)),
                DataCell(Text(p.currentStock.toInt().toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(MoneyDisplay(amount: p.sellingPrice)),
                DataCell(StockStatus(quantity: p.currentStock.toInt())),
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${p.brand} ${p.model}', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
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
                        Text('Stock: ${p.currentStock.toInt()}', style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        MoneyDisplay(amount: p.sellingPrice, style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
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
